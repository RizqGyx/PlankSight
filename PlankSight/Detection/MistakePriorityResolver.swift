import Foundation
import CoreGraphics

struct PlankMistakePriorityResolver {
    private let priorityOrder: [PlankFormMistakeType] = [
        .hipsTooLow, .hipsTooHigh, .kneeBent, .headDropped, .elbowMisaligned
    ]

    func resolvePrimaryMistake(
        from scores: [PlankFormMistakeType: CGFloat],
        minimumScore: CGFloat
    ) -> PlankFormMistakeType? {
        for mistakeType in priorityOrder {
            guard let score = scores[mistakeType], score >= minimumScore else { continue }
            return mistakeType
        }
        return nil
    }
}
