import AVFoundation
import SwiftUI
import UIKit

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    let poseFrame: PlankPoseFrame
    let isUsingFrontCamera: Bool

    init(
        session: AVCaptureSession,
        poseFrame: PlankPoseFrame = .empty,
        isUsingFrontCamera: Bool = false
    ) {
        self.session = session
        self.poseFrame = poseFrame
        self.isUsingFrontCamera = isUsingFrontCamera
    }

    func makeUIView(context: Context) -> PlankPreviewView {
        let view = PlankPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.setUsingFrontCamera(isUsingFrontCamera)
        return view
    }

    func updateUIView(_ uiView: PlankPreviewView, context: Context) {
        uiView.videoPreviewLayer.session = session
        uiView.setUsingFrontCamera(isUsingFrontCamera)
        uiView.renderOverlay(poseFrame: poseFrame)
    }
}

final class PlankPreviewView: UIView {
    private let segmentLayer = CAShapeLayer()
    private let jointFillLayer = CAShapeLayer()
    private let jointStrokeLayer = CAShapeLayer()
    private var currentPoseFrame: PlankPoseFrame = .empty
    private var isUsingFrontCamera = false
    private var currentOrientation: UIDeviceOrientation = UIDevice.current.orientation
    // Keeps the last known landscape orientation so skeleton stays stable
    // during brief transitions where orientation becomes .unknown or .portrait.
    private var lastReliableLandscapeOrientation: UIDeviceOrientation = .landscapeLeft

    private var shouldFlipHorizontally: Bool { !isUsingFrontCamera }

    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected AVCaptureVideoPreviewLayer")
        }
        return layer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureOverlayLayers()
        startObservingOrientation()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureOverlayLayers()
        startObservingOrientation()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func startObservingOrientation() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOrientationChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    @objc private func handleOrientationChange() {
        currentOrientation = UIDevice.current.orientation
        if currentOrientation.isLandscape {
            lastReliableLandscapeOrientation = currentOrientation
        }
        updatePreviewOrientation()
        redrawOverlay()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        segmentLayer.frame = bounds
        jointFillLayer.frame = bounds
        jointStrokeLayer.frame = bounds
        updatePreviewOrientation()
        redrawOverlay()
    }

    func renderOverlay(poseFrame: PlankPoseFrame) {
        currentPoseFrame = poseFrame
        redrawOverlay()
    }

    func setUsingFrontCamera(_ isUsingFrontCamera: Bool) {
        self.isUsingFrontCamera = isUsingFrontCamera
        guard let connection = videoPreviewLayer.connection else { return }
        updatePreviewOrientation(connection: connection)
        if connection.isVideoMirroringSupported {
            if connection.automaticallyAdjustsVideoMirroring {
                connection.automaticallyAdjustsVideoMirroring = false
            }
            if connection.isVideoMirrored != isUsingFrontCamera {
                connection.isVideoMirrored = isUsingFrontCamera
            }
        }
    }

    private func updatePreviewOrientation(connection: AVCaptureConnection? = nil) {
        let conn = connection ?? videoPreviewLayer.connection
        guard let conn else { return }

        // The app UI is always forced to landscapeRight (home button on left =
        // UIDeviceOrientation.landscapeLeft). When the device is physically held in
        // landscapeRight (home button on right), UIKit applies a 180° window transform
        // to compensate, but AVCaptureVideoPreviewLayer does NOT follow that transform
        // automatically. We detect the physical orientation and apply 180° manually.
        let physical = UIDevice.current.orientation
        let angle: CGFloat = (physical == .landscapeRight) ? 180 : 0

        if #available(iOS 17.0, *) {
            if conn.isVideoRotationAngleSupported(angle) {
                conn.videoRotationAngle = angle
            }
        } else {
            if conn.isVideoOrientationSupported {
                conn.videoOrientation = (physical == .landscapeRight) ? .landscapeLeft : .landscapeRight
            }
        }
    }

    private func configureOverlayLayers() {
        segmentLayer.fillColor = UIColor.clear.cgColor
        segmentLayer.strokeColor = UIColor.white.withAlphaComponent(0.95).cgColor
        segmentLayer.lineWidth = 3.25
        segmentLayer.lineCap = .round
        segmentLayer.lineJoin = .round

        jointFillLayer.fillColor = UIColor.white.withAlphaComponent(0.92).cgColor
        jointStrokeLayer.fillColor = UIColor.clear.cgColor
        jointStrokeLayer.strokeColor = UIColor.black.withAlphaComponent(0.8).cgColor
        jointStrokeLayer.lineWidth = 1.25

        videoPreviewLayer.addSublayer(segmentLayer)
        videoPreviewLayer.addSublayer(jointFillLayer)
        videoPreviewLayer.addSublayer(jointStrokeLayer)
    }

    private func redrawOverlay() {
        guard bounds.width > 0, bounds.height > 0 else {
            segmentLayer.path = nil; jointFillLayer.path = nil; jointStrokeLayer.path = nil
            return
        }
        guard currentPoseFrame.hasPose else {
            segmentLayer.path = nil; jointFillLayer.path = nil; jointStrokeLayer.path = nil
            return
        }

        let segmentPath = UIBezierPath()
        for (startJoint, endJoint) in PlankSkeletonMap.connections {
            guard
                let startPoint = currentPoseFrame.point(for: startJoint),
                let endPoint = currentPoseFrame.point(for: endJoint),
                let startLayer = layerPoint(fromVisionPoint: startPoint),
                let endLayer = layerPoint(fromVisionPoint: endPoint)
            else { continue }
            segmentPath.move(to: startLayer)
            segmentPath.addLine(to: endLayer)
        }
        segmentLayer.path = segmentPath.cgPath

        let jointFillPath = UIBezierPath()
        let jointStrokePath = UIBezierPath()
        for (_, sample) in currentPoseFrame.joints {
            guard let point = layerPoint(fromVisionPoint: sample.location) else { continue }
            let confidenceScale = CGFloat(max(0.15, min(sample.confidence, 1)))
            let radius = 4.5 + (confidenceScale * 3.5)
            let rect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
            let circle = UIBezierPath(ovalIn: rect)
            jointFillPath.append(circle)
            jointStrokePath.append(circle)
        }
        jointFillLayer.path = jointFillPath.cgPath
        jointStrokeLayer.path = jointStrokePath.cgPath
    }

    private func layerPoint(fromVisionPoint point: CGPoint) -> CGPoint? {
        guard point.x.isFinite, point.y.isFinite else { return nil }
        // Use the current orientation if it is landscape; fall back to the last
        // reliable landscape orientation during brief transitions (.unknown, .portrait, etc.)
        // to prevent the skeleton from stretching while the device is mid-rotation.
        let orient = currentOrientation.isLandscape ? currentOrientation : lastReliableLandscapeOrientation
        let capturePoint: CGPoint
        if orient == .landscapeLeft {
            capturePoint = CGPoint(x: point.y, y: 1 - point.x)
        } else {
            capturePoint = CGPoint(x: 1 - point.y, y: point.x)
        }
        let converted = videoPreviewLayer.layerPointConverted(fromCaptureDevicePoint: capturePoint)
        guard converted.x.isFinite, converted.y.isFinite else { return nil }
        if shouldFlipHorizontally { return CGPoint(x: bounds.width - converted.x, y: converted.y) }
        return converted
    }
}
