//
//  SplashView.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appRouter: AppRouter
    @Environment(\.colorScheme) var colorScheme
    @State private var animateBrand = false

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack {
                Spacer()

                ZStack {
                    Circle()
                        .foregroundColor(Color.bgCard)
                        .frame(width: 350, height: 350)

                    VStack {
                        Image(colorScheme == .light ? "PlankLight" : "PlankDark")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 150)
                            .offset(y: 10)
                            .clipped()
                            .scaleEffect(animateBrand ? 1.05 : 0.95)
                            .animation(
                                Animation.easeInOut(duration: 1),
                                value: animateBrand
                            )

                        HStack(spacing: 0) {
                            Text("PLANK")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                                .foregroundColor(Color.textPrimary)
                            Text("SIGHT")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                                .foregroundColor(Color.brand)
                        }
                        .opacity(animateBrand ? 1 : 0)
                        .offset(y: animateBrand ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateBrand)

                        Text("STABILITAS · VALIDITAS")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.textCaption)
                            .opacity(animateBrand ? 1 : 0)
                            .animation(.easeOut(duration: 0.8).delay(0.4), value: animateBrand)
                    }
                }

                Spacer()

                ProgressView()
                    .tint(.brand)
                    .scaleEffect(1.2)
                    .padding(.bottom, 60)
                    .opacity(animateBrand ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.6), value: animateBrand)
            }
        }
        .onAppear {
            animateBrand = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    appRouter.finishSplash()
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AppRouter())
}
