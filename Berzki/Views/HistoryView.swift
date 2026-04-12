//
//  HistoryView.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Navigation Header
                Button(action: { print("Kembali") }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                        Text("Kembali")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.brand)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // MARK: - Title
                VStack(alignment: .leading, spacing: 24) {
                    VStack {
                        Text("Riwayat Sesi")
                            .font(.system(size: 34, weight: .heavy))
                            .foregroundColor(.textPrimary)
                        Text("Semua rekam jejakmu ada di sini")
                            .font(.subheadline)
                            .foregroundColor(.textBody)
                    }
                    // Summary Box
                    HistorySummaryBox(
                        totalSessions: viewModel.totalSessions,
                        avgQuality: viewModel.averageQuality,
                        streak: viewModel.streak
                    )
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                // MARK: - Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("2026")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.textCaption)
                            .padding(.bottom, -8)
                        
                        ForEach(viewModel.historySections) { section in
                            SectionCard(section: section)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // MARK: - Botttom Action
                VStack {
                    PrimaryButton(title: "Sesi Baru", iconName: "circle") {
                        print("Sesi Baru")
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
                .background(Color.bgPrimary)
            }
        }
        .navigationBarHidden(true)
    }
}

// Subcomponent for the section wrapper
struct SectionCard: View {
    let section: HistorySection
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section Header
            HStack {
                Text(section.header)
                    .font(.caption)
                    .fontWeight(.black)
                    .kerning(1.5)
                    .foregroundColor(.textCaption)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.bgInput)
            
            // Items Inside Section
            VStack(spacing: 0) {
                ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                    HistoryItemCard(item: item)
                        .padding(.horizontal, 16)
                    
                    if index < section.items.count - 1 {
                        Divider()
                            .background(Color.borderMain)
                            .padding(.leading, 82)
                    }
                }
            }
            .background(Color.bgPrimary)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.borderMain, lineWidth: 1)
        )
    }
}

#Preview {
    HistoryView()
}
