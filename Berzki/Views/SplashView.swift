//
//  SplashView.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct SplashView: View {
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
                        Image("Plank")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 150)
                            .offset(y: 10)
                            .clipped()
                        HStack(spacing: 0) {
                            Text("PLANK")
                                .font(Font.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(Color.textPrimary)
                            Text("SIGHT")
                                .font(Font.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(Color.brand)
                        }
                        
                        Text("STABILITY · VALIDITY")
                            .font(Font.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color.textBody)
                            .opacity(Double(0.5))
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    SplashView()
}
