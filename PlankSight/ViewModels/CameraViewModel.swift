import AVFoundation
import Combine
import Foundation
import SwiftUI
import UIKit
import WidgetKit

class CameraViewModel: ObservableObject {

    // MARK: - Config
    let duration: Int?

    // MARK: - Published State (consumed by CameraView)
    @Published var trackingState: PlankTrackingState = .idle
    @Published var poseFrame: PlankPoseFrame = .empty
    @Published var isUsingFrontCamera: Bool = false
    @Published var timerDisplay: String = "00:00"
    @Published var timerProgress: Double = 0.0
    @Published var currentMistake: PlankFormMistakeType? = nil
    @Published var statusText: String = ""
    @Published var indicatorOpacity: Double = 0.2
    @Published var sessionCompleted: Bool = false
    @Published var sessionResult: SessionResult? = nil
    @Published var tiltGuidanceText: String? = nil
    @Published var hasPose: Bool = false

    // MARK: - Camera Session (handed to CameraPreviewView)
    let cameraSession: AVCaptureSession

    // MARK: - Services
    private let cameraManager = CameraSessionManager()
    private let poseService = PoseDetectionService()
    private let sideNormalizer = PoseSideNormalizer()
    private let poseSmoother = PoseSmoother()
    private let poseValidator = PoseFrameValidator()
    private let liveMetricCalculator = PlankMetricCalculator(minimumReliableConfidence: 0.28)
    private let mistakeDetector = PlankMistakeDetector()
    private let voiceCoach = PlankVoiceCoach()
    private let startStopDetector = StartStopDetector()
    private let timerService: PlankTimerService

    // MARK: - Private State
    private let processingQueue = DispatchQueue(label: "planksight.pose.processing")
    private let frameLock = NSLock()
    private var isProcessingFrame = false
    private var deviceOrientation: UIDeviceOrientation = .unknown
    private var orientationObserver: NSObjectProtocol?
    private var displayTimerCancellable: AnyCancellable?
    private var isPlankEligible = false
    private var activeSideLabel: String? = nil
    private var previousStateCategory: String = "idle"
    private var lastVoiceMistake: PlankFormMistakeType? = nil
    private var lastVoiceStatusKey: String = ""
    private var lastIsTrackable = false

    // MARK: - Mistake Tracking
    private var sessionMistakes: [RecordedMistake] = []
    private var lastRecordedMistakeType: PlankFormMistakeType? = nil

    // MARK: - Init
    init(duration: Int? = nil) {
        self.duration = duration
        let mode: PlankTimerService.Mode = duration.map { .timed(duration: TimeInterval($0)) } ?? .free
        self.timerService = PlankTimerService(mode: mode)
        self.cameraSession = cameraManager.session
        // Show target duration immediately (e.g. "01:00") instead of "00:00"
        self.timerDisplay = self.timerService.timerDisplay

        timerService.onCompleted = { [weak self] in
            DispatchQueue.main.async { self?.finalizeSession() }
        }

        bindCameraFrames()
    }

    // MARK: - Lifecycle
    func onAppear() {
        startOrientationMonitoring()
        setupDisplayTimer()

        cameraManager.onCameraPositionChanged = { [weak self] position in
            DispatchQueue.main.async {
                self?.isUsingFrontCamera = (position == .front)
            }
        }

        cameraManager.requestPermissionAndConfigure { [weak self] granted in
            DispatchQueue.main.async {
                guard let self, granted else { return }
                self.cameraManager.startSession()
                self.cameraManager.updateVideoRotation(deviceOrientation: self.deviceOrientation)
            }
        }
    }

    func onDisappear() {
        displayTimerCancellable?.cancel()
        cameraManager.stopSession()
        poseSmoother.reset()
        sideNormalizer.reset()
        mistakeDetector.reset()
        voiceCoach.reset()
        startStopDetector.reset()
        timerService.reset()
        stopOrientationMonitoring()
        cameraManager.onCameraPositionChanged = nil
        poseFrame = .empty
        isPlankEligible = false
        lastIsTrackable = false
        activeSideLabel = nil
    }

    // MARK: - Public Actions
    func toggleCamera() {
        cameraManager.toggleCamera()
    }

