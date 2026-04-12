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
        HStack(alignment: .top, spacing: 16) {
            // Date Box
            VStack(spacing: 2) {
                Text(item.dayString)
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.textPrimary)
                Text(item.monthString)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.textCaption)
            }
            .frame(width: 50, height: 50)
            .background(Color.bgInput)
            .cornerRadius(12)
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 6) {
                    Text(item.durationText)
                        .font(.caption)
                        .foregroundColor(.textCaption)
                    
                    // Quality Badge
                    Text("Quality \(item.qualityPercent)%")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(item.qualityLevel.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(item.qualityLevel.bgColor)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(item.qualityLevel.borderColor, lineWidth: 1)
                        )
                }
                
                // Tags
                if !item.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(item.tags) { tag in
                            HStack(spacing: 4) {
                                if let icon = tag.icon, icon == "checkmark" {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.textPrimary)
                                }
                                Text(tag.text)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.textBody)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.borderMain, lineWidth: 1)
                            )
                        }
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.borderMain)
                .padding(.top, 16)
        }
        .padding(.vertical, 16)
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
