//
//  HistoryItemCard.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct HistoryItemCard: View {
    let item: SessionHistory
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Date Box
            VStack(spacing: 1) {
                // HIG Headline: 17pt Semibold (date day number)
                Text(item.dayString)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                // HIG Caption 2: 11pt Semibold uppercase
                Text(item.monthString)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .textCase(.uppercase)
                    .foregroundColor(.textCaption)
            }
            .frame(width: 44, height: 44)
            .background(Color.bgInput)
            .cornerRadius(10)
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                // HIG Footnote: 13pt Semibold (session title)
                Text(item.title)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 7) {
                    // HIG Caption 1: 12pt Regular (meta duration)
                    Text(item.durationText)
                        .font(.caption)
                        .foregroundColor(.textCaption)
                    
                    // Quality Badge — HIG Caption 2: 11pt Semibold
                    Text("Quality \(item.qualityPercent)%")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(item.qualityLevel.color)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(item.qualityLevel.bgColor)
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(item.qualityLevel.borderColor, lineWidth: 1)
                        )
                }
                
                // Tags — HIG Caption 2: 11pt Semibold
                if !item.tags.isEmpty {
                    HStack(spacing: 3) {
                        ForEach(item.tags) { tag in
                            HStack(spacing: 4) {
                                if let icon = tag.icon, icon == "checkmark" {
                                    Image(systemName: "checkmark")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.textCaption)
                                }
                                Text(tag.text)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textCaption)
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(Color.bgInput)
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.borderMain, lineWidth: 1)
                            )
                        }
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
                .padding(.top, 16)
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    HistoryItemCard(item: SessionHistory(
        dayString: "09",
        monthString: "APR",
        title: "Free Time · 42 detik",
        durationText: "42 / ∞ detik",
        qualityPercent: 95,
        qualityLevel: .excellent,
        tags: [
            SessionTag(text: "Semua form sempurna", icon: "checkmark")
        ]
    ))
    .padding()
}
