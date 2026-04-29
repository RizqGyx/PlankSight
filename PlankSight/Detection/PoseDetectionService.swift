import AVFoundation
import ImageIO
import Vision

final class PoseDetectionService {
    private let frameBuilder: PoseFrameBuilder
    private let preferredOrientation: CGImagePropertyOrientation = .up

    init(minimumConfidence: VNConfidence = 0.3) {
        self.frameBuilder = PoseFrameBuilder(minimumConfidence: minimumConfidence)
    }

    func detectPose(in sampleBuffer: CMSampleBuffer) -> PlankPoseFrame? {
        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(
            cmSampleBuffer: sampleBuffer,
            orientation: preferredOrientation,
            options: [:]
        )
        do {
            try handler.perform([request])
            guard let observation = request.results?.first else { return nil }
            return frameBuilder.buildFrame(from: observation, sampleBuffer: sampleBuffer)
        } catch {
            return nil
        }
    }
}
