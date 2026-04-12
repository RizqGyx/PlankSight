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
        HStack(spacing: 20) {
            // Circular Progress
            ZStack {
                Circle()
                    .stroke(Color.borderMain, lineWidth: 10)
                
                Circle()
                    .trim(from: 0, to: CGFloat(qualityScore) / 100)
                    .stroke(Color.brand, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text("\(qualityScore)%")
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(.formGood)
                    Text("Quality")
                        .font(.system(size: 10))
                        .fontWeight(.bold)
                        .foregroundColor(.textCaption)
                }
            }
            .frame(width: 80, height: 80)
            
            // Text Content
            VStack(alignment: .leading, spacing: 6) {
                Text("Hampir sempurna!")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.textPrimary)
                
                Text("Kamu bertahan lebih lama dari rata-rata pemula. Terus latihan!")
                    .font(.caption)
                    .foregroundColor(.textBody)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Grade B+")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.formGood)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.formGoodBg)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.formGoodBorder, lineWidth: 1)
                    )
            }
        }
        .padding(16)
        .background(Color.bgCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.borderMain, lineWidth: 1)
        )
    }
}

#Preview {
    SummaryScoreCard(qualityScore: 80)
}
