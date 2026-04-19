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
            VStack(spacing: 3) {
                // HIG Headline: 17pt Semibold (stat-n)
                Text("\(totalSessions)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                // HIG Caption 2: 11pt Semibold uppercase (stat-l)
                Text("TOTAL SESI")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.textCaption)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: 30)
                .background(Color.borderMain)
            
            // Avg Quality
            VStack(spacing: 3) {
                // HIG Headline: 17pt Semibold (stat-n)
                Text("\(avgQuality)%")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.formGood)
                // HIG Caption 2: 11pt Semibold uppercase (stat-l)
                Text("AVG QUALITY")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.textCaption)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: 30)
                .background(Color.borderMain)
            
            // Streak
            VStack(spacing: 3) {
                HStack(spacing: 4) {
                    Text("🔥")
                    // HIG Headline: 17pt Semibold (stat-n)
                    Text("\(streak)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.brand)
                }
                // HIG Caption 2: 11pt Semibold uppercase (stat-l)
                Text("STREAK")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.textCaption)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 12)
        .background(Color.bgCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.borderMain, lineWidth: 1)
        )
    }
}

#Preview {
    HistorySummaryBox(totalSessions: 1, avgQuality: 50, streak: 1)
}
