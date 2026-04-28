import Foundation

// Frame-based state machine: IDLE → CANDIDATE → ACTIVE → ENDED
// Transitions are driven by camera frame trackability, not time ticks.
final class StartStopDetector {
    private let candidateThreshold = 3          // consecutive trackable frames to enter candidate
    private let activeThreshold = 8             // total trackable frames (from candidate start) to activate
    private let candidateMissingTolerance = 2   // consecutive missing frames allowed in candidate
    private let activeGracePeriod: TimeInterval = 2.0  // seconds without tracking before ENDED

    private(set) var state: PlankTrackingState = .idle
    private var consecutiveTrackable = 0
    private var consecutiveMissing = 0

    @discardableResult
    func update(isTrackable: Bool, timestamp: TimeInterval) -> PlankTrackingState {
        switch state {
        case .idle:
            if isTrackable {
                consecutiveTrackable += 1
                consecutiveMissing = 0
                if consecutiveTrackable >= candidateThreshold {
                    state = .candidate(candidateStartedAt: timestamp, stableTrackableFrames: consecutiveTrackable)
                }
            } else {
                consecutiveTrackable = 0
            }

        case .candidate(let startedAt, let stableFrames):
            if isTrackable {
                consecutiveMissing = 0
                let newStable = stableFrames + 1
                if newStable >= activeThreshold {
                    state = .active(activeStartedAt: timestamp, lastTrackableAt: timestamp)
                    consecutiveTrackable = 0
                } else {
                    state = .candidate(candidateStartedAt: startedAt, stableTrackableFrames: newStable)
                }
            } else {
                consecutiveMissing += 1
                if consecutiveMissing > candidateMissingTolerance {
                    state = .idle
                    consecutiveTrackable = 0
                    consecutiveMissing = 0
                }
            }

        case .active(let startedAt, let lastTrackableAt):
            if isTrackable {
                consecutiveMissing = 0
                state = .active(activeStartedAt: startedAt, lastTrackableAt: timestamp)
            } else {
                let gap = timestamp - lastTrackableAt
                if gap > activeGracePeriod {
                    state = .ended(
                        startedAt: startedAt,
                        endedAt: lastTrackableAt,
                        duration: lastTrackableAt - startedAt
                    )
                }
                // Within grace period: stay active, timer still runs
            }

        case .ended:
            // ViewModel navigates away on ENDED — no new session from here
            break
        }

        return state
    }

    func reset() {
        state = .idle
        consecutiveTrackable = 0
        consecutiveMissing = 0
    }
}
