//
//  SummaryScoreCard.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct SummaryScoreCard: View {
    let qualityScore: Int
    
    var body: some View {
        HStack(spacing: 18) {
            // Circular Progress
            ZStack {
                Circle()
                    .stroke(Color.borderMain, lineWidth: 10)
                
                Circle()
                    .trim(from: 0, to: CGFloat(qualityScore) / 100)
                    .stroke(Color.brand, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    // HIG Title 2: 22pt Semibold
                    Text("\(qualityScore)%")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.formGood)
                    // HIG Caption 2: 11pt Semibold uppercase
                    Text("QUALITY")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.textCaption)
                }
            }
            .frame(width: 88, height: 88)
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                // HIG Subhead: 15pt Semibold (score-title)
                Text("Hampir sempurna!")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .lineSpacing(2)
                
                // HIG Footnote: 13pt Regular (score-sub)
                Text("Kamu bertahan lebih lama dari rata-rata pemula.")
                    .font(.footnote)
                    .foregroundColor(.textCaption)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
                
                // HIG Caption 2: 11pt Semibold (score-grade)
                Text("Grade B+")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.formGood)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(Color.formGoodBg)
                    .cornerRadius(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color.formGoodBorder, lineWidth: 1)
                    )
                    .padding(.top, 3)
            }
        }
        .padding(18)
        .background(Color.bgCard)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.borderMain, lineWidth: 1)
        )
    }
}

#Preview {
    SummaryScoreCard(qualityScore: 75)
}
