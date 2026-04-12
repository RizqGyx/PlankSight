//
//  SummaryView.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct SummaryView: View {
    @StateObject private var viewModel = SummaryViewModel()
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("KERJA BAGUS!")
                            .font(.caption)
                            .fontWeight(.black)
                            .foregroundColor(.brand)
                            .kerning(1.2)
                        
                        Text("Sesi Selesai")
                            .font(.system(size: 32, weight: .heavy))
                            .foregroundColor(.textPrimary)
                        
                        Text(viewModel.dateString)
                            .font(.subheadline)
                            .foregroundColor(.textCaption)
                    }
                    
                    Spacer()
                    
                    // Small "Selesai" Badge top right
                    Button(action: viewModel.finishSession) {
                        Text("Selesai")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.brand)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.brandBg)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.brandBorder, lineWidth: 1))
                    }
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
                                Text("METRIK SESI")
                                    .font(.caption)
                                    .fontWeight(.black)
                                    .kerning(1.5)
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
                                    Text("ANALISIS ERROR")
                                        .font(.caption)
                                        .fontWeight(.black)
                                        .kerning(1.5)
                                        .foregroundColor(.textCaption)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 12) {
                                        Text("\(viewModel.currentErrorIndex + 1) / \(viewModel.errors.count)")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.textCaption)
                                        
                                        Text("\(viewModel.errors[viewModel.currentErrorIndex].timestamp) - \(viewModel.errors[viewModel.currentErrorIndex].title)")
                                            .font(.system(size: 11, weight: .bold))
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
                        viewModel.retrySession()
                    }
                    
                    PrimaryButton(title: "Selesai") {
                        viewModel.finishSession()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 16)
                .background(Color.bgPrimary)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    SummaryView()
}
