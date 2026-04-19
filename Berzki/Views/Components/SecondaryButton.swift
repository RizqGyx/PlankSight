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
            // HIG Headline: 17pt Semibold
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textBody)
                .padding(.horizontal, isFullWidth ? 16 : 30)
                .padding(.vertical, isFullWidth ? 14 : 13)
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .background(Color.bgInput)
                .cornerRadius(13)
                .overlay(
                    RoundedRectangle(cornerRadius: 13)
                        .stroke(Color.borderMain, lineWidth: 1)
                )
        }
    }
}

#Preview {
    SecondaryButton(title: "Coba Lagi", action: {print("Coba Lagi")})
}
