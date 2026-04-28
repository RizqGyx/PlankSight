import Foundation
import CoreGraphics

struct PlankJointMetrics {
    let activeSideLabel: String?
    let shoulder: PlankJointSample?
    let hip: PlankJointSample?
    let knee: PlankJointSample?
    let ankle: PlankJointSample?
    let elbow: PlankJointSample?
    let wrist: PlankJointSample?
    let nose: PlankJointSample?
    let neck: PlankJointSample?

    let shoulderToAnkleSlopeDegrees: CGFloat?
    let hipDeviationFromBodyLine: CGFloat?
    let kneeAngleDegrees: CGFloat?
    let elbowAngleDegrees: CGFloat?
    let noseToShoulderDelta: CGFloat?
    let averageTrackedConfidence: Float

    var hasMainPostureMetrics: Bool {
        hipDeviationFromBodyLine != nil && kneeAngleDegrees != nil && noseToShoulderDelta != nil
    }

    static let empty = PlankJointMetrics(
        activeSideLabel: nil,
        shoulder: nil, hip: nil, knee: nil, ankle: nil,
        elbow: nil, wrist: nil, nose: nil, neck: nil,
        shoulderToAnkleSlopeDegrees: nil,
        hipDeviationFromBodyLine: nil,
        kneeAngleDegrees: nil,
        elbowAngleDegrees: nil,
        noseToShoulderDelta: nil,
        averageTrackedConfidence: 0
    )
}
