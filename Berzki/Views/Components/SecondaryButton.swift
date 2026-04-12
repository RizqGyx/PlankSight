//
//  SecondaryButton.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct SecondaryButton: View {
    var title: String
    var isFullWidth: Bool = true
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(isFullWidth ? .system(size: 18, weight: .bold) : .headline)
                .fontWeight(isFullWidth ? .bold : .semibold)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, isFullWidth ? 16 : 30)
                .padding(.vertical, isFullWidth ? 16 : 14)
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .background(Color.bgInput)
                .cornerRadius(isFullWidth ? 16 : 12)
                .overlay(
                    RoundedRectangle(cornerRadius: isFullWidth ? 16 : 12)
                        .stroke(Color.borderMain, lineWidth: 1)
                )
        }
    }
}

#Preview {
    SecondaryButton(title: "Coba Lagi", action: {print("Coba Lagi")})
}
