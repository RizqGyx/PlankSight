//
//  TargetWaktuSheet.swift
//  PlankSight
//
//  Created by Muhammad Rizki on 27/04/26.
//

import SwiftUI

// MARK: - Target Waktu Sheet

struct TargetWaktuSheet: View {
    @ObservedObject var viewModel: SetelWaktuViewModel
    var appRouter: AppRouter
    @Environment(\.dismiss) var dismiss
    @State private var showCustomModal = false

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Pilih Target Waktu")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textMuted)
                            .font(.title2)
                    }
                }
                .padding()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(viewModel.options) { opt in
                            DurationOptionRow(
                                opt: opt,
                                isSelected: viewModel.selectedDuration == opt.type
                            ) {
                                if opt.type == .custom {
                                    showCustomModal = true
                                } else {
                                    viewModel.selectedDuration = opt.type
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }

                PrimaryButton(
                    title: "Gunakan Target Ini",
                    isFullWidth: true
                ) {
                    dismiss()

                    let targetDuration: Int?
                    switch viewModel.selectedDuration {
                    case .freeTime: targetDuration = nil
                    case .fixed(let val): targetDuration = val
                    case .custom: targetDuration = viewModel.customSeconds > 0 ? viewModel.customSeconds : nil
                    }

                    appRouter.navigate(to: .camera(duration: targetDuration))
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showCustomModal) {
            CustomDurationModalView { seconds in
                withAnimation {
                    viewModel.customSeconds = seconds
                    viewModel.selectedDuration = .custom
                }
            }
            .presentationDetents([.fraction(0.85), .large])
        }
    }
}
