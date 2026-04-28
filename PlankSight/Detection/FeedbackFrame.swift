import Foundation
import CoreGraphics

struct PlankFeedbackFrame {
    let timestamp: TimeInterval
    let calibrationCase: PlankCalibrationCase?
    let metrics: PlankJointMetrics
    let mistakeScores: [PlankFormMistakeType: CGFloat]
    let primaryMistake: PlankFormMistakeType?

    var primaryMistakeText: String? { primaryMistake?.displayText }

    static let empty = PlankFeedbackFrame(
        timestamp: 0,
        calibrationCase: nil,
        metrics: .empty,
        mistakeScores: [:],
        primaryMistake: nil
    )
}
