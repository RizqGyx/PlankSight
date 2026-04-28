//
//  DayIndicator.swift
//  PlankSight
//
//  Created by Muhammad Rizki on 22/04/26.
//

import SwiftUI

struct DayIndicatorView: View {
    let indicators: [DayIndicator]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aktivitas 7 Hari Terakhir")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 0) {
                ForEach(indicators) { indicator in
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(indicator.isCompleted ? Color.brand : Color.borderMain)
                                .frame(width: 40, height: 40)

                            if indicator.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                            }
                        }
                        .overlay(
                            Circle()
                                .stroke(
                                    indicator.isToday ? Color.brand : Color.clear,
                                    lineWidth: 2
                                )
                                .padding(-3)
                        )

                        Text(indicator.label)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.textCaption)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(Color.bgCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.borderMain, lineWidth: 1))
    }
}

#Preview {
    DayIndicatorView(indicators: [
        DayIndicator(label: "Sen", isCompleted: true, isToday: false),
        DayIndicator(label: "Sel", isCompleted: false, isToday: false),
        DayIndicator(label: "Rab", isCompleted: true, isToday: false),
        DayIndicator(label: "Kam", isCompleted: true, isToday: false),
        DayIndicator(label: "Jum", isCompleted: true, isToday: true),
        DayIndicator(label: "Sab", isCompleted: false, isToday: false),
        DayIndicator(label: "Min", isCompleted: false, isToday: false)
    ])
}
