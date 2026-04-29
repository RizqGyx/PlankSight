import AVFoundation
import Foundation
import UIKit

final class CameraSessionManager: NSObject {
    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "planksight.camera.session.queue")
    private let outputQueue = DispatchQueue(label: "planksight.camera.output.queue")
    private let videoOutput = AVCaptureVideoDataOutput()
    private var videoInput: AVCaptureDeviceInput?
    private var currentCameraPosition: AVCaptureDevice.Position = .back

    nonisolated(unsafe) var onSampleBuffer: ((CMSampleBuffer) -> Void)?
    nonisolated(unsafe) var onCameraPositionChanged: ((AVCaptureDevice.Position) -> Void)?

    private(set) var isConfigured = false
    private var currentVideoRotationAngle: CGFloat = 270

    var isUsingFrontCamera: Bool { currentCameraPosition == .front }

    func requestPermissionAndConfigure(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSessionIfNeeded(completion: completion)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else { completion(false); return }
                self.configureSessionIfNeeded(completion: completion)
            }
        default:
            completion(false)
        }
    }

    func startSession() {
        sessionQueue.async {
            guard self.isConfigured, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    func stopSession() {
        sessionQueue.async {
            guard self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    func toggleCamera() {
        sessionQueue.async {
            guard self.isConfigured else { return }
            let nextPosition: AVCaptureDevice.Position = self.currentCameraPosition == .back ? .front : .back
            guard let newInput = self.makeVideoInput(for: nextPosition) else { return }

            self.session.beginConfiguration()
            if let existing = self.videoInput { self.session.removeInput(existing) }
            guard self.session.canAddInput(newInput) else {
                if let existing = self.videoInput, self.session.canAddInput(existing) {
                    self.session.addInput(existing)
                }
                self.session.commitConfiguration()
                return
            }

            self.session.addInput(newInput)
            self.videoInput = newInput
            self.currentCameraPosition = nextPosition

            if let connection = self.videoOutput.connection(with: .video) {
                let angle = self.currentVideoRotationAngle
                if connection.isVideoRotationAngleSupported(angle) {
                    connection.videoRotationAngle = angle
                }
                self.applyMirroring(connection: connection, isMirrored: false)
            }

            self.session.commitConfiguration()

            // Configure exposure AFTER commit — safe to lock device here
            self.configureExposureForBacklight(device: newInput.device)

            let callback = self.onCameraPositionChanged
            DispatchQueue.main.async { callback?(nextPosition) }
        }
    }

    // Update video rotation when device orientation changes.
    // landscapeLeft (top goes LEFT) needs 90° — with 270° Vision sees the person upside-down.
    // landscapeRight (top goes RIGHT) and portrait work correctly with 270°.
    func updateVideoRotation(deviceOrientation: UIDeviceOrientation) {
        currentVideoRotationAngle = Self.videoRotationAngle(for: deviceOrientation)
        sessionQueue.async {
            guard let connection = self.videoOutput.connection(with: .video) else { return }
            let angle = self.currentVideoRotationAngle
            if connection.isVideoRotationAngleSupported(angle) {
                connection.videoRotationAngle = angle
            }
        }
    }

    private static func videoRotationAngle(for orientation: UIDeviceOrientation) -> CGFloat {
        switch orientation {
        case .landscapeLeft: return 90    // top goes LEFT → 270° makes person upside-down for Vision
        default:             return 270   // landscapeRight (top goes right), portrait — 270° correct
        }
    }

    private func configureSessionIfNeeded(completion: @escaping (Bool) -> Void) {
        sessionQueue.async {
            if self.isConfigured { completion(true); return }

            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            guard let input = self.makeVideoInput(for: self.currentCameraPosition) else {
                self.session.commitConfiguration(); completion(false); return
            }
            guard self.session.canAddInput(input) else {
                self.session.commitConfiguration(); completion(false); return
            }

            self.session.addInput(input)
            self.videoInput = input

            self.videoOutput.alwaysDiscardsLateVideoFrames = true
            self.videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            self.videoOutput.setSampleBufferDelegate(self, queue: self.outputQueue)

            guard self.session.canAddOutput(self.videoOutput) else {
                self.session.commitConfiguration(); completion(false); return
            }

            self.session.addOutput(self.videoOutput)

            if let connection = self.videoOutput.connection(with: .video) {
                let angle = self.currentVideoRotationAngle
                if connection.isVideoRotationAngleSupported(angle) {
                    connection.videoRotationAngle = angle
                }
                self.applyMirroring(connection: connection, isMirrored: false)
            }

            self.session.commitConfiguration()
            self.isConfigured = true

            // Configure exposure AFTER commit — lockForConfiguration must not run
            // inside a beginConfiguration/commitConfiguration block.
            if let device = self.videoInput?.device {
                self.configureExposureForBacklight(device: device)
            }

            completion(true)

            let callback = self.onCameraPositionChanged
            DispatchQueue.main.async { callback?(self.currentCameraPosition) }
        }
    }

    private func makeVideoInput(for position: AVCaptureDevice.Position) -> AVCaptureDeviceInput? {
        guard
            let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
            let input = try? AVCaptureDeviceInput(device: camera)
        else { return nil }
        return input
    }

    // Optimizes camera for backlighting scenes. Must be called OUTSIDE beginConfiguration/commitConfiguration
    // to avoid internal AVFoundation deadlock from concurrent lockForConfiguration + beginConfiguration.
    private func configureExposureForBacklight(device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }

            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = CGPoint(x: 0.5, y: 0.5)
            }
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            }
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
        } catch {
            // Camera still works with default settings if configuration fails
        }
    }

    private func applyMirroring(connection: AVCaptureConnection, isMirrored: Bool) {
        guard connection.isVideoMirroringSupported else { return }
        if connection.automaticallyAdjustsVideoMirroring {
            connection.automaticallyAdjustsVideoMirroring = false
        }
        if connection.isVideoMirrored != isMirrored {
            connection.isVideoMirrored = isMirrored
        }
    }
}

extension CameraSessionManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        onSampleBuffer?(sampleBuffer)
    }
}
