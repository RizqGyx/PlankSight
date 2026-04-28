import Foundation
import CoreGraphics

struct PlankMetricCalculator {
    private let minimumReliableConfidence: Float

    init(minimumReliableConfidence: Float = 0.28) {
        self.minimumReliableConfidence = minimumReliableConfidence
    }

    func calculate(frame: PlankPoseFrame, activeSideLabel: String?) -> PlankJointMetrics {
        let side = resolveSide(frame: frame, activeSideLabel: activeSideLabel)

        let shoulder = sample(for: side.shoulder, in: frame)
        let hip = sample(for: side.hip, in: frame)
        let knee = sample(for: side.knee, in: frame)
        let ankle = sample(for: side.ankle, in: frame)
        let elbow = sample(for: side.elbow, in: frame)
        let wrist = sample(for: side.wrist, in: frame)
        let nose = sample(for: .nose, in: frame)
        let neck = sample(for: .neck, in: frame)

        let bodyAxes = makeBodyAxes(shoulder: shoulder?.location, ankle: ankle?.location)

        let trackedSamples = [shoulder, hip, knee, ankle, elbow, wrist, nose, neck].compactMap { $0 }
        let averageConfidence: Float = {
            guard !trackedSamples.isEmpty else { return 0 }
            return trackedSamples.reduce(Float(0)) { $0 + $1.confidence } / Float(trackedSamples.count)
        }()

        return PlankJointMetrics(
            activeSideLabel: side.label,
            shoulder: shoulder, hip: hip, knee: knee, ankle: ankle,
            elbow: elbow, wrist: wrist, nose: nose, neck: neck,
            shoulderToAnkleSlopeDegrees: slopeDegrees(fromAxes: bodyAxes),
            hipDeviationFromBodyLine: normalizedLateralDistance(point: hip?.location, axes: bodyAxes),
            kneeAngleDegrees: angleDegrees(a: hip?.location, vertex: knee?.location, c: ankle?.location),
            elbowAngleDegrees: angleDegrees(a: shoulder?.location, vertex: elbow?.location, c: wrist?.location),
            noseToShoulderDelta: normalizedLateralDistance(point: nose?.location, axes: bodyAxes),
            averageTrackedConfidence: averageConfidence
        )
    }

    private func sample(for joint: PlankJointType, in frame: PlankPoseFrame) -> PlankJointSample? {
        guard let s = frame.sample(for: joint), s.confidence >= minimumReliableConfidence else { return nil }
        return s
    }

    private func slopeDegrees(fromAxes axes: BodyAxes?) -> CGFloat? {
        guard let axes else { return nil }
        let rawAngle = abs(atan2(axes.longitudinal.dy, axes.longitudinal.dx) * 180 / .pi)
        return min(rawAngle, abs(180 - rawAngle))
    }

    private func normalizedLateralDistance(point: CGPoint?, axes: BodyAxes?) -> CGFloat? {
        guard let point, let axes else { return nil }
        let relative = CGVector(dx: point.x - axes.origin.x, dy: point.y - axes.origin.y)
        let lateral = relative.dx * axes.normal.dx + relative.dy * axes.normal.dy
        return lateral / axes.length
    }

    private func makeBodyAxes(shoulder: CGPoint?, ankle: CGPoint?) -> BodyAxes? {
        guard let shoulder, let ankle else { return nil }
        let line = CGVector(dx: ankle.x - shoulder.x, dy: ankle.y - shoulder.y)
        let length = sqrt(line.dx * line.dx + line.dy * line.dy)
        guard length > 0.0001 else { return nil }
        let longitudinal = CGVector(dx: line.dx / length, dy: line.dy / length)
        var normal = CGVector(dx: -longitudinal.dy, dy: longitudinal.dx)
        if normal.dy < 0 { normal = CGVector(dx: -normal.dx, dy: -normal.dy) }
        return BodyAxes(origin: shoulder, longitudinal: longitudinal, normal: normal, length: length)
    }

    private func angleDegrees(a: CGPoint?, vertex: CGPoint?, c: CGPoint?) -> CGFloat? {
        guard let a, let vertex, let c else { return nil }
        let v1 = CGVector(dx: a.x - vertex.x, dy: a.y - vertex.y)
        let v2 = CGVector(dx: c.x - vertex.x, dy: c.y - vertex.y)
        let m1 = sqrt(v1.dx * v1.dx + v1.dy * v1.dy)
        let m2 = sqrt(v2.dx * v2.dx + v2.dy * v2.dy)
        guard m1 > 0.0001, m2 > 0.0001 else { return nil }
        let dot = v1.dx * v2.dx + v1.dy * v2.dy
        let cosine = max(-1.0, min(1.0, dot / (m1 * m2)))
        return acos(cosine) * 180 / .pi
    }

    private func resolveSide(frame: PlankPoseFrame, activeSideLabel: String?) -> SideJointSet {
        switch activeSideLabel {
        case "left": return .left
        case "right": return .right
        default:
            let leftScore = sideScore(frame: frame, side: .left)
            let rightScore = sideScore(frame: frame, side: .right)
            return leftScore >= rightScore ? .left : .right
        }
    }

    private func sideScore(frame: PlankPoseFrame, side: SideJointSet) -> Float {
        side.trackChain.reduce(Float(0)) { result, joint in
            guard let sample = frame.sample(for: joint) else { return result }
            return result + sample.confidence
        }
    }
}

private struct BodyAxes {
    let origin: CGPoint
    let longitudinal: CGVector
    let normal: CGVector
    let length: CGFloat
}

private struct SideJointSet {
    let label: String
    let shoulder: PlankJointType
    let hip: PlankJointType
    let knee: PlankJointType
    let ankle: PlankJointType
    let elbow: PlankJointType
    let wrist: PlankJointType

    var trackChain: [PlankJointType] { [shoulder, hip, knee, ankle] }

    static let left = SideJointSet(
        label: "left",
        shoulder: .leftShoulder, hip: .leftHip, knee: .leftKnee, ankle: .leftAnkle,
        elbow: .leftElbow, wrist: .leftWrist
    )
    static let right = SideJointSet(
        label: "right",
        shoulder: .rightShoulder, hip: .rightHip, knee: .rightKnee, ankle: .rightAnkle,
        elbow: .rightElbow, wrist: .rightWrist
    )
}