    func requestStop() {
        guard !sessionCompleted else { return }
        if timerService.strictElapsed > 0 {
            finalizeSession()
        }
        // If no strict time, CameraView handles the pop
    }

    var hasValidSession: Bool { timerService.strictElapsed > 0 }

    // MARK: - Derived Properties
    var isDeviceLandscape: Bool { deviceOrientation.isLandscape }

    var currentAlertMessage: String? { currentMistake?.displayText }

    // MARK: - Camera Frame Binding
    private func bindCameraFrames() {
        cameraManager.onSampleBuffer = { [weak self] sampleBuffer in
            guard let self else { return }
            guard self.beginFrameProcessing() else { return }

            self.processingQueue.async {
                defer { self.endFrameProcessing() }
                let detectedFrame = self.poseService.detectPose(in: sampleBuffer)
                let rawTS = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
                let timestamp = rawTS.isFinite && rawTS > 0 ? rawTS : ProcessInfo.processInfo.systemUptime

                DispatchQueue.main.async {
                    self.processFrame(detectedFrame, timestamp: timestamp)
                }
            }
        }
    }

    private func processFrame(_ frame: PlankPoseFrame?, timestamp: TimeInterval) {
        guard !sessionCompleted else { return }

        var smoothedFrame: PlankPoseFrame = .empty
        var isTrackable = false
        var isEligible = false
        var currentSideLabel: String? = nil
        var calibCase: PlankCalibrationCase? = nil

        if let detected = frame {
            let normalized = sideNormalizer.normalize(frame: detected)
            let smoothed = poseSmoother.smooth(frame: normalized)
            currentSideLabel = sideNormalizer.activeSideLabel

            let liveMetrics = liveMetricCalculator.calculate(frame: smoothed, activeSideLabel: currentSideLabel)
            calibCase = currentCalibrationCase(
                activeSideLabel: currentSideLabel,
                bodySlopeDegrees: liveMetrics.shoulderToAnkleSlopeDegrees
            )
            isTrackable = poseValidator.isFrameTrackable(smoothed)
            isEligible = poseValidator.isFrameEligibleForPlankTimer(
                smoothed, activeSideLabel: currentSideLabel, calibrationCase: calibCase
            )

            smoothedFrame = smoothed
            activeSideLabel = currentSideLabel

            let now = ProcessInfo.processInfo.systemUptime
            let feedback = mistakeDetector.evaluate(
                frame: smoothed,
                activeSideLabel: currentSideLabel,
                calibrationCase: calibCase,
                now: now
            )
            currentMistake = feedback.primaryMistake
            handleVoiceCoaching(mistake: feedback.primaryMistake, now: now)
        } else {
            if lastIsTrackable {
                poseSmoother.reset()
                sideNormalizer.reset()
                mistakeDetector.reset()
                lastVoiceMistake = nil
            }
            currentMistake = nil
            activeSideLabel = nil
        }

        // Record mistake when it first appears (deduplicated by type change)
        if timerService.isActive, currentMistake != lastRecordedMistakeType {
            if let mistake = currentMistake {
                let elapsed = Int(timerService.trackedElapsed)
                sessionMistakes.append(RecordedMistake(typeName: mistake.rawValue, sessionSecond: elapsed))
            }
            lastRecordedMistakeType = currentMistake
        }

        lastIsTrackable = isTrackable
        poseFrame = smoothedFrame
        hasPose = smoothedFrame.hasPose
        isPlankEligible = isEligible

        let newState = startStopDetector.update(isTrackable: isTrackable, timestamp: timestamp)
        handleStateTransition(newState: newState, isTrackable: isTrackable, isEligible: isEligible, timestamp: timestamp)
        updateTrackingStatePublished(newState)
        updateStatusText(state: newState, isTrackable: isTrackable, isEligible: isEligible, side: currentSideLabel)
        updateIndicator(isTrackable: isTrackable)
        updateTiltGuidance(side: currentSideLabel)
    }

