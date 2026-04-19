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
//    @State private var loadingProgress: CGFloat = 0.0
//    let maxLoadingWidth: CGFloat = 200.0

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
                        Image(
                            colorScheme == .light ? "PlankLight" : "PlankDark"
                        )
                        .resizable()
                        .scaledToFill()
                        .frame(width: 300, height: 150)
                        .offset(y: 10)
                        .clipped()
                        HStack(spacing: 0) {
                            // HIG Large Title: 34pt Bold 700
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
                        // HIG Caption 2: 11pt Semibold, uppercase
                        Text("STABILITAS · VALIDITAS")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.textCaption)
                    }
                }
                
//                ZStack(alignment: .leading) {
//                    Capsule()
//                        .frame(width: maxLoadingWidth, height: 6)
//                        .foregroundColor(Color.textCaption.opacity(0.3))
//                    
//                    // Foreground bar (Progress)
//                    Capsule()
//                        .frame(width: loadingProgress, height: 6)
//                        .foregroundColor(Color.brand)
//                }
//                .padding(.top, 50)
                
                Spacer()
            }
        }
        .onAppear {
//            withAnimation(.linear(duration: 2.0)) {
//                loadingProgress = maxLoadingWidth
//            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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
