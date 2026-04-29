import Foundation
import CoreGraphics

struct PlankThresholdProfile {
    let minimumAverageConfidence: Float
    let hipLowTolerance: CGFloat
    let hipHighTolerance: CGFloat
    let invertHipDirection: Bool
    let kneeMinimumAngle: CGFloat
    let headDropThreshold: CGFloat
    let headDropUsesGreaterThan: Bool
    let elbowPreferredRange: ClosedRange<CGFloat>
    let minimumMistakeScore: CGFloat

    static let defaultProfile = PlankThresholdProfile(
        minimumAverageConfidence: 0.28,
        hipLowTolerance: 0.075, hipHighTolerance: 0.075,
        invertHipDirection: false,
        kneeMinimumAngle: 158,
        headDropThreshold: 0.040,
        headDropUsesGreaterThan: false,
        elbowPreferredRange: 62...116,
        minimumMistakeScore: 0.012
    )

    static func forCalibrationCase(_ calibrationCase: PlankCalibrationCase?) -> PlankThresholdProfile {
        guard let calibrationCase else { return defaultProfile }
        switch calibrationCase {
        case .landscapeTiltLeftPlankLeft, .landscapeTiltRightPlankRight:
            return PlankThresholdProfile(
                minimumAverageConfidence: defaultProfile.minimumAverageConfidence,
                hipLowTolerance: 0.052, hipHighTolerance: 0.052,
                invertHipDirection: true,
                kneeMinimumAngle: 162,
                headDropThreshold: 0.180,
                headDropUsesGreaterThan: true,
                elbowPreferredRange: 62...108,
                minimumMistakeScore: defaultProfile.minimumMistakeScore
            )
        case .portraitPlankLeft, .portraitPlankRight:
            return PlankThresholdProfile(
                minimumAverageConfidence: defaultProfile.minimumAverageConfidence - 0.02,
                hipLowTolerance: 0.050, hipHighTolerance: 0.050,
                invertHipDirection: false,
                kneeMinimumAngle: 162,
                headDropThreshold: 0.200,
                headDropUsesGreaterThan: true,
                elbowPreferredRange: 45...108,
                minimumMistakeScore: defaultProfile.minimumMistakeScore
            )
        }
    }
}
