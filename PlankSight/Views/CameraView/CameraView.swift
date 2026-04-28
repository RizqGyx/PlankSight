import SwiftUI

struct CameraView: View {
    @StateObject private var viewModel: CameraViewModel
    @EnvironmentObject var appRouter: AppRouter

    init(duration: Int? = nil) {
        _viewModel = StateObject(wrappedValue: CameraViewModel(duration: duration))
    }

    var body: some View {
        GeometryReader { _ in
            ZStack {
                // MARK: - Camera Background
                CameraPreviewView(
                    session: viewModel.cameraSession,
                    poseFrame: viewModel.poseFrame,
                    isUsingFrontCamera: viewModel.isUsingFrontCamera
                )
                .ignoresSafeArea()

                // MARK: - Searching / Candidate Overlay
                if isSearching {
                    VStack(spacing: 16) {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 64, weight: .light))
                            .foregroundColor(.white.opacity(0.85))

                        if case .candidate(_, let frames) = viewModel.trackingState {
                            VStack(spacing: 6) {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.brand)
                                    .scaleEffect(1.4)
                                Text("Bersiap… \(frames)/8")
                                    .font(.footnote.bold())
                                    .foregroundColor(.brand)
                            }
                        } else {
                            Text("Posisikan seluruh tubuh di dalam layar")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 40)
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                }

                // MARK: - HUD Layer
                VStack(spacing: 0) {

                    // Top row: X button | FormAlertBanner | Camera Toggle
                    ZStack(alignment: .top) {
                        HStack(alignment: .top) {
                            // Exit button
                            Button(action: {
                                if viewModel.hasValidSession {
                                    viewModel.requestStop()
                                } else {
                                    appRouter.pop()
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(11)
                                    .background(Color.black.opacity(0.55))
                                    .clipShape(Circle())
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                        // Error banner (centered)
                        if let error = viewModel.currentAlertMessage {
                            FormAlertBanner(message: error)
                                .frame(maxWidth: 380)
                                .padding(.top, 16)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .animation(.spring(response: 0.35), value: viewModel.currentAlertMessage)
                        }
                    }

                    // Tilt guidance (center of screen)
                    if let guidance = viewModel.tiltGuidanceText {
                        Spacer()
                        Text(guidance)
                            .font(.footnote.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(10)
                            .transition(.opacity.animation(.easeInOut))
                        Spacer()
                    } else {
                        Spacer()
                    }

                    // Bottom HUD
                    VStack(spacing: 10) {

                        // Status indicator row
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.formGood)
                                .opacity(viewModel.indicatorOpacity)
                                .frame(width: 10, height: 10)
                                .animation(.easeInOut(duration: 0.3), value: viewModel.indicatorOpacity)
                            Text(viewModel.statusText)
                                .font(.caption.bold())
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(20)

                        // Timer card
                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: viewModel.duration == nil ? "infinity" : "timer")
                                    .font(.caption.bold())
                                    .foregroundColor(viewModel.duration == nil ? .brand : .textCaption)
                                Text(viewModel.duration == nil ? "FREE TIME" : "SISA WAKTU")
                                    .font(.caption2.bold())
                                    .foregroundColor(.textCaption)
                            }

                            Text(viewModel.timerDisplay)
                                .font(.system(size: 64, weight: .bold, design: .rounded).monospacedDigit())
                                .foregroundColor(.brand)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(Color.bgCard.opacity(0.95))
                                    .shadow(color: .black.opacity(0.2), radius: 14, x: 0, y: 6)

                                // Progress bar lives in background so it doesn't expand the card
                                if viewModel.duration != nil {
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Color.borderMain)
                                                .frame(height: 5)
                                            Capsule()
                                                .fill(Color.brand)
                                                .frame(width: geo.size.width * viewModel.timerProgress, height: 5)
                                                .animation(.linear(duration: 0.1), value: viewModel.timerProgress)
                                        }
                                    }
                                    .frame(height: 5)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 10)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }

                // MARK: - Landscape Warning Overlay
                if !viewModel.isDeviceLandscape {
                    ZStack {
                        Color.bgPrimary.ignoresSafeArea()
                        VStack(spacing: 24) {
                            Image(systemName: "iphone.landscape")
                                .font(.system(size: 64))
                                .foregroundColor(.brand)
                            Text("Silakan Putar Ponsel Anda")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.textPrimary)
                            Text("Aplikasi ini membutuhkan mode lanskap untuk mendeteksi postur tubuh Anda dengan akurat.")
                                .font(.subheadline)
                                .foregroundColor(.textCaption)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            Button(action: { appRouter.pop() }) {
                                Text("Kembali")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 14)
                                    .background(Color.brand)
                                    .cornerRadius(20)
                            }
                            .padding(.top, 16)
                        }
                    }
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            forceLandscape()
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
            restorePortrait()
        }
        // Auto-navigate to Summary when session completes
        .onChange(of: viewModel.sessionCompleted) { oldValue, newValue in
            if newValue, let result = viewModel.sessionResult {
                appRouter.navigate(to: .summary(result: result))
            }
        }
    }

    // MARK: - Helpers
    private var isSearching: Bool {
        switch viewModel.trackingState {
        case .idle, .candidate: return true
        case .active, .ended: return false
        }
    }

    private func forceLandscape() {
        AppDelegate.orientationLock = .landscape
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        if #available(iOS 16.0, *) {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }

    private func restorePortrait() {
        AppDelegate.orientationLock = .portrait
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        if #available(iOS 16.0, *) {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
}

#Preview("Camera Landscape", traits: .landscapeLeft) {
    CameraView()
        .environmentObject(AppRouter())
}

