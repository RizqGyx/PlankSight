import CoreGraphics
import Foundation

final class PoseSideNormalizer {
    private enum Side {
        case left, right
        var label: String { self == .left ? "left" : "right" }
    }

    private let chainJointMinimumConfidence: Float = 0.2
    private let sidePresenceScoreThreshold: Float = 1.0
    private let sideSwitchConfirmationFrames = 5
    private let activeSideMissingFramesToUnlock = 8

    private let leftChain: [PlankJointType] = [.leftShoulder, .leftHip, .leftKnee, .leftAnkle]
    private let rightChain: [PlankJointType] = [.rightShoulder, .rightHip, .rightKnee, .rightAnkle]
    private let sharedJoints: Set<PlankJointType> = [.nose, .neck, .root]

    private var activeSide: Side?
    private var pendingSide: Side?
    private var pendingSwitchCount = 0
    private var missingActiveSideCount = 0

    var activeSideLabel: String? { activeSide?.label }

    func normalize(frame: PlankPoseFrame) -> PlankPoseFrame {
        guard frame.hasPose else { reset(); return frame }

        let leftScore = score(for: leftChain, joints: frame.joints)
        let rightScore = score(for: rightChain, joints: frame.joints)
        let candidate = candidateSide(leftScore: leftScore, rightScore: rightScore)

        resolveActiveSide(candidate: candidate, leftScore: leftScore, rightScore: rightScore)

        guard let activeSide else { return frame }

        let filteredJoints = frame.joints.filter { joint, _ in
            sharedJoints.contains(joint) || belongsToActiveSide(joint: joint, side: activeSide)
        }

        return PlankPoseFrame(timestamp: frame.timestamp, joints: filteredJoints, sourceImageSize: frame.sourceImageSize)
    }

    func reset() {
        activeSide = nil
        pendingSide = nil
        pendingSwitchCount = 0
        missingActiveSideCount = 0
    }

    private func score(for chain: [PlankJointType], joints: [PlankJointType: PlankJointSample]) -> Float {
        chain.reduce(0) { result, joint in
            guard let sample = joints[joint], sample.confidence >= chainJointMinimumConfidence else { return result }
            return result + sample.confidence
        }
    }

    private func candidateSide(leftScore: Float, rightScore: Float) -> Side? {
        let maxScore = max(leftScore, rightScore)
        guard maxScore >= sidePresenceScoreThreshold else { return nil }
        if abs(leftScore - rightScore) < 0.12 {
            return activeSide ?? (leftScore >= rightScore ? .left : .right)
        }
        return leftScore > rightScore ? .left : .right
    }

    private func resolveActiveSide(candidate: Side?, leftScore: Float, rightScore: Float) {
        if let activeSide {
            let activeScore = activeSide == .left ? leftScore : rightScore
            if activeScore < sidePresenceScoreThreshold {
                missingActiveSideCount += 1
            } else {
                missingActiveSideCount = 0
            }
            if missingActiveSideCount >= activeSideMissingFramesToUnlock {
                self.activeSide = nil
                pendingSide = nil
                pendingSwitchCount = 0
                missingActiveSideCount = 0
            }
        }

        guard let candidate else { pendingSide = nil; pendingSwitchCount = 0; return }
        guard let activeSide else { self.activeSide = candidate; pendingSide = nil; pendingSwitchCount = 0; return }
        guard candidate != activeSide else { pendingSide = nil; pendingSwitchCount = 0; return }

        if pendingSide == candidate {
            pendingSwitchCount += 1
        } else {
            pendingSide = candidate
            pendingSwitchCount = 1
        }

        if pendingSwitchCount >= sideSwitchConfirmationFrames {
            self.activeSide = candidate
            pendingSide = nil
            pendingSwitchCount = 0
            missingActiveSideCount = 0
        }
    }

    private func belongsToActiveSide(joint: PlankJointType, side: Side) -> Bool {
        switch (side, joint) {
        case (.left, .leftShoulder), (.left, .leftElbow), (.left, .leftWrist),
             (.left, .leftHip), (.left, .leftKnee), (.left, .leftAnkle): return true
        case (.right, .rightShoulder), (.right, .rightElbow), (.right, .rightWrist),
             (.right, .rightHip), (.right, .rightKnee), (.right, .rightAnkle): return true
        default: return false
        }
    }
}
