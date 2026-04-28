import Foundation

enum PlankTrackingState: Equatable {
    case idle
    case candidate(candidateStartedAt: TimeInterval, stableTrackableFrames: Int)
    case active(activeStartedAt: TimeInterval, lastTrackableAt: TimeInterval)
    case ended(startedAt: TimeInterval, endedAt: TimeInterval, duration: TimeInterval)

    var isRunning: Bool {
        if case .active = self { return true }
        return false
    }
}
