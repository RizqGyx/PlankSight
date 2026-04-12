//
//  SummaryViewModel.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import Foundation
import SwiftUI
import Combine

enum MetricType {
    case total
    case perfect
    case incorrect
    
    var iconName: String {
        switch self {
        case .total: return "clock"
        case .perfect: return "checkmark"
        case .incorrect: return "xmark"
        }
    }
    
    var iconTint: Color {
        switch self {
        case .total: return .textBody
        case .perfect: return .formGood
        case .incorrect: return .formBad
        }
    }
    
    var iconBg: Color {
        switch self {
        case .total: return .borderMain
        case .perfect: return .formGoodBg
        case .incorrect: return .formBadBg
        }
    }
    
    var progressTint: Color {
        switch self {
        case .total: return .clear
        case .perfect: return .formGood
        case .incorrect: return .formBad
        }
    }
}

struct SessionMetric: Identifiable {
    let id = UUID()
    let type: MetricType
    let title: String
    let subtitle: String
    let valueString: String
    let value: Int
    let maxValue: Int 
}

struct ErrorAnalysis: Identifiable {
    let id = UUID()
    let timestamp: String
    let title: String
    let descriptionHTML: String
    let tip: String
    let imageName: String
}

class SummaryViewModel: ObservableObject {
    @Published var dateString: String = "09 April 2026 · 30 Detik"
    @Published var qualityScore: Int = 60
    
    @Published var metrics: [SessionMetric] = []
    
    @Published var errors: [ErrorAnalysis] = []
    @Published var currentErrorIndex: Int = 0
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        metrics = [
            SessionMetric(type: .total, title: "Total Plank", subtitle: "Durasi keseluruhan sesi", valueString: "30s", value: 30, maxValue: 30),
            SessionMetric(type: .perfect, title: "Perfect Form", subtitle: "Posisi tulang belakang lurus sempurna", valueString: "18s", value: 18, maxValue: 30),
            SessionMetric(type: .incorrect, title: "Incorrect Form", subtitle: "Kesalahan posisi terdeteksi", valueString: "12s", value: 12, maxValue: 30)
        ]
        
        errors = [
            ErrorAnalysis(
                timestamp: "00:12",
                title: "Pinggul",
                descriptionHTML: "Di detik **00:12**, pinggul kamu turun di bawah garis ideal. Kondisi ini membebani **lower back** dan mengurangi efektivitas latihan core.",
                tip: "Tips: Kontraksikan otot perut, dorong tumit ke belakang, bayangkan papan lurus di punggungmu.",
                imageName: "pinggul_rendah_mock"
            ),
            ErrorAnalysis(
                timestamp: "00:24",
                title: "Kepala",
                descriptionHTML: "Di detik **00:24**, kepala kamu menunduk. Jaga pandangan ke bawah agar leher sejajar.",
                tip: "Tips: Pandang lantai di antara kedua tangan untuk menjaga leher netral.",
                imageName: "kepala_menunduk_mock"
            )
        ]
    }
    
    func retrySession() {
        print("Retry Session")
    }
    
    func finishSession() {
        print("Finish Session")
    }
}
