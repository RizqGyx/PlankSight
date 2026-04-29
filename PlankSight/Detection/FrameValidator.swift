import Foundation
import CoreGraphics

struct PoseFrameValidator {
    private struct StartGateConfiguration {
        let confidenceSlack: Float = 0.03
        let portraitHipToleranceExtra: CGFloat = 0.060
        let landscapeHipToleranceExtra: CGFloat = 0.200
        let fallbackHipToleranceExtra: CGFloat = 0.110
        let hardKneeAngleSlack: CGFloat = 25
        let maxBodySlopeDegrees: CGFloat = 30
        let minVerticalBodySlopeDegrees: CGFloat = 62
        let elbowLowerBound: CGFloat = 42
        let elbowUpperBound: CGFloat = 155
        let elbowRangePadding: CGFloat = 40
    }

    var minimumJointConfidence: Float = 0.27
    private let metricCalculator = PlankMetricCalculator(minimumReliableConfidence: 0.28)
    private let startGateConfiguration = StartGateConfiguration()

    func isFrameTrackable(_ frame: PlankPoseFrame) -> Bool {
        guard frame.hasPose else { return false }
        let hasCore = hasReliableJoint(.neck, in: frame) && hasReliableJoint(.root, in: frame)
        guard hasCore else { return false }
        let hasLeftSide = hasReliableChain([.leftShoulder, .leftHip, .leftKnee, .leftAnkle], in: frame)
        let hasRightSide = hasReliableChain([.rightShoulder, .rightHip, .rightKnee, .rightAnkle], in: frame)
        return hasLeftSide || hasRightSide
    }

    func hasHeadReference(_ frame: PlankPoseFrame) -> Bool {
        hasReliableJoint(.nose, in: frame)
    }

    func isFrameEligibleForPlankTimer(
        _ frame: PlankPoseFrame,
        activeSideLabel: String?,
        calibrationCase: PlankCalibrationCase?
    ) -> Bool {
        guard isFrameTrackable(frame) else { return false }

        let metrics = metricCalculator.calculate(frame: frame, activeSideLabel: activeSideLabel)
        let profile = PlankThresholdProfile.forCalibrationCase(calibrationCase)

        let minimumConfidence = max(0, profile.minimumAverageConfidence - startGateConfiguration.confidenceSlack)
        guard metrics.averageTrackedConfidence >= minimumConfidence else { return false }

        guard
            let hipDeviation = metrics.hipDeviationFromBodyLine,
            let slope = metrics.shoulderToAnkleSlopeDegrees,
            let elbowAngle = metrics.elbowAngleDegrees
        else { return false }

        let acceptsHorizontal = slope <= startGateConfiguration.maxBodySlopeDegrees
        let acceptsVertical = slope >= startGateConfiguration.minVerticalBodySlopeDegrees
        guard acceptsHorizontal || acceptsVertical else { return false }

        let adjustedHipDeviation = profile.invertHipDirection ? -hipDeviation : hipDeviation
        let hipToleranceExtra: CGFloat
        switch calibrationCase {
        case .landscapeTiltLeftPlankLeft, .landscapeTiltRightPlankRight:
            hipToleranceExtra = startGateConfiguration.landscapeHipToleranceExtra
        case .portraitPlankLeft, .portraitPlankRight:
            hipToleranceExtra = startGateConfiguration.portraitHipToleranceExtra
        case nil:
            hipToleranceExtra = startGateConfiguration.fallbackHipToleranceExtra
        }
        let allowedHipDeviation = max(profile.hipLowTolerance, profile.hipHighTolerance) + hipToleranceExtra
        guard adjustedHipDeviation >= -allowedHipDeviation,
              adjustedHipDeviation <= allowedHipDeviation else { return false }

        if let kneeAngle = metrics.kneeAngleDegrees {
            let minimumKneeAngle = profile.kneeMinimumAngle - startGateConfiguration.hardKneeAngleSlack
            guard kneeAngle >= minimumKneeAngle else { return false }
        }

        let lower = max(
            startGateConfiguration.elbowLowerBound,
            profile.elbowPreferredRange.lowerBound - startGateConfiguration.elbowRangePadding
        )
        let upper = min(
            startGateConfiguration.elbowUpperBound,
            profile.elbowPreferredRange.upperBound + startGateConfiguration.elbowRangePadding
        )
        guard (lower...upper).contains(elbowAngle) else { return false }

        return true
    }

    private func hasReliableChain(_ joints: [PlankJointType], in frame: PlankPoseFrame) -> Bool {
        joints.allSatisfy { hasReliableJoint($0, in: frame) }
    }

    private func hasReliableJoint(_ joint: PlankJointType, in frame: PlankPoseFrame) -> Bool {
        guard let sample = frame.sample(for: joint) else { return false }
        let x = sample.location.x
        let y = sample.location.y
        return (0...1).contains(x) && (0...1).contains(y) && sample.confidence >= minimumJointConfidence
    }
}
