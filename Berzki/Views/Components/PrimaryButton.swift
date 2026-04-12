//
//  PrimaryButton.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct PrimaryButton: View {
    var title: String
    var iconName: String? = nil
    var isFullWidth: Bool = true
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(title)
                    .font(isFullWidth ? .system(size: 18, weight: .bold) : .headline)
                    .fontWeight(isFullWidth ? .bold : .semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, isFullWidth ? 16 : 30)
            .padding(.vertical, isFullWidth ? 16 : 14)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(Color.brand)
            .cornerRadius(isFullWidth ? 16 : 12)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Mulai Sesi", iconName: "play.fill") {
            print("Action Full Width")
        }
        
        PrimaryButton(title: "Lanjut", isFullWidth: false) {
            print("Action Not Full Width")
        }
    }
    .padding()
}
