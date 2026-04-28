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
        minimumAverageConfidence: 0.36,
        hipLowTolerance: 0.050, hipHighTolerance: 0.050,
        invertHipDirection: false,
        kneeMinimumAngle: 167,
        headDropThreshold: 0.060,
        headDropUsesGreaterThan: false,
        elbowPreferredRange: 74...104,
        minimumMistakeScore: 0.008
    )

    static func forCalibrationCase(_ calibrationCase: PlankCalibrationCase?) -> PlankThresholdProfile {
        guard let calibrationCase else { return defaultProfile }
        switch calibrationCase {
        case .landscapeTiltLeftPlankLeft, .landscapeTiltRightPlankRight:
            return PlankThresholdProfile(
                minimumAverageConfidence: defaultProfile.minimumAverageConfidence,
                hipLowTolerance: 0.034, hipHighTolerance: 0.034,
                invertHipDirection: true,
                kneeMinimumAngle: 170,
                headDropThreshold: 0.165,
                headDropUsesGreaterThan: true,
                elbowPreferredRange: 74...96,
                minimumMistakeScore: defaultProfile.minimumMistakeScore
            )
        case .portraitPlankLeft, .portraitPlankRight:
            return PlankThresholdProfile(
                minimumAverageConfidence: defaultProfile.minimumAverageConfidence - 0.02,
                hipLowTolerance: 0.032, hipHighTolerance: 0.032,
                invertHipDirection: false,
                kneeMinimumAngle: 170,
                headDropThreshold: 0.180,
                headDropUsesGreaterThan: true,
                elbowPreferredRange: 52...96,
                minimumMistakeScore: defaultProfile.minimumMistakeScore
            )
        }
    }
}
