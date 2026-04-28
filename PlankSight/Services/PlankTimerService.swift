import Foundation

// Three-clock timer:
// - displayElapsed: wall clock since startSession() (kept for reference)
// - trackedElapsed: only advances when user is detected (isTracked). Grace period excluded.
// - strictElapsed: only advances when pose is valid & timer-eligible.
final class PlankTimerService {
    enum Mode {
        case free
        case timed(duration: TimeInterval)
    }

    let mode: Mode
    private(set) var isActive = false

    // Display clock — total wall time since startSession()
    private var sessionStartDate: Date?
    private(set) var displayElapsed: TimeInterval = 0

    // Tracked clock — only when user is detected with trackable joints (grace period excluded)
    private(set) var trackedElapsed: TimeInterval = 0
    // Strict clock — only accumulates when pose is valid & timer-eligible
    private(set) var strictElapsed: TimeInterval = 0
    private var lastFrameTimestamp: TimeInterval?
    private var hasCalledCompleted = false

    var onCompleted: (() -> Void)?

    init(mode: Mode) { self.mode = mode }

    func startSession() {
        isActive = true
        sessionStartDate = Date()
        displayElapsed = 0
        trackedElapsed = 0
        strictElapsed = 0
        lastFrameTimestamp = nil
        hasCalledCompleted = false
    }

    // Call from a 0.1s UI timer to refresh the display elapsed.
    func updateDisplay() {
        guard isActive, let start = sessionStartDate else { return }
        displayElapsed = -start.timeIntervalSinceNow
    }

    // Call each camera frame while in ACTIVE state.
    // isTracked: user was detected with trackable joints (pauses during grace period)
    // isEligible: user is in valid plank form — advances strict clock and triggers completion
    func tickStrict(isTracked: Bool, isEligible: Bool, timestamp: TimeInterval) {
        guard isActive else { return }
        defer { lastFrameTimestamp = timestamp }
        guard let last = lastFrameTimestamp else { return }

        let delta = max(0, min(timestamp - last, 0.1)) // cap at 100ms to handle gaps
        guard delta > 0 else { return }

        if isTracked {
            trackedElapsed += delta
        }
        if isEligible {
            strictElapsed += delta
            if !hasCalledCompleted, case .timed(let total) = mode, strictElapsed >= total {
                hasCalledCompleted = true
                onCompleted?()
            }
        }
    }

    // Freeze all clocks at the moment of stopping.
    func stopSession() {
        guard isActive else { return }
        isActive = false
        if let start = sessionStartDate {
            displayElapsed = -start.timeIntervalSinceNow
        }
        lastFrameTimestamp = nil
    }

    func reset() {
        isActive = false
        sessionStartDate = nil
        displayElapsed = 0
        trackedElapsed = 0
        strictElapsed = 0
        lastFrameTimestamp = nil
        hasCalledCompleted = false
    }

    // Progress 0.0–1.0 (only meaningful in timed mode).
    var progress: Double {
        guard case .timed(let total) = mode, total > 0 else { return 0 }
        return min(strictElapsed / total, 1.0)
    }

    // Human-readable timer string for display in the UI.
    var timerDisplay: String {
        switch mode {
        case .free:
            return formatTime(trackedElapsed)  // pauses during grace period & no detection
        case .timed(let total):
            return formatTime(max(0, total - strictElapsed))
        }
    }

    private func formatTime(_ t: TimeInterval) -> String {
        let total = Int(t)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
