//
//  HistoryViewModel.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import Foundation
import SwiftUI
import Combine

enum QualityLevel {
    case excellent
    case warning
    case poor
    
    var color: Color {
        switch self {
        case .excellent: return .formGood
        case .warning: return .brand
        case .poor: return .formBad
        }
    }
    
    var bgColor: Color {
        switch self {
        case .excellent: return .formGoodBg
        case .warning: return .brandBg
        case .poor: return .formBadBg
        }
    }
    
    var borderColor: Color {
        switch self {
        case .excellent: return .formGoodBorder
        case .warning: return .brandBorder
        case .poor: return .formBadBorder
        }
    }
}

struct SessionTag: Identifiable {
    let id = UUID()
    let text: String
    let icon: String?
}

struct SessionHistory: Identifiable {
    let id = UUID()
    let dayString: String
    let monthString: String
    let title: String
    let durationText: String
    let qualityPercent: Int
    let qualityLevel: QualityLevel
    let tags: [SessionTag]
}

struct HistorySection: Identifiable {
    let id = UUID()
    let header: String
    let items: [SessionHistory]
}

class HistoryViewModel: ObservableObject {
    @Published var totalSessions: Int = 12
    @Published var averageQuality: Int = 87
    @Published var streak: Int = 4
    
    @Published var historySections: [HistorySection] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        let aprilItems = [
            SessionHistory(
                dayString: "09",
                monthString: "APR",
                title: "Free Time · 42 detik",
                durationText: "42 / ∞ detik",
                qualityPercent: 95,
                qualityLevel: .excellent,
                tags: [
                    SessionTag(text: "Semua form sempurna", icon: "checkmark")
                ]
            )
        ]
        
        let maretItems = [
            SessionHistory(
                dayString: "25",
                monthString: "MAR",
                title: "30 Detik",
                durationText: "21 / 30 detik",
                qualityPercent: 42,
                qualityLevel: .poor,
                tags: [
                    SessionTag(text: "Waktu tidak habis (-9s)", icon: nil),
                    SessionTag(text: "Pinggul tidak stabil", icon: nil)
                ]
            ),
            SessionHistory(
                dayString: "24",
                monthString: "MAR",
                title: "60 Detik",
                durationText: "60 / 60 detik",
                qualityPercent: 72,
                qualityLevel: .warning,
                tags: [
                    SessionTag(text: "Kepala tidak sejajar", icon: nil)
                ]
            )
        ]
        
        historySections = [
            HistorySection(header: "APRIL 2026", items: aprilItems),
            HistorySection(header: "MARET 2026", items: maretItems)
        ]
    }
}
