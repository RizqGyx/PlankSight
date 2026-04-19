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
                    RoundedRectangle(cornerRadius: 9)
                        .fill(isSelected ? Color.brandBg : Color.bgInput)
                    Image(systemName: opt.iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? .brand : .textBody.opacity(0.6))
                }
                .frame(width: 36, height: 36)
                
                // Titles
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        // HIG Subhead: 15pt Semibold (dur-main)
                        Text(opt.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(isSelected ? .brand : .textPrimary)
                    }
                    
                    // HIG Footnote: 13pt Regular (dur-sub)
                    Text(opt.subtitle)
                        .font(.footnote)
                        .foregroundColor(isSelected ? .brand.opacity(0.7) : .textCaption)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                }
                
                Spacer()
                
                // Radio Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.brand)
                } else {
                    Circle()
                        .stroke(Color.borderMain, lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(isSelected ? Color.brandBg : Color.bgCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.brand : Color.borderMain, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 12) {
        DurationOptionRow(
            opt: SetelWaktuViewModel.OptionData(type: .fixed(30), title: "30 Detik", subtitle: "Rekomendasi untuk pemula", iconName: "clock"),
            isSelected: true,
            action: {}
        )
        DurationOptionRow(
            opt: SetelWaktuViewModel.OptionData(type: .freeTime, title: "Free Time", subtitle: "Tanpa batas waktu, hentikan kapan saja", iconName: "infinity"),
            isSelected: false,
            action: {}
        )
    }
    .padding()
    .background(Color.bgPrimary)
}
