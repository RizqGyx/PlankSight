//
//  SetelWaktuView.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct SetelWaktuView: View {
    @StateObject private var viewModel = SetelWaktuViewModel()
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Header
                headerView
                
                // MARK: - Title Section
                titleSection
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // MARK: - List Items
                        VStack(spacing: 12) {
                            ForEach(viewModel.options) { opt in
                                DurationOptionRow(
                                    opt: opt,
                                    isSelected: viewModel.selectedDuration == opt.type
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.selectedDuration = opt.type
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }
                }
                
                // MARK: - Bottom Button
                bottomActionButton
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Subviews (Main View)
    private var headerView: some View {
        HStack {
            Button(action: { print("Tutup") }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textMuted)
            }
            Spacer()
            Text("Setel Waktu")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            Spacer()
            Button(action: { print("Riwayat") }) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 14, weight: .bold))
                    Text("Riwayat")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.brand)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("PILIH DURASI")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.brand)
                .kerning(1.2)
            
            Text("Berapa lama?")
                .font(.system(size: 34, weight: .heavy))
                .foregroundColor(.textPrimary)
            
            Text("Mulai dari target kecil, tingkatkan perlahan")
                .font(.subheadline)
                .foregroundColor(.textMuted)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
    
    private var bottomActionButton: some View {
        VStack {
            PrimaryButton(title: "Mulai Sesi", iconName: "play.fill") {
                viewModel.startSession()
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .background(Color.bgPrimary)
    }
}


#Preview {
    SetelWaktuView()
}
