import AVFoundation
import CoreGraphics
import Foundation
import Vision

final class PoseFrameBuilder {
    private let minimumConfidence: VNConfidence

    init(minimumConfidence: VNConfidence) {
        self.minimumConfidence = minimumConfidence
    }

    func buildFrame(
        from observation: VNHumanBodyPoseObservation,
        sampleBuffer: CMSampleBuffer
    ) -> PlankPoseFrame? {
        do {
            let recognizedPoints = try observation.recognizedPoints(.all)
            var joints: [PlankJointType: PlankJointSample] = [:]

            for jointType in PlankJointType.allCases {
                guard let jointName = jointType.visionJointName else { continue }
                guard let point = recognizedPoints[jointName] else { continue }
                guard point.confidence >= minimumConfidence else { continue }

                joints[jointType] = PlankJointSample(
                    location: point.location,
                    confidence: point.confidence
                )
            }

            guard !joints.isEmpty else { return nil }

            return PlankPoseFrame(
                timestamp: validatedTimestamp(from: sampleBuffer),
                joints: joints,
                sourceImageSize: sourceImageSize(from: sampleBuffer)
            )
        } catch {
            return nil
        }
    }

    private func validatedTimestamp(from sampleBuffer: CMSampleBuffer) -> TimeInterval {
        let seconds = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        guard seconds.isFinite, seconds > 0 else { return Date().timeIntervalSince1970 }
        return seconds
    }

    private func sourceImageSize(from sampleBuffer: CMSampleBuffer) -> CGSize {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return .zero }
        let width = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let height = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        return CGSize(width: min(width, height), height: max(width, height))
    }
}
