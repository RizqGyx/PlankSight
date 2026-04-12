//
//  Colors.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI

// MARK: - Color Extension
extension Color {
    // BRAND — Burnt Amber (UI chrome: buttons, nav, aksen)
    static let brand        = Color(hex: "#C4751A")
    static let brandDark    = Color(hex: "#A35E0E")
    static let brandBg      = Color(hex: "#C4751A").opacity(0.10)
    static let brandBorder  = Color(hex: "#C4751A").opacity(0.28)

    // STATUS: Form Benar (HANYA untuk feedback postur)
    static let formGood     = Color(hex: "#2D9B5A")
    static let formGoodBg   = Color(hex: "#2D9B5A").opacity(0.10)
    static let formGoodBorder = Color(hex: "#2D9B5A").opacity(0.28)

    // STATUS: Form Error (HANYA untuk feedback postur)
    static let formBad      = Color(hex: "#C0392B")
    static let formBadBg    = Color(hex: "#C0392B").opacity(0.10)
    static let formBadBorder = Color(hex: "#C0392B").opacity(0.28)

    // SURFACES — Warm White
    static let bgPrimary    = Color(hex: "#F9F6F0") 
    static let bgCard       = Color(hex: "#F2EBE0")
    static let bgInput      = Color(hex: "#E9DFD0")
    static let bgPressed    = Color(hex: "#DDD1BF")

    // TEXT — Espresso
    static let textPrimary  = Color(hex: "#1E1208").opacity(0.92)
    static let textBody     = Color(hex: "#1E1208").opacity(0.58)
    static let textCaption  = Color(hex: "#1E1208").opacity(0.38)
    static let textMuted    = Color(hex: "#1E1208").opacity(0.20)

    // BORDER
    static let borderMain   = Color(hex: "#1E1208").opacity(0.10)
    static let borderSubtle = Color(hex: "#1E1208").opacity(0.065)
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
