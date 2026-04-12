//
//  DurationOptionRow.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct DurationOptionRow: View {
    let opt: SetelWaktuViewModel.OptionData
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon box
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.brand.opacity(0.15) : Color.textBody.opacity(0.08))
                    Image(systemName: opt.iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? .brand : .textBody.opacity(0.6))
                }
                .frame(width: 44, height: 44)
                
                // Titles
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(opt.title)
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        if let badge = opt.badge {
                            Text(badge)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.brand)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.brand.opacity(0.15))
                                .cornerRadius(6)
                        }
                    }
                    
                    Text(opt.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.textBody)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Radio Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.brand)
                } else {
                    Circle()
                        .stroke(Color.textBody.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                }
            }
            .padding()
            .background(isSelected ? Color.brandBg : Color.bgCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.brand : Color.borderMain, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 12) {
        DurationOptionRow(
            opt: SetelWaktuViewModel.OptionData(type: .fixed(30), title: "30 Detik", subtitle: "Rekomendasi untuk pemula", iconName: "clock", badge: "Populer"),
            isSelected: true,
            action: {}
        )
        DurationOptionRow(
            opt: SetelWaktuViewModel.OptionData(type: .freeTime, title: "Free Time", subtitle: "Tanpa batas waktu, hentikan kapan saja", iconName: "infinity", badge: nil),
            isSelected: false,
            action: {}
        )
    }
    .padding()
    .background(Color.bgPrimary)
}
