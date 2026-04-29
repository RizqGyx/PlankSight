import Foundation
import CoreGraphics

final class PlankMistakeDetector {
    struct Configuration {
        var activationDuration: TimeInterval = 2.0
        var clearDuration: TimeInterval = 0.45
    }

    private let metricCalculator: PlankMetricCalculator
    private let priorityResolver: PlankMistakePriorityResolver
    private let configuration: Configuration

    private var activeMistake: PlankFormMistakeType?
    private var pendingMistake: PlankFormMistakeType?
    private var pendingStartedAt: TimeInterval?
    private var clearStartedAt: TimeInterval?

    init(
        metricCalculator: PlankMetricCalculator = .init(),
        priorityResolver: PlankMistakePriorityResolver = .init(),
        configuration: Configuration = .init()
    ) {
        self.metricCalculator = metricCalculator
        self.priorityResolver = priorityResolver
        self.configuration = configuration
    }

    func reset() {
        activeMistake = nil
        pendingMistake = nil
        pendingStartedAt = nil
        clearStartedAt = nil
    }

    func evaluate(
        frame: PlankPoseFrame,
        activeSideLabel: String?,
        calibrationCase: PlankCalibrationCase?,
        now: TimeInterval
    ) -> PlankFeedbackFrame {
        let metrics = metricCalculator.calculate(frame: frame, activeSideLabel: activeSideLabel)
        let profile = PlankThresholdProfile.forCalibrationCase(calibrationCase)

        var scores: [PlankFormMistakeType: CGFloat] = [:]
        if metrics.averageTrackedConfidence >= profile.minimumAverageConfidence {
            if let hipDeviation = metrics.hipDeviationFromBodyLine {
                let adjusted = profile.invertHipDirection ? -hipDeviation : hipDeviation
                if adjusted < -profile.hipLowTolerance {
                    scores[.hipsTooLow] = abs(adjusted) - profile.hipLowTolerance
                } else if adjusted > profile.hipHighTolerance {
                    scores[.hipsTooHigh] = adjusted - profile.hipHighTolerance
                }
            }
            if let kneeAngle = metrics.kneeAngleDegrees, kneeAngle < profile.kneeMinimumAngle {
                scores[.kneeBent] = profile.kneeMinimumAngle - kneeAngle
            }
            if let noseDelta = metrics.noseToShoulderDelta {
                if profile.headDropUsesGreaterThan {
                    if noseDelta > profile.headDropThreshold {
                        scores[.headDropped] = noseDelta - profile.headDropThreshold
                    }
                } else if noseDelta < profile.headDropThreshold {
                    scores[.headDropped] = profile.headDropThreshold - noseDelta
                }
            }
            if let elbowAngle = metrics.elbowAngleDegrees,
               !profile.elbowPreferredRange.contains(elbowAngle) {
                if elbowAngle < profile.elbowPreferredRange.lowerBound {
                    scores[.elbowMisaligned] = profile.elbowPreferredRange.lowerBound - elbowAngle
                } else {
                    scores[.elbowMisaligned] = elbowAngle - profile.elbowPreferredRange.upperBound
                }
            }
        }

        let rawPrimary = priorityResolver.resolvePrimaryMistake(from: scores, minimumScore: profile.minimumMistakeScore)
        let stablePrimary = resolveStablePrimary(rawPrimary: rawPrimary, now: now)

        return PlankFeedbackFrame(
            timestamp: frame.timestamp,
            calibrationCase: calibrationCase,
            metrics: metrics,
            mistakeScores: scores,
            primaryMistake: stablePrimary
        )
    }

    private func resolveStablePrimary(rawPrimary: PlankFormMistakeType?, now: TimeInterval) -> PlankFormMistakeType? {
        guard let rawPrimary else {
            pendingMistake = nil
            pendingStartedAt = nil

            if activeMistake != nil {
                if clearStartedAt == nil { clearStartedAt = now }
                let clearElapsed = max(0, now - (clearStartedAt ?? now))
                if clearElapsed >= configuration.clearDuration {
                    activeMistake = nil
                    clearStartedAt = nil
                }
            }
            return activeMistake
        }

        clearStartedAt = nil

        if activeMistake == rawPrimary {
            pendingMistake = nil
            pendingStartedAt = nil
            return activeMistake
        }

        if pendingMistake == rawPrimary {
            let elapsed = max(0, now - (pendingStartedAt ?? now))
            if elapsed >= configuration.activationDuration {
                activeMistake = rawPrimary
                pendingMistake = nil
                pendingStartedAt = nil
            }
        } else {
            pendingMistake = rawPrimary
            pendingStartedAt = now
        }

        return activeMistake
    }
}
