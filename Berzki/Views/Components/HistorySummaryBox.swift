//
//  HistorySummaryBox.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct HistorySummaryBox: View {
    let totalSessions: Int
    let avgQuality: Int
    let streak: Int
    
    var body: some View {
        HStack(spacing: 0) {
            // Total Sesi
            VStack(spacing: 4) {
                Text("\(totalSessions)")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.textPrimary)
                Text("TOTAL SESI")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.textCaption)
                    .kerning(1.2)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: 30)
                .background(Color.borderSubtle)
            
            // Avg Quality
            VStack(spacing: 4) {
                Text("\(avgQuality)%")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.formGood)
                Text("AVG QUALITY")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.textCaption)
                    .kerning(1.2)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: 30)
                .background(Color.borderSubtle)
            
            // Streak
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text("🔥")
                    Text("\(streak)")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.brand)
                }
                Text("STREAK")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.textCaption)
                    .kerning(1.2)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 16)
        .background(Color.bgCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.borderMain, lineWidth: 1)
        )
    }
}

#Preview {
    HistorySummaryBox(totalSessions: 1, avgQuality: 50, streak: 1)
}
