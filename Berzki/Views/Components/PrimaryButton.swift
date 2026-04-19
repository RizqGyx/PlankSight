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
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                // HIG Headline: 17pt Semibold
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            // Dark mode: dark text on brand button (#1A1410)
            .foregroundColor(.brandButtonText)
            .padding(.horizontal, isFullWidth ? 16 : 22)
            .padding(.vertical, isFullWidth ? 15 : 13)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(Color.brand)
            .cornerRadius(13)
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
