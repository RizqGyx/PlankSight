//
//  AppSlide.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct AppSlide: View {
    let title: String?
    var body: some View {
        VStack(spacing: 12) {
            // Main Illustration area
            ZStack(alignment: .topLeading) {
                Color.bgCard
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.borderMain, lineWidth: 1))
                
                VStack {
                    HStack {
                        Text(title ?? "Langkah 1 · Setup Kamera")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.textCaption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.bgInput)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.borderMain, lineWidth: 1))
                        Spacer()
                    }
                    .padding(16)
                    
                    Spacer()
                    
                    // Specific Illustration
                    VStack(spacing: 4) {
                        Image(systemName: "iphone")
                            .font(.system(size: 50))
                            .foregroundColor(.brand.opacity(0.5))
                            .background(Color.brandBg)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.brandBorder, lineWidth: 1))
                        
                        Text("3 meter")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.brand)
                        
                        Text("Posisikan ponsel setinggi pinggang")
                            .font(.caption2)
                            .foregroundColor(.textCaption)
                            .padding(.top, 10)
                    }
                    
                    Spacer()
                }
            }
            .frame(maxHeight: .infinity)
            
            // Info Card
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.brandBg)
                        .frame(width: 40, height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.brandBorder, lineWidth: 1))
                    
                    Image(systemName: "info.circle")
                        .foregroundColor(.brand)
                        .font(.system(size: 18, weight: .regular))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tripod disarankan")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    Text("Pastikan ponsel stabil dan kamera menghadap area plank dari sisi samping")
                        .font(.caption)
                        .foregroundColor(.textBody)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.borderMain, lineWidth: 1))
        }
        .padding(.horizontal)
    }
}

// Sub-slides
struct AppSlide1: View { var body: some View { AppSlide(title: "Langkah 1 - Setup Kamera") } }
struct AppSlide2: View { var body: some View { AppSlide(title: "Langkah 2 - Posisi Berdiri") } }
struct AppSlide3: View { var body: some View { AppSlide(title: "Langkah 3 - Hitung Mulai") } }
struct AppSlide4: View { var body: some View { AppSlide(title: "Langkah 4 - Hitung Selesai") } }
struct PlankSlide1: View { var body: some View { AppSlide(title: "Metrik 1 - Kepala") } }
struct PlankSlide2: View { var body: some View { AppSlide(title: "Metrik 2 - Pinggul") } }
struct PlankSlide3: View { var body: some View { AppSlide(title: "Metrik 3 - Lutut") } }
struct PlankSlide4: View { var body: some View { AppSlide(title: "Metrik 4 - Kaki") } }

#Preview {
    AppSlide(title: "Langkah 1 - Setup Kamera")
}
