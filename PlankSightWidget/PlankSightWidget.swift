//
//  PlankSightWidget.swift
//  PlankSightWidget
//
//  Created by Muhammad Rizki on 22/04/26.
//

import WidgetKit
import SwiftUI

// MARK: - Shared UserDefaults (App Group)
// IMPORTANT: Enable App Group "group.com.berzki.planksight" in Signing & Capabilities
// for both PlankSight and PlankSightWidget targets.
private let sharedDefaults = UserDefaults(suiteName: "group.com.berzki.planksight") ?? .standard
private let streakKey = "currentStreak"
private let lastSessionDateKey = "lastSessionDate"
private let lastQualityKey = "lastQualityPercent"
private let lastDurationKey = "lastDurationSeconds"

// MARK: - Timeline Entry

struct PlankEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let isCompletedToday: Bool
    let lastQualityPercent: Int
    let lastDurationSeconds: Int
}

// MARK: - Provider

struct PlankProvider: TimelineProvider {

    func placeholder(in context: Context) -> PlankEntry {
        PlankEntry(date: .now, streak: 5, isCompletedToday: false,
                   lastQualityPercent: 88, lastDurationSeconds: 45)
    }

    func getSnapshot(in context: Context, completion: @escaping (PlankEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PlankEntry>) -> Void) {
        let entry = makeEntry()
        // Refresh every 30 minutes so widget stays up to date
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func makeEntry() -> PlankEntry {
        let streak = sharedDefaults.integer(forKey: streakKey)
        let lastQuality = sharedDefaults.integer(forKey: lastQualityKey)
        let lastDuration = sharedDefaults.integer(forKey: lastDurationKey)

        let isToday: Bool = {
            guard let last = sharedDefaults.object(forKey: lastSessionDateKey) as? Date else { return false }
            return Calendar.current.isDateInToday(last)
        }()

        return PlankEntry(
            date: .now,
            streak: streak,
            isCompletedToday: isToday,
            lastQualityPercent: lastQuality,
            lastDurationSeconds: lastDuration
        )
    }
}

// MARK: - Design Helpers

private extension Color {
    static let brandAmber   = Color(red: 0.604, green: 0.337, blue: 0.063)   // #9A5610 light
    static let warmBg       = Color(red: 0.949, green: 0.922, blue: 0.878)   // #F2EBE0
    static let warmBgDeep   = Color(red: 0.976, green: 0.965, blue: 0.941)   // #F9F6F0
    static let textDark     = Color(red: 0.118, green: 0.071, blue: 0.031)   // #1E1208
    static let formGreen    = Color(red: 0.118, green: 0.478, blue: 0.251)   // #1E7A40
    static let formRed      = Color(red: 0.690, green: 0.125, blue: 0.125)   // #B02020
}

private func streakFlame(_ streak: Int) -> String {
    switch streak {
    case 0:       return "🌱"
    case 1...3:   return "🔥"
    case 4...6:   return "🔥"
    case 7...13:  return "🔥🔥"
    case 14...29: return "🔥🔥🔥"
    default:      return "👑"
    }
}

private func motivationLine(streak: Int, isToday: Bool) -> String {
    if isToday {
        switch streak {
        case 0...3: return "Plank selesai hari ini!"
        case 4...6: return "Konsisten \(streak) hari, luar biasa!"
        case 7...13: return "\(streak) hari berturut-turut 🎯"
        default:    return "Legenda \(streak) hari! 👑"
        }
    } else {
        switch streak {
        case 0:     return "Mulai streakmu sekarang!"
        case 1...3: return "Jaga streak \(streak) hari kamu!"
        case 4...6: return "\(streak) hari! Jangan putus sekarang."
        case 7...29: return "WOW \(streak) hari! Pertahankan!"
        default:    return "\(streak) hari! Tulis sejarahmu."
        }
    }
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: PlankEntry

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                // Top row: logo + flame
                HStack(alignment: .center) {
                    // App name
                    HStack(spacing: 2) {
                        Text("PLANK")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundColor(Color.textDark.opacity(0.85))
                        Text("SIGHT")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundColor(Color.brandAmber)
                    }
                    Spacer()
                    Text(streakFlame(entry.streak))
                        .font(.system(size: 14))
                }
                .padding(.bottom, 6)

                // Streak number
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(entry.streak)")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(Color.textDark)
                    Text("hari")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.textDark.opacity(0.5))
                        .padding(.bottom, 6)
                }
                .padding(.bottom, 2)

                // Status badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(entry.isCompletedToday ? Color.formGreen : Color.brandAmber)
                        .frame(width: 6, height: 6)
                    Text(entry.isCompletedToday ? "Selesai hari ini" : "Belum plank hari ini")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(entry.isCompletedToday ? Color.formGreen : Color.brandAmber)
                }

                Spacer()

                // CTA
                if !entry.isCompletedToday {
                    Text("Mulai sekarang →")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.brandAmber)
                        .clipShape(Capsule())
                }
            }
            .padding(14)
        }
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: PlankEntry

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                // Left column — streak + motivation
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack(spacing: 3) {
                        Text("PLANK")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(Color.textDark.opacity(0.85))
                        Text("SIGHT")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(Color.brandAmber)
                    }
                    .padding(.bottom, 8)

                    // Streak
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text(streakFlame(entry.streak))
                            .font(.system(size: 22))
                        Text("\(entry.streak)")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundColor(Color.textDark)
                        VStack(alignment: .leading, spacing: 0) {
                            Text("hari")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(Color.textDark.opacity(0.45))
                            Text("streak")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.textDark.opacity(0.35))
                        }
                        .padding(.bottom, 6)
                    }

                    // Motivation line
                    Text(motivationLine(streak: entry.streak, isToday: entry.isCompletedToday))
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.textDark.opacity(0.7))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    // Status + CTA
                    if entry.isCompletedToday {
                        Label("Selesai hari ini", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color.formGreen)
                    } else {
                        Text("Mulai plank sekarang →")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.brandAmber)
                            .clipShape(Capsule())
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Divider
                Rectangle()
                    .fill(Color.textDark.opacity(0.08))
                    .frame(width: 1)
                    .padding(.vertical, 16)

                // Right column — last session stats
                VStack(alignment: .leading, spacing: 8) {
                    Text("SESI TERAKHIR")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundColor(Color.textDark.opacity(0.4))
                        .tracking(1)

                    // Quality
                    statRow(
                        icon: "star.fill",
                        iconColor: Color.brandAmber,
                        label: "Kualitas",
                        value: entry.lastQualityPercent > 0 ? "\(entry.lastQualityPercent)%" : "—"
                    )

                    // Duration
                    statRow(
                        icon: "clock.fill",
                        iconColor: Color.textDark.opacity(0.4),
                        label: "Durasi",
                        value: entry.lastDurationSeconds > 0 ? "\(entry.lastDurationSeconds)d" : "—"
                    )

                    // Quality bar
                    if entry.lastQualityPercent > 0 {
                        VStack(alignment: .leading, spacing: 3) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.textDark.opacity(0.08))
                                        .frame(height: 5)
                                    Capsule()
                                        .fill(qualityColor(entry.lastQualityPercent))
                                        .frame(width: geo.size.width * CGFloat(entry.lastQualityPercent) / 100, height: 5)
                                }
                            }
                            .frame(height: 5)
                        }
                    }

                    Spacer()

                    // Days of week dots
                    HStack(spacing: 4) {
                        ForEach(Array(weekDots(streak: entry.streak, isToday: entry.isCompletedToday).enumerated()), id: \.offset) { index, filled in
                            Circle()
                                .fill(filled ? Color.brandAmber : Color.textDark.opacity(0.12))
                                .frame(width: 7, height: 7)
                        }
                    }
                    Text("7 hari terakhir")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(Color.textDark.opacity(0.35))
                }
                .padding(.vertical, 16)
                .padding(.trailing, 16)
                .frame(width: 120, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private func statRow(icon: String, iconColor: Color, label: String, value: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 14)
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(Color.textDark.opacity(0.4))
                Text(value)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textDark.opacity(0.85))
            }
        }
    }

    private func qualityColor(_ percent: Int) -> Color {
        if percent >= 80 { return Color.formGreen }
        if percent >= 60 { return Color.brandAmber }
        return Color.formRed
    }

    private func weekDots(streak: Int, isToday: Bool) -> [Bool] {
        var dots = Array(repeating: false, count: 7)
        let filled = min(streak + (isToday ? 1 : 0), 7)
        for i in (7 - filled)..<7 {
            dots[i] = true
        }
        return dots
    }
}

