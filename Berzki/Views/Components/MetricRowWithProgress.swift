//
//  MetricRowWithProgress.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

struct MetricRowWithProgress: View {
    let metric: SessionMetric
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(metric.type.iconBg)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: metric.type.iconName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(metric.type.iconTint)
                }
                
                // Titles
                VStack(alignment: .leading, spacing: 2) {
                    Text(metric.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text(metric.subtitle)
                        .font(.caption2)
                        .foregroundColor(.textCaption)
                }
                
                Spacer()
                
                // Value
                Text(metric.valueString)
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(metric.type == .incorrect ? .formBad : (metric.type == .perfect ? .formGood : .textPrimary))
            }
            
            // Progress Bar
            if metric.type != .total {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.borderMain)
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(metric.type.progressTint)
                            .frame(width: geo.size.width * CGFloat(metric.value) / CGFloat(max(1, metric.maxValue)), height: 4)
                    }
                }
                .frame(height: 4)
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack {
        MetricRowWithProgress(metric: SessionMetric(type: .perfect, title: "Perfect Form", subtitle: "Posisi tulang belakang lurus", valueString: "18s", value: 18, maxValue: 30))
        MetricRowWithProgress(metric: SessionMetric(type: .incorrect, title: "Incorrect Form", subtitle: "Kesalahan terdeteksi", valueString: "12s", value: 12, maxValue: 30))
    }
    .padding()
}
