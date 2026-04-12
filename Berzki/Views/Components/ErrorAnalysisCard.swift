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
                    .fill(Color(hex: "#1C1412"))
            
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
                            Text(error.timestamp)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("\(error.title) Rendah")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.formBad)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.formBad.opacity(0.2))
                            .cornerRadius(6)
                    }
                    Spacer()
                }
                .padding(12)
            }
            .frame(height: 180)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderMain, lineWidth: 1))
            
            // Description Text
            if let attributedString = try? AttributedString(markdown: error.descriptionHTML) {
                Text(attributedString)
                    .font(.subheadline)
                    .foregroundColor(.textBody)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(error.descriptionHTML)
                    .font(.subheadline)
                    .foregroundColor(.textBody)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Tips Box
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(.brand)
                    .font(.system(size: 16))
                    .padding(.top, 2)
                
                Text(error.tip)
                    .font(.caption)
                    .foregroundColor(.brandDark)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(12)
            .background(Color.brandBg)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.brandBorder, lineWidth: 1))
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