    // MARK: - State Transition Handling
    private func handleStateTransition(newState: PlankTrackingState, isTrackable: Bool, isEligible: Bool, timestamp: TimeInterval) {
        let newCategory = stateCategory(newState)
        let wasActive = previousStateCategory == "active"
        let isNowActive = newCategory == "active"
        let isNowEnded = newCategory == "ended"

        if isNowActive {
            if !timerService.isActive {
                timerService.startSession()
                sessionMistakes = []
                lastRecordedMistakeType = nil
                let now = ProcessInfo.processInfo.systemUptime
                voiceCoach.speak("Timer dimulai", now: now, force: true)
            }
            // Strict time only counts when pose is eligible AND no active stable mistake.
            // This ensures quality accurately reflects clean form time.
            let strictEligible = isEligible && (currentMistake == nil)
            timerService.tickStrict(isTracked: isTrackable, isEligible: strictEligible, timestamp: timestamp)
        }

        if isNowEnded && (wasActive || timerService.isActive) {
            timerService.stopSession()
            if timerService.strictElapsed > 0 {
                finalizeSession()
            }
        }

        previousStateCategory = newCategory
    }

    // Publish tracking state only when the category changes (idle/candidate/active/ended)
    // to avoid per-frame SwiftUI rerenders from associated-value changes.
    private func updateTrackingStatePublished(_ newState: PlankTrackingState) {
        let newCat = stateCategory(newState)
        let oldCat = stateCategory(trackingState)
        if newCat != oldCat {
            trackingState = newState
        } else if case .candidate = newState, case .candidate = trackingState {
            trackingState = newState  // update stableTrackableFrames for UI
        }
    }

    private func stateCategory(_ state: PlankTrackingState) -> String {
        switch state {
        case .idle: return "idle"
        case .candidate: return "candidate"
        case .active: return "active"
        case .ended: return "ended"
        }
    }

    // MARK: - Session Finalization
    private func finalizeSession() {
        guard !sessionCompleted else { return }
        sessionCompleted = true
        timerService.stopSession()
        let now = ProcessInfo.processInfo.systemUptime
        if case .timed = timerService.mode {
            voiceCoach.speak("Waktu habis, kerja bagus!", now: now, force: true)
        } else {
            voiceCoach.speak("Sesi selesai", now: now, force: true)
        }
        let result = SessionResult(
            totalDisplaySeconds: Int(timerService.trackedElapsed),
            strictSeconds: Int(timerService.strictElapsed),
            targetDuration: duration,
            mistakes: sessionMistakes
        )
        sessionResult = result
        let record = SessionRecord(
            totalDisplaySeconds: result.totalDisplaySeconds,
            strictSeconds: result.strictSeconds,
            targetDuration: result.targetDuration,
            mistakes: sessionMistakes
        )
        SessionRepository.shared.save(record)
        NotificationService.shared.logSessionCompleted()
        writeWidgetData(result: result)
    }

    // MARK: - UI State Updates
    private func updateStatusText(
        state: PlankTrackingState,
        isTrackable: Bool,
        isEligible: Bool,
        side: String?
    ) {
        let sideLabel = side.map { " (\($0))" } ?? ""

        let newKey: String
        switch state {
        case .idle, .candidate:
            if !isTrackable { newKey = "no_pose" }
            else if !isEligible { newKey = "bad_form" }
            else { newKey = "eligible" }
        case .active:
            newKey = "active"
        case .ended:
            newKey = "ended"
        }

        let newText: String
        switch newKey {
        case "no_pose":   newText = "Lakukan posisi plank untuk melanjutkan\(sideLabel)"
        case "bad_form":  newText = "Tubuh terdeteksi, tahan posisi plank\(sideLabel)"
        case "eligible":  newText = "Tahan untuk memulai timer\(sideLabel)"
        case "active":    newText = "Timer berjalan\(sideLabel)"
        case "ended":     newText = "Sesi berakhir"
        default:          newText = ""
        }

        statusText = newText

        // Voice status announcements (only when status key changes, no mistake active)
        if newKey != lastVoiceStatusKey, currentMistake == nil {
            let now = ProcessInfo.processInfo.systemUptime
            switch newKey {
            case "no_pose":  voiceCoach.speak("Lakukan posisi plank untuk melanjutkan", now: now, samePhraseCooldown: 4.0)
            case "bad_form": voiceCoach.speak("Tubuh terdeteksi, tahan posisi plank", now: now, samePhraseCooldown: 4.0)
            case "eligible": voiceCoach.speak("Tahan untuk memulai timer", now: now, samePhraseCooldown: 4.0)
            default: break
            }
            lastVoiceStatusKey = newKey
        }
    }

