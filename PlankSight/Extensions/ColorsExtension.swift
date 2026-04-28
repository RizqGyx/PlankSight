//
//  Colors.swift
//  Berzki
//
//  Created by Muhammad Rizki on 12/04/26.
//

import SwiftUI
import UIKit

// MARK: - Adaptive Color Extension (Light / Dark)
extension Color {

    // ─────────────────────────────────────────────
    // MARK: Helper — adaptive color factory
    // ─────────────────────────────────────────────
    private static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        })
    }

    private static func hex(_ hex: String) -> UIColor {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3:
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        return UIColor(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: 1.0
        )
    }

    // ─────────────────────────────────────────────
    // MARK: BRAND — Burnt Amber
    // Light: #9A5610 / Dark: #F0A84E
    // ─────────────────────────────────────────────
    static let brand       = adaptive(light: hex("9A5610"), dark: hex("F0A84E"))
    static let brandDark   = adaptive(light: hex("7A4008"), dark: hex("D4893A"))

    static let brandBg = adaptive(
        light: hex("9A5610").withAlphaComponent(0.10),
        dark:  hex("F0A84E").withAlphaComponent(0.15)
    )
    static let brandBorder = adaptive(
        light: hex("9A5610").withAlphaComponent(0.28),
        dark:  hex("F0A84E").withAlphaComponent(0.35)
    )

    // ─────────────────────────────────────────────
    // MARK: STATUS — Form Good (Green)
    // Light: #1E7A40 / Dark: #4DC97A
    // ─────────────────────────────────────────────
    static let formGood = adaptive(light: hex("1E7A40"), dark: hex("4DC97A"))

    static let formGoodBg = adaptive(
        light: hex("1E7A40").withAlphaComponent(0.10),
        dark:  hex("4DC97A").withAlphaComponent(0.15)
    )
    static let formGoodBorder = adaptive(
        light: hex("1E7A40").withAlphaComponent(0.28),
        dark:  hex("4DC97A").withAlphaComponent(0.35)
    )

    // ─────────────────────────────────────────────
    // MARK: STATUS — Form Bad (Red)
    // Light: #B02020 / Dark: #FF6B6B
    // ─────────────────────────────────────────────
    static let formBad = adaptive(light: hex("B02020"), dark: hex("FF6B6B"))

    static let formBadBg = adaptive(
        light: hex("B02020").withAlphaComponent(0.10),
        dark:  hex("FF6B6B").withAlphaComponent(0.12)
    )
    static let formBadBorder = adaptive(
        light: hex("B02020").withAlphaComponent(0.28),
        dark:  hex("FF6B6B").withAlphaComponent(0.35)
    )

    // ─────────────────────────────────────────────
    // MARK: SURFACES
    // Light: #F9F6F0 / Dark: #1A1410
    // ─────────────────────────────────────────────
    static let bgPrimary = adaptive(light: hex("F9F6F0"), dark: hex("1A1410"))
    static let bgCard    = adaptive(light: hex("F2EBE0"), dark: hex("231C14"))
    static let bgInput   = adaptive(light: hex("E9DFD0"), dark: hex("2C221A"))
    static let bgPressed = adaptive(light: hex("DDD1BF"), dark: hex("352A1F"))

    // ─────────────────────────────────────────────
    // MARK: TEXT
    // Light base: #1E1208 / Dark base: #F9F6F0
    // ─────────────────────────────────────────────
    static let textPrimary = adaptive(
        light: hex("1E1208").withAlphaComponent(0.92),
        dark:  hex("F9F6F0").withAlphaComponent(0.92)
    )
    static let textBody = adaptive(
        light: hex("1E1208").withAlphaComponent(0.60),
        dark:  hex("F9F6F0").withAlphaComponent(0.65)
    )
    static let textCaption = adaptive(
        light: hex("1E1208").withAlphaComponent(0.50),
        dark:  hex("F9F6F0").withAlphaComponent(0.50)
    )
    static let textMuted = adaptive(
        light: hex("1E1208").withAlphaComponent(0.20),
        dark:  hex("F9F6F0").withAlphaComponent(0.20)
    )

    // ─────────────────────────────────────────────
    // MARK: BORDERS
    // ─────────────────────────────────────────────
    static let borderMain = adaptive(
        light: hex("1E1208").withAlphaComponent(0.10),
        dark:  hex("F9F6F0").withAlphaComponent(0.10)
    )
    static let borderSubtle = adaptive(
        light: hex("1E1208").withAlphaComponent(0.065),
        dark:  hex("F9F6F0").withAlphaComponent(0.065)
    )

    // ─────────────────────────────────────────────
    // MARK: SPECIAL — Dark-mode button text
    // On brand-colored buttons, dark mode uses dark text
    // ─────────────────────────────────────────────
    static let brandButtonText = adaptive(
        light: UIColor.white,
        dark:  hex("1A1410")
    )

    // ─────────────────────────────────────────────
    // MARK: Hex initializer (retained for any ad-hoc usage)
    // ─────────────────────────────────────────────
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
