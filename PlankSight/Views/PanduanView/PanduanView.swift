//
//  PanduanView.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct PanduanView: View {
    @StateObject private var viewModel = PanduanViewModel()
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header Title — HIG Headline: 17pt Semibold
                Text("Panduan")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .padding(.top, 10)
                    .padding(.bottom, 20)

                // Segmented Picker
                HStack(spacing: 0) {
                    TabButton(
                        title: "Panduan App",
                        isSelected: viewModel.selectedTab == 0
                    ) {
                        viewModel.setTab(0)
                    }
                    TabButton(
                        title: "Panduan Plank",
                        isSelected: viewModel.selectedTab == 1
                    ) {
                        viewModel.setTab(1)
                    }
                }
                .padding(4)
                .background(Color.bgInput)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 20)

                // Slides
                TabView(selection: $viewModel.currentPage) {
                    if viewModel.selectedTab == 0 {
                        AppSlide1().tag(0)
                        AppSlide2().tag(1)
                        AppSlide3().tag(2)
                        AppSlide4().tag(3)
                        AppSlide5().tag(4)
                    } else {
                        PlankSlide1().tag(0)
                        PlankSlide2().tag(1)
                        PlankSlide3().tag(2)
                        PlankSlide4().tag(3)
                        PlankSlide5().tag(4)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .id(viewModel.selectedTab)

                // Page Indicator — dinamis sesuai tab
                let totalPages = viewModel.selectedTab == 0 ? 5 : 5
                HStack(spacing: 6) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Capsule()
                            .fill(
                                viewModel.currentPage == index
                                    ? Color.brand
                                    : Color.textMuted.opacity(0.3)
                            )
                            .frame(
                                width: viewModel.currentPage == index ? 18 : 6,
                                height: 6
                            )
                            .animation(.spring(), value: viewModel.currentPage)
                    }
                }
                .animation(.easeInOut, value: viewModel.selectedTab)
                .padding(.vertical, 16)

                // Footer
                HStack {
                    HStack {
                        Toggle(isOn: $viewModel.dontShowAgain) {}
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: .formGood))
                        Text("Jangan tampilkan lagi")
                            .font(.subheadline)
                            .foregroundColor(.textBody)
                    }

                    Spacer()

                    PrimaryButton(title: "Lanjut", isFullWidth: false) {
                        appRouter.finishPanduan(dontShowAgain: viewModel.dontShowAgain)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
    }
}

#Preview() {
    PanduanView()
        .environmentObject(AppRouter())
}
