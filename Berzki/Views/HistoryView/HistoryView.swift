//
//  HistoryView.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @EnvironmentObject var appRouter: AppRouter
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Navigation Header
                Button(action: {
                    appRouter.pop()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .fontWeight(.semibold)
                        // HIG Callout: 16pt Semibold
                        Text("Kembali")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.brand)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // MARK: - Title
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading) {
                        // HIG Title 1: 28pt Bold
                        Text("Riwayat Sesi")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                        // HIG Subhead: 15pt Regular
                        Text("Semua rekam jejakmu ada di sini")
                            .font(.subheadline)
                            .foregroundColor(.textCaption)
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
                        // HIG Footnote: 13pt Semibold
                        Text("2026")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.textCaption)
                            .tracking(0.3)
                            .padding(.bottom, -8)
                        
                        ForEach(viewModel.historySections) { section in
                            SectionCard(section: section) { selectedItem in
                                appRouter.navigate(to: .summary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // MARK: - Botttom Action
                VStack {
                    PrimaryButton(title: "Sesi Baru", iconName: "circle") {
                        appRouter.popToRoot()
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
    var onTapItem: ((SessionHistory) -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section Header — HIG Caption 2: 11pt Semibold uppercase
            HStack {
                Text(section.header)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .textCase(.uppercase)
                    .foregroundColor(.textCaption)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.bgInput)
            
            // Items Inside Section
            VStack(spacing: 0) {
                ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                    // Wrap the card in a Button or NavigationLink
                    Button(action: {
                        onTapItem?(item)
                    }) {
                        HistoryItemCard(item: item)
                            .padding(.horizontal, 16)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
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
        .environmentObject(AppRouter())
}
