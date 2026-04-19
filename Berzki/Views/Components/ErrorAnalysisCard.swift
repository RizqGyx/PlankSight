//
//  ErrorAnalysisCard.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct ErrorAnalysisCard: View {
    let error: ErrorAnalysis
    
    var body: some View {
        VStack(spacing: 16) {
            // Video Frame Simulation
            ZStack {
                Rectangle()
                    .fill(Color(hex: "#0D0D15"))
            
                Image("pinggul_rendah_mock")
                    .resizable()
                    .scaledToFit()
                    .opacity(0.5)
                
                // Overlay Tags
                VStack {
                    HStack {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.formBad)
                                .frame(width: 8, height: 8)
                            // HIG Caption 2: 11pt Semibold
                            Text(error.timestamp)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.75))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.75))
                        .cornerRadius(7)
                        
                        Spacer()
                        
                        // HIG Caption 2: 11pt Semibold
                        Text("\(error.title) Rendah")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.formBad)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.formBad.opacity(0.18))
                            .cornerRadius(7)
                    }
                    Spacer()
                }
                .padding(12)
            }
            .frame(height: 180)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.formBadBorder, lineWidth: 1))
            
            // Description Text — HIG Footnote: 13pt Regular
            if let attributedString = try? AttributedString(markdown: error.descriptionHTML) {
                Text(attributedString)
                    .font(.footnote)
                    .foregroundColor(.textBody)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(error.descriptionHTML)
                    .font(.footnote)
                    .foregroundColor(.textBody)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Tips Box — HIG Caption 1: 12pt Regular
            HStack(alignment: .top, spacing: 7) {
                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(.brand)
                    .font(.system(size: 26))
                    .padding(.top, 1)
                
                Text(error.tip)
                    .font(.caption)
                    .foregroundColor(.textBody)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
                Spacer()
            }
            .padding(10)
            .background(Color.brandBg)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.brandBorder, lineWidth: 1))
        }
    }
}

#Preview {
    ErrorAnalysisCard(error: ErrorAnalysis(
        timestamp: "00:12",
        title: "Pinggul",
        descriptionHTML: "Di detik **00:12**, pinggul kamu turun di bawah garis ideal. Kondisi ini membebani **lower back** dan mengurangi efektivitas latihan core.",
        tip: "Tips: Kontraksikan otot perut, dorong tumit ke belakang, bayangkan papan lurus di punggungmu.",
        imageName: "pinggul_rendah_mock"
    ))
    .padding()
}
