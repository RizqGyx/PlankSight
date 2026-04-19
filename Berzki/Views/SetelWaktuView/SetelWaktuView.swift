//
//  SetelWaktuView.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct SetelWaktuView: View {
    @StateObject private var viewModel = SetelWaktuViewModel()
    @EnvironmentObject var appRouter: AppRouter
    @State private var showCustomModal = false

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
                                        isSelected: viewModel.selectedDuration
                                            == opt.type
                                    ) {
                                        if opt.type == .custom {
                                            showCustomModal = true
                                            // Set visual selection
                                            withAnimation(
                                                .easeInOut(duration: 0.2)
                                            ) {
                                                viewModel.selectedDuration =
                                                    .custom
                                            }
                                        } else {
                                            withAnimation(
                                                .easeInOut(duration: 0.2)
                                            ) {
                                                viewModel.selectedDuration =
                                                    opt.type
                                            }
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
        .sheet(isPresented: $showCustomModal) {
            CustomDurationModalView { seconds in
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.customSeconds = seconds
                    viewModel.selectedDuration = .custom
                }
            }
            .presentationDetents([.fraction(0.85), .large])
        }
    }

    // MARK: - Subviews (Main View)
    private var headerView: some View {
        HStack {
            Button(action: {
                appRouter.goToPanduan()
            }) {
                Image(systemName: "xmark")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
            }
            Spacer()
            // HIG Nav bar title: Headline 17pt Semibold
            Text("Setel Waktu")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            Spacer()
            Button(action: {
                appRouter.navigate(to: .history)
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Riwayat")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.brand)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            // HIG Caption 2: 11pt Semibold uppercase
            Text("PILIH DURASI")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.brand)

            // HIG Title 1: 28pt Bold
            Text("Berapa lama?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)

            // HIG Footnote: 13pt Regular
            Text("Mulai dari target kecil, tingkatkan perlahan")
                .font(.footnote)
                .foregroundColor(.textCaption)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }

    private var bottomActionButton: some View {
        VStack {
            PrimaryButton(title: "Mulai Sesi", iconName: "play.fill") {
                viewModel.startSession()
                let targetDuration: Int?
                switch viewModel.selectedDuration {
                case .freeTime:
                    targetDuration = nil
                case .fixed(let val):
                    targetDuration = val
                case .custom:
                    targetDuration = viewModel.customSeconds
                }
                appRouter.navigate(to: .camera(duration: targetDuration))
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .background(Color.bgPrimary)
    }
}

#Preview {
    SetelWaktuView()
        .environmentObject(AppRouter())
}