    private func updateIndicator(isTrackable: Bool) {
        if !hasPose {
            indicatorOpacity = 0.2
        } else if !isTrackable {
            indicatorOpacity = 0.5
        } else {
            indicatorOpacity = 1.0
        }
    }

    private func updateTiltGuidance(side: String?) {
        guard let side, deviceOrientation.isLandscape else {
            tiltGuidanceText = nil
            return
        }
        let expected: String = side == "left" ? "landscapeLeft" : "landscapeRight"
        let actual: String = deviceOrientation == .landscapeLeft ? "landscapeLeft" : "landscapeRight"
        if expected != actual {
            tiltGuidanceText = side == "left"
                ? "Miringkan ponsel ke kiri untuk hasil terbaik"
                : "Miringkan ponsel ke kanan untuk hasil terbaik"
        } else {
            tiltGuidanceText = nil
        }
    }

    // MARK: - Voice Coaching
    private func handleVoiceCoaching(mistake: PlankFormMistakeType?, now: TimeInterval) {
        guard let mistake else {
            lastVoiceMistake = nil
            return
        }
        let isNew = mistake != lastVoiceMistake
        voiceCoach.speak(
            mistake.coachingInstruction,
            now: now,
            force: isNew,
            samePhraseCooldown: 5.0
        )
        lastVoiceMistake = mistake
    }

    // MARK: - Display Timer (refreshes UI at 10 Hz)
    private func setupDisplayTimer() {
        displayTimerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.timerService.updateDisplay()
                self.timerDisplay = self.timerService.timerDisplay
                self.timerProgress = self.timerService.progress
            }
    }

    // MARK: - Calibration Case
    private func currentCalibrationCase(
        activeSideLabel: String?,
        bodySlopeDegrees: CGFloat?
    ) -> PlankCalibrationCase? {
        let landscapeSlopeThreshold: CGFloat = 58

        let plankSide: String? = {
            guard let label = activeSideLabel else { return nil }
            return isUsingFrontCamera ? (label == "left" ? "right" : "left") : label
        }()

        if let slope = bodySlopeDegrees, slope >= landscapeSlopeThreshold {
            switch plankSide {
            case "left":  return .landscapeTiltLeftPlankLeft
            case "right": return .landscapeTiltRightPlankRight
            default: return nil
            }
        }

        switch deviceOrientation {
        case .landscapeLeft  where plankSide == "left":  return .landscapeTiltLeftPlankLeft
        case .landscapeRight where plankSide == "right": return .landscapeTiltRightPlankRight
        default: break
        }

        switch plankSide {
        case "left":  return .portraitPlankLeft
        case "right": return .portraitPlankRight
        default: return nil
        }
    }

    // MARK: - Orientation Monitoring
    private func startOrientationMonitoring() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        deviceOrientation = UIDevice.current.orientation
        cameraManager.updateVideoRotation(deviceOrientation: deviceOrientation)
        orientationObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.deviceOrientation = UIDevice.current.orientation
            self.cameraManager.updateVideoRotation(deviceOrientation: self.deviceOrientation)
        }
    }

    private func stopOrientationMonitoring() {
        if let obs = orientationObserver {
            NotificationCenter.default.removeObserver(obs)
            orientationObserver = nil
        }
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    // MARK: - Frame Processing Lock
    private func beginFrameProcessing() -> Bool {
        frameLock.lock()
        defer { frameLock.unlock() }
        if isProcessingFrame { return false }
        isProcessingFrame = true
        return true
    }

    private func endFrameProcessing() {
        frameLock.lock()
        isProcessingFrame = false
        frameLock.unlock()
    }

    // MARK: - Widget Data Sync

    private func writeWidgetData(result: SessionResult) {
        let defaults = UserDefaults(suiteName: "group.com.berzki.planksight") ?? .standard
        defaults.set(SessionRepository.shared.currentStreak(), forKey: "currentStreak")
        defaults.set(Date(), forKey: "lastSessionDate")
        defaults.set(result.qualityPercent, forKey: "lastQualityPercent")
        defaults.set(result.totalDisplaySeconds, forKey: "lastDurationSeconds")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
