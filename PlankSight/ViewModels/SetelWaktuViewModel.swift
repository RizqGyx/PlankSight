import Foundation
import Combine
import SwiftUI

class SetelWaktuViewModel: ObservableObject {

    // MARK: - Duration Selection
    @Published var selectedDuration: DurationType = .fixed(60)
    @Published var customSeconds: Int = 0

    // MARK: - Dashboard State
    @Published var weeklyProgress: [DailyProgress] = []
    @Published var weeklyTotal: Int = 0
    @Published var streak: Int = 0
    @Published var completedToday: Bool = false
    @Published var weekIndicators: [DayIndicator] = []
    @Published var badgeGroups: [BadgeGroup] = []

    // MARK: - Duration Types

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

    // MARK: - Computed Properties

    var options: [OptionData] {
        [
            OptionData(type: .fixed(60),  title: "60 Detik", subtitle: "Rekomendasi untuk pemula",  iconName: "clock"),
            OptionData(type: .fixed(30),  title: "30 Detik", subtitle: "Latihan singkat & intensif", iconName: "clock"),
            OptionData(type: .fixed(90),  title: "90 Detik", subtitle: "Level menengah",             iconName: "clock"),
            OptionData(type: .fixed(120), title: "2 Menit",  subtitle: "Untuk yang sudah terlatih",  iconName: "clock"),
            OptionData(
                type: .custom,
                title: "Kustom",
                subtitle: customSeconds > 0 ? "\(formatOptionDuration(customSeconds)) — custom" : "Atur sendiri durasinya",
                iconName: "plus"
            ),
        ]
    }

    var headerSubtitle: String {
        if completedToday {
            return streak > 1 ? "Streak \(streak) hari kamu terjaga! 🔥" : "Bagus! Sudah plank hari ini 💪"
        } else if streak > 0 {
            return "Ayo teruskan streak \(streak) harimu 🔥"
        } else {
            return "Mulai streak pertamamu hari ini! 🚀"
        }
    }

    var chartData: [DailyProgress] {
        weeklyProgress.isEmpty ? defaultWeeklyProgress : weeklyProgress
    }

    var displayedIndicators: [DayIndicator] {
        weekIndicators.isEmpty ? defaultIndicators : weekIndicators
    }

    // MARK: - Data Loading

    func loadDashboardData() {
        let repo = SessionRepository.shared
        repo.invalidateCache()
        streak = repo.currentStreak()
        completedToday = repo.hasCompletedToday()
        weeklyProgress = repo.weeklyProgress()
        weeklyTotal = weeklyProgress.reduce(0) { $0 + $1.duration }
        weekIndicators = repo.dayIndicators()
        badgeGroups = buildBadgeGroups(streak: streak, bestSeconds: repo.bestStrictSeconds())
    }

    // MARK: - Formatting (public for View)

    func formatWeeklyTotal(_ total: Int) -> String {
        guard total > 0 else { return "0s" }
        if total < 60 { return "\(total)s" }
        let m = total / 60
        let s = total % 60
        return s > 0 ? "\(m)m \(s)s" : "\(m)m"
    }

    // MARK: - Private Helpers

    private func buildBadgeGroups(streak: Int, bestSeconds: Int) -> [BadgeGroup] {
        let streakBadges: [AchievementBadge] = [
            AchievementBadge(id: "s3",   icon: "flame.fill",               title: "3 Hari",  color: .orange, isObtained: streak >= 3),
            AchievementBadge(id: "s7",   icon: "flame.fill",               title: "7 Hari",  color: .red,    isObtained: streak >= 7),
            AchievementBadge(id: "s14",  icon: "flame.fill",               title: "14 Hari", color: .red,    isObtained: streak >= 14),
            AchievementBadge(id: "s21",  icon: "bolt.fill",                title: "21 Hari", color: .purple, isObtained: streak >= 21),
            AchievementBadge(id: "s28",  icon: "calendar.badge.checkmark", title: "28 Hari", color: Color(red: 0.1, green: 0.6, blue: 0.5), isObtained: streak >= 28),
            AchievementBadge(id: "s365", icon: "crown.fill",               title: "1 Tahun", color: .yellow, isObtained: streak >= 365),
        ]

        let durationBadges: [AchievementBadge] = [
            AchievementBadge(id: "d30",  icon: "stopwatch.fill", title: "30 Detik", color: .blue,  isObtained: bestSeconds >= 30),
            AchievementBadge(id: "d60",  icon: "stopwatch.fill", title: "1 Menit",  color: .blue,  isObtained: bestSeconds >= 60),
            AchievementBadge(id: "d90",  icon: "stopwatch.fill", title: "1:30",     color: .cyan,  isObtained: bestSeconds >= 90),
            AchievementBadge(id: "d120", icon: "stopwatch.fill", title: "2 Menit",  color: .cyan,  isObtained: bestSeconds >= 120),
            AchievementBadge(id: "d150", icon: "stopwatch.fill", title: "2:30",     color: .teal,  isObtained: bestSeconds >= 150),
            AchievementBadge(id: "d180", icon: "stopwatch.fill", title: "3 Menit",  color: .teal,  isObtained: bestSeconds >= 180),
            AchievementBadge(id: "d240", icon: "stopwatch.fill", title: "4 Menit",  color: .green, isObtained: bestSeconds >= 240),
            AchievementBadge(id: "d300", icon: "stopwatch.fill", title: "5 Menit",  color: .green, isObtained: bestSeconds >= 300),
        ]

        let skillBadges: [AchievementBadge] = [
            AchievementBadge(id: "sk1", icon: "figure.stand",     title: "Pemula",   color: .blue,                                     isObtained: bestSeconds >= 60),
            AchievementBadge(id: "sk2", icon: "figure.walk",      title: "Menengah", color: .cyan,                                     isObtained: bestSeconds >= 120),
            AchievementBadge(id: "sk3", icon: "star.fill",        title: "Pro",      color: Color(red: 0.9, green: 0.75, blue: 0.1),   isObtained: bestSeconds >= 180),
            AchievementBadge(id: "sk4", icon: "star.circle.fill", title: "Ahli",     color: .orange,                                   isObtained: bestSeconds >= 300),
            AchievementBadge(id: "sk5", icon: "trophy.fill",      title: "Master",   color: Color(red: 0.85, green: 0.65, blue: 0.05), isObtained: bestSeconds >= 600),
        ]

        return [
            BadgeGroup(id: "streak", label: "Streak", badges: streakBadges),
            BadgeGroup(id: "durasi", label: "Durasi", badges: durationBadges),
            BadgeGroup(id: "skill",  label: "Skill",  badges: skillBadges),
        ]
    }

    private var defaultWeeklyProgress: [DailyProgress] {
        ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"].map { DailyProgress(day: $0, duration: 0) }
    }

    private var defaultIndicators: [DayIndicator] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayLabels = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"]
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today)!
        return (0..<7).map { i in
            let date = calendar.date(byAdding: .day, value: i, to: startOfWeek)!
            let label = dayLabels[calendar.component(.weekday, from: date) - 1]
            return DayIndicator(label: label, isCompleted: false, isToday: calendar.isDate(date, inSameDayAs: today))
        }
    }

    private func formatOptionDuration(_ t: Int) -> String {
        let h = t / 3600
        let m = (t % 3600) / 60
        let s = t % 60
        var parts: [String] = []
        if h > 0 { parts.append("\(h) Jam") }
        if m > 0 { parts.append("\(m) Menit") }
        if s > 0 { parts.append("\(s) Detik") }
        return parts.joined(separator: " ")
    }
}
