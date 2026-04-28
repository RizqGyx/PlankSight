//
//  CameraGuideCard.swift
//  Berzki
//
//  Created by Muhammad Rizki on 18/04/26.
//

import SwiftUI

struct CameraGuideCard: View {
    var body: some View {
        VStack(spacing: 0) {
            // HIG Caption 2: 11pt Semibold
            Text("POSTUR IDEAL")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.brandButtonText)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.brand)
            
            // Image Placeholder for correct posture
            Image("PlankLight")
                .resizable()
                .scaledToFill()
                .frame(width: 130, height: 100)
                .clipped()
                .background(Color.bgCard)
        }
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
        .frame(width: 130)
    }
}

#Preview {
    CameraGuideCard()
        .padding()
        .background(Color.bgPrimary)
}
