//
//  SummaryScoreCard.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct SummaryScoreCard: View {
    let qualityScore: Int

    private var grade: String {
        switch qualityScore {
        case 95...100: return "S"
        case 90..<95:  return "A+"
        case 85..<90:  return "A"
        case 80..<85:  return "A-"
        case 75..<80:  return "B+"
        case 70..<75:  return "B"
        case 65..<70:  return "B-"
        case 60..<65:  return "C+"
        case 55..<60:  return "C"
        case 50..<55:  return "C-"
        case 40..<50:  return "D+"
        default:       return "D"
        }
    }

    private var gradeColor: Color {
        switch qualityScore {
        case 80...100: return .formGood
        case 60..<80:  return .brand
        default:       return .formBad
        }
    }

    private var gradeTitle: String {
        switch qualityScore {
        case 95...100: return "Sempurna!"
        case 90..<95:  return "Luar Biasa!"
        case 85..<90:  return "Hampir Sempurna!"
        case 80..<85:  return "Sangat Baik!"
        case 75..<80:  return "Cukup Baik!"
        case 70..<75:  return "Lumayan!"
        case 60..<70:  return "Perlu Latihan!"
        case 50..<60:  return "Terus Berjuang!"
        default:       return "Jangan Menyerah!"
        }
    }

    private var gradeSubtitle: String {
        switch qualityScore {
        case 95...100: return "Postur plank-mu tidak bisa lebih baik dari ini!"
        case 90..<95:  return "Kamu menjaga postur plank dengan sangat baik!"
        case 85..<90:  return "Hampir sempurna, sedikit lagi menuju performa terbaik."
        case 80..<85:  return "Kamu bertahan lebih lama dari rata-rata pemula."
        case 75..<80:  return "Tetap latihan untuk meningkatkan konsistensimu."
        case 70..<75:  return "Masih ada ruang untuk memperbaiki form-mu."
        case 60..<70:  return "Fokus pada perbaikan postur di sesi berikutnya."
        case 50..<60:  return "Setiap latihan membuatmu semakin kuat!"
        default:       return "Mulai dari posisi dasar dan tingkatkan secara bertahap."
        }
    }

    var body: some View {
        HStack(spacing: 18) {
            // Circular Progress
            ZStack {
                Circle()
                    .stroke(Color.borderMain, lineWidth: 10)

                Circle()
                    .trim(from: 0, to: CGFloat(qualityScore) / 100)
                    .stroke(gradeColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(qualityScore)%")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(gradeColor)
                    Text("QUALITY")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.textCaption)
                }
            }
            .frame(width: 88, height: 88)

            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(gradeTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .lineSpacing(2)

                Text(gradeSubtitle)
                    .font(.footnote)
                    .foregroundColor(.textCaption)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)

                Text("Grade \(grade)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(gradeColor)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(gradeColor.opacity(0.12))
                    .cornerRadius(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(gradeColor.opacity(0.35), lineWidth: 1)
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
