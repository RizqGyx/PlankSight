//
//  SetelWaktuViewModel.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import Foundation
import Combine

class SetelWaktuViewModel: ObservableObject {
    @Published var selectedDuration: DurationType = .fixed(60)
    @Published var customSeconds: Int = 0
    
    enum DurationType: Hashable {
        case freeTime
        case fixed(Int)
        case custom
    }
    
    struct OptionData: Identifiable {
        let id = UUID()
        let type: DurationType
        let title: String
        let subtitle: String
        let iconName: String
    }
    
    var options: [OptionData] {
        return [
            OptionData(type: .fixed(60), title: "60 Detik", subtitle: "Rekomendasi untuk pemula", iconName: "clock"),
            OptionData(type: .fixed(30), title: "30 Detik", subtitle: "Latihan singkat & intensif", iconName: "clock"),
            OptionData(type: .fixed(90), title: "90 Detik", subtitle: "Level menengah", iconName: "clock"),
            OptionData(type: .fixed(120), title: "2 Menit", subtitle: "Untuk yang sudah terlatih", iconName: "clock"),
            OptionData(type: .custom, title: "Kustom", 
                       subtitle: customSeconds > 0 ? "\(formatSeconds(customSeconds)) — custom" : "Atur sendiri durasinya", 
                       iconName: "plus")
        ]
    }
    
    private func formatSeconds(_ t: Int) -> String {
        let h = t / 3600
        let m = (t % 3600) / 60
        let s = t % 60
        var parts: [String] = []
        if h > 0 { parts.append("\(h) Jam") }
        if m > 0 { parts.append("\(m) Menit") }
        if s > 0 { parts.append("\(s) Detik") }
        return parts.joined(separator: " ")
    }
    
    func startSession() {
        if selectedDuration == .custom {
            print("Mulai Sesi (Kustom) dengan durasi: \(customSeconds) detik")
        } else {
            print("Mulai Sesi dengan durasi: \(selectedDuration)")
        }
    }
}
