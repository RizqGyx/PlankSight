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
        VStack(spacing: 10) {
            // Main Illustration area
            ZStack(alignment: .topLeading) {
                Color.bgCard
                    .cornerRadius(18)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.borderMain, lineWidth: 1))
                
                ZStack {
                    Image("SetupCamera")
                        .resizable()
                        .cornerRadius(8)
                    
                    VStack {
                        HStack {
                            // HIG Caption 2: 11pt Semibold (illus-label)
                            Text(title ?? "Langkah 1 · Setup Kamera")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.textBody)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 3)
                                .background(Color.bgInput)
                                .cornerRadius(5)
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.borderMain, lineWidth: 1))
                            Spacer()
                        }
                        .padding(12)
                        
                        Spacer()
                    }
                }
                .frame(maxHeight: .infinity)}
            
            // Info Card
            HStack(alignment: .top, spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(Color.brandBg)
                        .frame(width: 38, height: 38)
                        .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.brandBorder, lineWidth: 1))
                    
                    Image(systemName: "info.circle")
                        .foregroundColor(.brand)
                        .font(.system(size: 16, weight: .regular))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    // HIG Footnote: 13pt Semibold (info-strong)
                    Text("Tripod disarankan")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    // HIG Caption 1: 12pt Regular (info-sub)
                    Text("Pastikan ponsel stabil dan kamera menghadap area plank dari sisi samping")
                        .font(.caption)
                        .foregroundColor(.textCaption)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)
                }
                Spacer()
            }
            .padding(14)
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
