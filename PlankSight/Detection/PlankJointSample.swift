import CoreGraphics

struct PlankJointSample {
    let location: CGPoint
    let confidence: Float
    let isInferred: Bool

    init(location: CGPoint, confidence: Float, isInferred: Bool = false) {
        self.location = location
        self.confidence = confidence
        self.isInferred = isInferred
    }

    var isReliable: Bool {
        confidence >= 0.4
    }
}
