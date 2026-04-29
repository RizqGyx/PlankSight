//
//  Models.swift
//  PlankSight
//
//  Created by Muhammad Rizki on 22/04/26.
//

import Foundation
import SwiftUI

// MARK: - Camera Models
enum CameraPosition {
    case front
}

enum CameraSessionState {
    case searchingUser
    case waitingForPosition
    case tracking(sessionActive: Bool)
}

enum FormQuality: Equatable {
    case good
    case bad(errorMessage: String)
}

struct TrackedBodyPart: Identifiable {
    let id = UUID()
    let name: String
    var status: FormQuality
}

// MARK: - History Models
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
    let id: UUID
    let dayString: String
    let monthString: String
    let title: String
    let durationText: String
    let numericDuration: Int?
    let qualityPercent: Int
    let qualityLevel: QualityLevel
    let tags: [SessionTag]

    init(
        id: UUID = UUID(),
        dayString: String,
        monthString: String,
        title: String,
        durationText: String,
        numericDuration: Int?,
        qualityPercent: Int,
        qualityLevel: QualityLevel,
        tags: [SessionTag]
    ) {
        self.id = id
        self.dayString = dayString
        self.monthString = monthString
        self.title = title
        self.durationText = durationText
        self.numericDuration = numericDuration
        self.qualityPercent = qualityPercent
        self.qualityLevel = qualityLevel
        self.tags = tags
    }
}

struct HistorySection: Identifiable {
    let id = UUID()
    let header: String
    var items: [SessionHistory]
}

// MARK: - Summary Models
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

// MARK: - Home/Dashboard Models
struct DailyProgress: Identifiable {
    let id = UUID()
    let day: String
    let duration: Int // in seconds - absolute correct duration
}

struct DayIndicator: Identifiable {
    let id = UUID()
    let label: String       // "Sen", "Sel", dst.
    let isCompleted: Bool   // apakah sudah plank hari itu
    let isToday: Bool       // untuk highlight
}

struct MotivationCard: Identifiable {
    let id = UUID()
    let color: Color
    let emoji: String
    let title: String
    let message: String
}

// MARK: - Mistake & Session Persistence Models

struct RecordedMistake: Codable, Hashable, Identifiable {
    let id: UUID
    let typeName: String    // PlankFormMistakeType.rawValue
    let sessionSecond: Int  // seconds since session start when detected

    init(typeName: String, sessionSecond: Int) {
        self.id = UUID()
        self.typeName = typeName
        self.sessionSecond = sessionSecond
    }
}

struct SessionRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let totalDisplaySeconds: Int
    let strictSeconds: Int
    let targetDuration: Int?
    let mistakes: [RecordedMistake]

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        totalDisplaySeconds: Int,
        strictSeconds: Int,
        targetDuration: Int?,
        mistakes: [RecordedMistake] = []
    ) {
        self.id = id
        self.date = date
        self.totalDisplaySeconds = totalDisplaySeconds
        self.strictSeconds = strictSeconds
        self.targetDuration = targetDuration
        self.mistakes = mistakes
    }

    var qualityPercent: Int {
        guard totalDisplaySeconds > 0 else { return 0 }
        return min(100, Int(Double(strictSeconds) / Double(totalDisplaySeconds) * 100))
    }

    var qualityLevel: QualityLevel {
        switch qualityPercent {
        case 80...: return .excellent
        case 50..<80: return .warning
        default: return .poor
        }
    }

    func toSessionHistory() -> SessionHistory {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)

        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "id_ID")
        monthFormatter.dateFormat = "MMM"
        let month = monthFormatter.string(from: date).uppercased()

        let title: String
        let durationText: String
        if let target = targetDuration {
            title = "\(target) Detik"
            durationText = "\(strictSeconds) / \(target) detik"
        } else {
            title = "Free Time · \(totalDisplaySeconds) detik"
            durationText = "\(strictSeconds) / ∞ detik"
        }

        var tags: [SessionTag] = []
        if qualityPercent >= 90 {
            tags.append(SessionTag(text: "\(strictSeconds) detik sempurna", icon: "checkmark"))
        }
        if let target = targetDuration, totalDisplaySeconds < target {
            let diff = target - totalDisplaySeconds
            tags.append(SessionTag(text: "Waktu tidak habis (-\(diff)s)", icon: nil))
        }
        let uniqueMistakeNames = Array(Set(mistakes.map { $0.typeName })).prefix(2)
        for name in uniqueMistakeNames {
            if let type = PlankFormMistakeType(rawValue: name) {
                tags.append(SessionTag(text: "\(type.bodyPartMapping.partName) tidak ideal", icon: nil))
            }
        }

        return SessionHistory(
            id: self.id,
            dayString: String(day),
            monthString: month,
            title: title,
            durationText: durationText,
            numericDuration: targetDuration,
            qualityPercent: qualityPercent,
            qualityLevel: qualityLevel,
            tags: tags
        )
    }
}

// MARK: - Session Result (passed from Camera to Summary)
struct SessionResult: Hashable {
    let totalDisplaySeconds: Int
    let strictSeconds: Int
    let targetDuration: Int?
    let mistakes: [RecordedMistake]

    init(
        totalDisplaySeconds: Int,
        strictSeconds: Int,
        targetDuration: Int?,
        mistakes: [RecordedMistake] = []
    ) {
        self.totalDisplaySeconds = totalDisplaySeconds
        self.strictSeconds = strictSeconds
        self.targetDuration = targetDuration
        self.mistakes = mistakes
    }

    var qualityPercent: Int {
        guard totalDisplaySeconds > 0 else { return 0 }
        return min(100, Int((Double(strictSeconds) / Double(totalDisplaySeconds)) * 100))
    }
}

// MARK: - Achievement Models

struct AchievementBadge: Identifiable {
    let id: String
    let icon: String
    let title: String
    let color: Color
    let isObtained: Bool
}

struct BadgeGroup: Identifiable {
    let id: String
    let label: String
    let badges: [AchievementBadge]
    var obtainedCount: Int { badges.filter { $0.isObtained }.count }
}

// MARK: - Router Models
enum RootScreen {
    case splash
    case panduan
    case main
}

enum AppRoute: Hashable {
    case camera(duration: Int?)
    case summary(result: SessionResult)
    case history
}
