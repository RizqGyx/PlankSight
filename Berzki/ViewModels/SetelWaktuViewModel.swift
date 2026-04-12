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
        let badge: String?
    }
    
    let options: [OptionData] = [
        OptionData(type: .freeTime, title: "Free Time", subtitle: "Tanpa batas waktu, hentikan kapan saja", iconName: "infinity", badge: nil),
        OptionData(type: .fixed(60), title: "60 Detik", subtitle: "Rekomendasi untuk pemula", iconName: "clock", badge: "Populer"),
        OptionData(type: .fixed(30), title: "30 Detik", subtitle: "Latihan singkat & intensif", iconName: "clock", badge: nil),
        OptionData(type: .fixed(90), title: "90 Detik", subtitle: "Level menengah", iconName: "clock", badge: nil),
        OptionData(type: .fixed(120), title: "2 Menit", subtitle: "Untuk yang sudah terlatih", iconName: "clock", badge: nil),
        OptionData(type: .custom, title: "Kustom", subtitle: "Atur sendiri durasinya", iconName: "plus", badge: nil)
    ]
    
    func startSession() {
        print("Mulai Sesi dengan durasi: \(selectedDuration)")
    }
}
