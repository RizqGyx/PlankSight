//
//  SummaryView.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct SummaryView: View {
    @StateObject private var viewModel: SummaryViewModel
    @EnvironmentObject var appRouter: AppRouter

    init(result: SessionResult) {
        _viewModel = StateObject(wrappedValue: SummaryViewModel(result: result))
    }
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        // HIG Caption 2: 11pt Semibold uppercase
                        Text("KERJA BAGUS! 💪")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.brand)
                        
                        // HIG Title 1: 28pt Bold
                        Text("Sesi Selesai")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                        
                        // HIG Footnote: 13pt Regular
                        Text(viewModel.dateString)
                            .font(.footnote)
                            .foregroundColor(.textCaption)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                // MARK: - Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Score Card
                        SummaryScoreCard(qualityScore: viewModel.qualityScore)
                        
                        // Metrics Card
                        VStack(spacing: 0) {
                            HStack {
                                // HIG Caption 2: 11pt Semibold uppercase
                                Text("METRIK SESI")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textCaption)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.bgInput)
                            
                            VStack(spacing: 0) {
                                ForEach(Array(viewModel.metrics.enumerated()), id: \.element.id) { index, metric in
                                    MetricRowWithProgress(metric: metric)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 4)
                                    
                                    if index < viewModel.metrics.count - 1 {
                                        Divider()
                                            .background(Color.borderMain)
                                            .padding(.leading, 60)
                                    }
                                }
                            }
                            .padding(.bottom, 8)
                            .background(Color.bgCard)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.borderMain, lineWidth: 1))
                        
                        // Error Analysis
                        if !viewModel.errors.isEmpty {
                            VStack(spacing: 0) {
                                HStack {
                                    // HIG Caption 2: 11pt Semibold uppercase
                                    Text("ANALISIS ERROR")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.textCaption)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 12) {
                                        // HIG Caption 2: 11pt Semibold
                                        Text("\(viewModel.currentErrorIndex + 1) / \(viewModel.errors.count)")
                                            .font(.caption2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.textCaption)
                                        
                                        // HIG Caption 2: 11pt Semibold
                                        Text("\(viewModel.errors[viewModel.currentErrorIndex].timestamp) - \(viewModel.errors[viewModel.currentErrorIndex].title)")
                                            .font(.caption2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.formBad)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.formBadBg)
                                            .cornerRadius(6)
                                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.formBadBorder, lineWidth: 1))
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.bgInput)
                                
                                VStack {
                                    // Pager
                                    TabView(selection: $viewModel.currentErrorIndex) {
                                        ForEach(Array(viewModel.errors.enumerated()), id: \.element.id) { index, error in
                                            ErrorAnalysisCard(error: error)
                                                .tag(index)
                                                .padding(.horizontal, 16)
                                                .padding(.top, 16)
                                        }
                                    }
                                    .tabViewStyle(.page(indexDisplayMode: .never))
                                    .frame(height: 380)
                                    
                                    
                                    // Custom Page Indicator
                                    HStack(spacing: 6) {
                                        ForEach(0..<viewModel.errors.count, id: \.self) { index in
                                            Capsule()
                                                .fill(viewModel.currentErrorIndex == index ? Color.brand : Color.borderMain)
                                                .frame(width: viewModel.currentErrorIndex == index ? 16 : 6, height: 6)
                                                .animation(.spring(), value: viewModel.currentErrorIndex)
                                        }
                                    }
                                    .padding(.bottom, 20)
                                }
                                .background(Color.bgCard)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.borderMain, lineWidth: 1))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                
                // MARK: - Footer Buttons
                HStack(spacing: 12) {
                    SecondaryButton(title: "Coba Lagi") {
                        let retryDuration = viewModel.duration
                        appRouter.popToRoot()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            appRouter.navigate(to: .camera(duration: retryDuration))
                        }
                    }
                    
                    PrimaryButton(title: "Selesai") {
                        viewModel.finishSession()
                        appRouter.popToRoot()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 16)
                .background(Color.bgPrimary)
            }
        }
        .navigationBarHidden(true)
        .onAppear { forcePortrait() }
    }

    private func forcePortrait() {
        AppDelegate.orientationLock = .portrait
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        if #available(iOS 16.0, *) {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
}

#Preview {
    SummaryView(result: SessionResult(totalDisplaySeconds: 42, strictSeconds: 36, targetDuration: 30))
        .environmentObject(AppRouter())
}