// MARK: - Entry View Router

struct PlankSightWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: PlankEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Declaration

struct PlankSightWidget: Widget {
    let kind: String = "PlankSightWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlankProvider()) { entry in
            PlankSightWidgetEntryView(entry: entry)
                .containerBackground(Color.warmBgDeep, for: .widget)
        }
        .configurationDisplayName("PlankSight")
        .description("Pantau streak dan ingatkan dirimu untuk plank hari ini.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Previews

#Preview("Small – Belum plank", as: .systemSmall) {
    PlankSightWidget()
} timeline: {
    PlankEntry(date: .now, streak: 6, isCompletedToday: false, lastQualityPercent: 88, lastDurationSeconds: 45)
}

#Preview("Small – Selesai", as: .systemSmall) {
    PlankSightWidget()
} timeline: {
    PlankEntry(date: .now, streak: 7, isCompletedToday: true, lastQualityPercent: 92, lastDurationSeconds: 60)
}

#Preview("Medium – Belum plank", as: .systemMedium) {
    PlankSightWidget()
} timeline: {
    PlankEntry(date: .now, streak: 12, isCompletedToday: false, lastQualityPercent: 76, lastDurationSeconds: 45)
}

#Preview("Medium – Selesai", as: .systemMedium) {
    PlankSightWidget()
} timeline: {
    PlankEntry(date: .now, streak: 12, isCompletedToday: true, lastQualityPercent: 92, lastDurationSeconds: 60)
}
