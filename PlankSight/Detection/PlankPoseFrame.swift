import CoreGraphics
import Foundation

struct PlankPoseFrame {
    let timestamp: TimeInterval
    let joints: [PlankJointType: PlankJointSample]
    let sourceImageSize: CGSize

    var hasPose: Bool { !joints.isEmpty }
    var trackedJointCount: Int { joints.count }

    var totalConfidence: Float {
        joints.values.reduce(0) { $0 + $1.confidence }
    }

    var averageConfidence: Float {
        guard trackedJointCount > 0 else { return 0 }
        return totalConfidence / Float(trackedJointCount)
    }

    func sample(for joint: PlankJointType) -> PlankJointSample? {
        joints[joint]
    }

    func point(for joint: PlankJointType) -> CGPoint? {
        joints[joint]?.location
    }

    func hasRequiredJoints(_ required: Set<PlankJointType>) -> Bool {
        required.allSatisfy { joints[$0] != nil }
    }

    static let empty = PlankPoseFrame(timestamp: 0, joints: [:], sourceImageSize: .zero)
}
