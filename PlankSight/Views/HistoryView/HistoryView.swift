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
    @Environment(\.editMode) var editMode
    @State private var isEditingLocal: Bool = false
    
    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Navigation Header
                HStack(spacing: 4) {
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
                    Spacer()
                    Button(action: {
                        isEditingLocal.toggle()
                        if !isEditingLocal {
                            viewModel.selectedItems.removeAll()
                        }
                    }) {
                        Text(isEditingLocal ? "Selesai" : "Edit")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.brand)
                    }
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
                
                // MARK: - Year Filter (only shown if multi-year data)
                if viewModel.availableYears.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.availableYears, id: \.self) { year in
                                Button(action: {
                                    viewModel.selectedYear = year
                                }) {
                                    Text(String(year))
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(viewModel.selectedYear == year ? .white : .textCaption)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(viewModel.selectedYear == year ? Color.brand : Color.bgInput)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(viewModel.selectedYear == year ? Color.clear : Color.borderMain, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 8)
                }

                // MARK: - Edit Mode Toolbar
                if isEditingLocal {
                    HStack {
                        Button(action: {
                            if viewModel.allVisibleSelected {
                                viewModel.selectedItems.removeAll()
                            } else {
                                viewModel.selectAll()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: viewModel.allVisibleSelected ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 16))
                                    .foregroundColor(.brand)
                                Text(viewModel.allVisibleSelected ? "Batal Pilih Semua" : "Pilih Semua")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.brand)
                            }
                        }
                        Spacer()
                        Text("\(viewModel.selectedItems.count) dipilih")
                            .font(.caption2)
                            .foregroundColor(.textCaption)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                }

                // MARK: - Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        if let year = viewModel.selectedYear {
                            Text(String(year))
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.textCaption)
                                .tracking(0.3)
                                .padding(.bottom, -8)
                        }

                        if viewModel.filteredSections.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "tray")
                                    .font(.system(size: 36))
                                    .foregroundColor(.textMuted.opacity(0.4))
                                Text("Belum ada riwayat sesi")
                                    .font(.footnote)
                                    .foregroundColor(.textCaption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        } else {
                            ForEach(viewModel.filteredSections) { section in
                                SectionCard(section: section, isEditing: $isEditingLocal, onTapItem: { selectedItem in
                                    if let record = SessionRepository.shared.load(id: selectedItem.id) {
                                        let result = SessionResult(
                                            totalDisplaySeconds: record.totalDisplaySeconds,
                                            strictSeconds: record.strictSeconds,
                                            targetDuration: record.targetDuration,
                                            mistakes: record.mistakes
                                        )
                                        appRouter.navigate(to: .summary(result: result))
                                    }
                                }, viewModel: viewModel)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                // MARK: - Bottom Action
                VStack(spacing: 12) {
                    if isEditingLocal && !viewModel.selectedItems.isEmpty {
                        Button(role: .destructive, action: {
                            viewModel.deleteItems(ids: viewModel.selectedItems)
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Hapus \(viewModel.selectedItems.count) Item")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundColor(.white)
                            .background(Color.formBad)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    PrimaryButton(title: "Sesi Baru", iconName: "circle") {
                        appRouter.popToRoot()
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 16)
                .background(Color.bgPrimary)
            }
        }
        .navigationBarHidden(true)
        .onAppear { viewModel.loadSessions() }
    }
}

#Preview {
    HistoryView()
        .environmentObject(AppRouter())
}
