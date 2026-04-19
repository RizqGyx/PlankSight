//
//  CameraView.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct CameraView: View {
    @StateObject private var viewModel: CameraViewModel
    @EnvironmentObject var appRouter: AppRouter
    
    init(duration: Int? = 30) {
        _viewModel = StateObject(wrappedValue: CameraViewModel(duration: duration))
    }
    
    var body: some View {
        ZStack {
            // MARK: - Camera Background Layer (Placeholder)
            Color.bgPrimary.ignoresSafeArea() 
            
            // Abstract placeholder indicating camera viewfinder
            if case .tracking = viewModel.sessionState {
                // Focus UI: Hide viewfinder and text when tracking
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 64, weight: .light))
                        .foregroundColor(.textPrimary)
                    
                    // Center Prompts based on User State
                    switch viewModel.sessionState {
                    case .searchingUser:
                        // HIG Footnote: 13pt Semibold (cam-text)
                        Text("Posisikan seluruh tubuh di dalam layar")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.brand)
                            
                    case .waitingForPosition:
                        // HIG Footnote: 13pt Semibold (cam-text)
                        Text("Siap-siap... Ambil posisi plank yang benar")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.brand)
                            
                    case .tracking:
                        EmptyView()
                    }
                }
                .offset(y: -10) // bump up slightly against center
                .transition(.opacity)
            }
            
            // MARK: - HUD Layer (Heads-Up Display)
            VStack {
                // Top Section Layer
                HStack(alignment: .top) {
                    
                    // Left: Exit & Timer
                    VStack(alignment: .leading, spacing: 16) {
                        Button(action: {
                            appRouter.pop()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding(16)
                                .background(Color.textPrimary)
                                .clipShape(Circle())
                        }
                    }
                    
                    Spacer()
                    
                    // Center: Error Alert Banner Overlay
                    if let error = viewModel.currentAlertMessage {
                        FormAlertBanner(message: error)
                            .frame(maxWidth: 380) 
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.spring(), value: viewModel.currentAlertMessage)
                    }
                    
                    Spacer()
                    
                    // Right: Posture Guide Card
                    CameraGuideCard()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Bottom Section Layer
                HStack(alignment: .bottom) {
                    
                    // Left: Live Tracked Body Parts / Timer
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Image(systemName: viewModel.duration == nil ? "infinity" : "timer")
                                .font(.caption.bold())
                                .foregroundColor(viewModel.duration == nil ? .brand : .textPrimary)
                            Text(viewModel.duration == nil ? "FREE TIME" : "SISA WAKTU")
                                .font(.caption2.bold())
                                .foregroundColor(.textCaption)
                        }
                        
                        Text(viewModel.displayTime)
                            .font(.system(size: viewModel.displayTime.count > 5 ? 42 : 56, weight: .bold, design: .rounded).monospacedDigit())
                            .foregroundColor(.brand)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.bgCard)
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    )
                    .transition(.opacity)
                    
                    Spacer()
                    
                    // Right: Temporary dev button to mock states
                    Button(action: {
                        withAnimation {
                            if case .tracking(let active) = viewModel.sessionState, !active {
                                // Simulate finishing the session
                                appRouter.navigate(to: .summary)
                            } else {
                                viewModel.toggleState()
                            }
                        }
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color(hex: "#A3A3A3"))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            forceLandscape()
        }
        .onDisappear {
            restorePortrait()
        }
    }
    
    private func forceLandscape() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        if #available(iOS 16.0, *) {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }
    
    private func restorePortrait() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        if #available(iOS 16.0, *) {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
}

// Ensure Xcode renders this in Landscape
#Preview("Camera Landscape", traits: .landscapeLeft) {
    CameraView()
        .environmentObject(AppRouter())
}
