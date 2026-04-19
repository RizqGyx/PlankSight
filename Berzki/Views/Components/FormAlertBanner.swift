//
//  FormAlertBanner.swift
//  Berzki
//
//  Created by Muhammad Rizki on 18/04/26.
//

import SwiftUI

struct FormAlertBanner: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 2) {
                // HIG Caption 2: 11pt Semibold
                Text("PERINGATAN FORM")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
                
                // HIG Footnote: 13pt Semibold (alert-strong)
                Text(message)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.formBad.opacity(0.95))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
    }
}

#Preview {
    FormAlertBanner(message: "Pinggul terlalu rendah")
        .padding()
        .background(Color.black)
}
