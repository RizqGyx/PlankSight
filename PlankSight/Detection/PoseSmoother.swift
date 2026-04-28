import CoreGraphics
import Foundation

final class PoseSmoother {
    private var previousJoints: [PlankJointType: PlankJointSample] = [:]
    private var expectedSegmentLengths: [SegmentKey: CGFloat] = [:]
    private let smoothingFactor: CGFloat
    private let lengthStabilizationBlend: CGFloat = 0.14
    private let maxJointStepPerFrame: CGFloat = 0.08
    private let minimumConfidenceForLengthLearning: Float = 0.65
    private let maxLengthAdjustmentRatioPerFrame: CGFloat = 0.18

    private let stabilizableSegments: [(PlankJointType, PlankJointType)] = [
        (.neck, .nose), (.neck, .root),
        (.neck, .leftShoulder), (.leftShoulder, .leftElbow), (.leftElbow, .leftWrist),
        (.root, .leftHip), (.leftHip, .leftKnee), (.leftKnee, .leftAnkle),
        (.neck, .rightShoulder), (.rightShoulder, .rightElbow), (.rightElbow, .rightWrist),
        (.root, .rightHip), (.rightHip, .rightKnee), (.rightKnee, .rightAnkle)
    ]

    init(smoothingFactor: CGFloat = 0.35) {
        self.smoothingFactor = smoothingFactor
    }

    func smooth(frame: PlankPoseFrame) -> PlankPoseFrame {
        guard frame.hasPose else { reset(); return frame }

        var smoothed: [PlankJointType: PlankJointSample] = [:]
        for (joint, current) in frame.joints {
            if let previous = previousJoints[joint] {
                let stableTarget = limitedTarget(from: previous.location, to: current.location, confidence: current.confidence)
                let adaptive = adaptiveSmoothingFactor(for: joint, confidence: current.confidence)
                let location = CGPoint(
                    x: previous.location.x + (stableTarget.x - previous.location.x) * adaptive,
                    y: previous.location.y + (stableTarget.y - previous.location.y) * adaptive
                )
                smoothed[joint] = PlankJointSample(
                    location: location,
                    confidence: min(max(current.confidence, previous.confidence * 0.7), 1),
                    isInferred: current.isInferred
                )
            } else {
                smoothed[joint] = current
            }
        }

        smoothed = stabilizeSegmentLengths(in: smoothed)
        previousJoints = smoothed

        return PlankPoseFrame(timestamp: frame.timestamp, joints: smoothed, sourceImageSize: frame.sourceImageSize)
    }

    func reset() {
        previousJoints = [:]
        expectedSegmentLengths = [:]
    }

    private func adaptiveSmoothingFactor(for joint: PlankJointType, confidence: Float) -> CGFloat {
        let clamped = CGFloat(max(0, min(confidence, 1)))
        let base = max(0.16, smoothingFactor - ((1 - clamped) * 0.2))
        if joint == .nose { return min(max(base + 0.18, 0.28), 0.9) }
        return base
    }

    private func limitedTarget(from previous: CGPoint, to current: CGPoint, confidence: Float) -> CGPoint {
        let confidenceScale = CGFloat(max(0, min(confidence, 1))) + 0.35
        let allowedStep = maxJointStepPerFrame * confidenceScale
        let dx = current.x - previous.x
        let dy = current.y - previous.y
        let distance = sqrt(dx * dx + dy * dy)
        guard distance > allowedStep, distance > 0.0001 else { return current }
        let ratio = allowedStep / distance
        return CGPoint(x: previous.x + dx * ratio, y: previous.y + dy * ratio)
    }

    private func stabilizeSegmentLengths(in joints: [PlankJointType: PlankJointSample]) -> [PlankJointType: PlankJointSample] {
        var adjusted = joints
        for (from, to) in stabilizableSegments {
            guard let start = adjusted[from], let end = adjusted[to] else { continue }
            let dx = end.location.x - start.location.x
            let dy = end.location.y - start.location.y
            let currentLength = sqrt(dx * dx + dy * dy)
            guard currentLength > 0.0001 else { continue }

            let key = SegmentKey(from: from, to: to)
            let confidence = min(start.confidence, end.confidence)
            if confidence >= minimumConfidenceForLengthLearning {
                if let existing = expectedSegmentLengths[key] {
                    expectedSegmentLengths[key] = existing * 0.9 + currentLength * 0.1
                } else {
                    expectedSegmentLengths[key] = currentLength
                }
            }

            guard let expectedLength = expectedSegmentLengths[key] else { continue }
            let rawBlended = currentLength + (expectedLength - currentLength) * lengthStabilizationBlend
            let minAllowed = currentLength * (1 - maxLengthAdjustmentRatioPerFrame)
            let maxAllowed = currentLength * (1 + maxLengthAdjustmentRatioPerFrame)
            let blended = min(max(rawBlended, minAllowed), maxAllowed)
            if abs(blended - currentLength) < 0.0005 { continue }

            let nx = dx / currentLength
            let ny = dy / currentLength
            let newPoint = CGPoint(
                x: min(max(start.location.x + nx * blended, 0), 1),
                y: min(max(start.location.y + ny * blended, 0), 1)
            )
            adjusted[to] = PlankJointSample(location: newPoint, confidence: end.confidence, isInferred: end.isInferred)
        }
        return adjusted
    }
}

private struct SegmentKey: Hashable {
    let from: PlankJointType
    let to: PlankJointType
}
