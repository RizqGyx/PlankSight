import Charts
import SwiftUI

struct SetelWaktuView: View {
    @StateObject private var viewModel = SetelWaktuViewModel()
    @EnvironmentObject var appRouter: AppRouter
    @State private var showTargetOptions = false

    // Dashboard state (loaded from SessionRepository)
    @State private var weeklyProgress: [DailyProgress] = []
    @State private var weeklyTotal: Int = 0
    @State private var streak: Int = 0
    @State private var completedToday: Bool = false
    @State private var weekIndicators: [DayIndicator] = []
    @State private var badgeGroups: [BadgeGroup] = []

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PlankSight")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                        Text(headerSubtitle)
                            .font(.footnote)
                            .foregroundColor(.textCaption)
                    }
                    Spacer()
                    Button(action: {
                        appRouter.goToPanduan()
                    }) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.textCaption)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // MARK: - Day Indicator
                        DayIndicatorView(indicators: weekIndicators.isEmpty ? defaultIndicators() : weekIndicators)

                        // MARK: - Progress Chart
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Aktivitas Minggu Ini")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                Button(action: {
                                    appRouter.navigate(to: .history)
                                }) {
                                    Text("Riwayat")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.brand)
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text(formatSeconds(weeklyTotal))
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(.brand)
                                    Text("minggu ini")
                                        .font(.caption)
                                        .foregroundColor(.textCaption)
                                }

                                Text("Detik form benar per hari")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textCaption)
                                    .padding(.bottom, 2)

                                let chartData = weeklyProgress.isEmpty ? defaultWeeklyProgress() : weeklyProgress
                                Chart(chartData) { data in
                                    BarMark(
                                        x: .value("Hari", data.day),
                                        y: .value("Detik", data.duration)
                                    )
                                    .foregroundStyle(
                                        data.duration > 0
                                            ? Color.brand.gradient
                                            : Color.textMuted.opacity(0.12).gradient
                                    )
                                    .cornerRadius(6)
                                    .annotation(position: .top, alignment: .center, spacing: 3) {
                                        if data.duration > 0 {
                                            Text("\(data.duration)s")
                                                .font(.system(size: 9, weight: .bold))
                                                .foregroundColor(.brand)
                                        }
                                    }
                                }
                                .chartYAxis(.hidden)
                                .chartXAxis {
                                    AxisMarks { value in
                                        AxisValueLabel {
                                            if let s = value.as(String.self) {
                                                Text(s)
                                                    .font(.caption2)
                                                    .foregroundColor(.textCaption)
                                            }
                                        }
                                    }
                                }
                                .frame(height: 160)
                            }
                            .padding(16)
                            .background(Color.bgCard)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20).stroke(Color.borderMain, lineWidth: 1)
                            )
                        }

                        // MARK: - Motivation Card
                        MotivationCardView(
                            card: MotivationCardHelper.generateMotivationCard(
                                lastSessionDate: completedToday ? Date() : Date().addingTimeInterval(-86400),
                                streak: streak,
                                today: completedToday
                            )
                        )

                        // MARK: - Gamification (Badges)
                        VStack(alignment: .leading, spacing: 16) {
                            let totalObtained = badgeGroups.reduce(0) { $0 + $1.obtainedCount }
                            let totalBadges   = badgeGroups.reduce(0) { $0 + $1.badges.count }

                            HStack(alignment: .firstTextBaseline) {
                                Text("Pencapaianmu")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                Text("\(totalObtained)/\(totalBadges) terbuka")
                                    .font(.caption)
                                    .foregroundColor(.textCaption)
                            }

                            VStack(spacing: 20) {
                                ForEach(badgeGroups) { group in
                                    BadgeGroupSection(group: group)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }

                // MARK: - Bottom CTA
                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "Mulai Plank Sekarang",
                        iconName: "play.circle.fill"
                    ) {
                        appRouter.navigate(to: .camera(duration: nil))
                    }
                    .padding(.horizontal)

                    Button(action: {
                        showTargetOptions = true
                    }) {
                        Text("Tetapkan Target Waktu Khusus")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.brand)
                    }
                }
                .padding(.bottom, 16)
                .background(Color.bgPrimary)
            }
        }
        .navigationBarHidden(true)
        .onAppear { loadDashboardData() }
        .sheet(isPresented: $showTargetOptions) {
            TargetWaktuSheet(viewModel: viewModel, appRouter: appRouter)
                .presentationDetents([.fraction(0.65)])
        }
    }

    // MARK: - Data Loading

    private func loadDashboardData() {
        let repo = SessionRepository.shared
        repo.invalidateCache()
        streak = repo.currentStreak()
        completedToday = repo.hasCompletedToday()
        weeklyProgress = repo.weeklyProgress()
        weeklyTotal = weeklyProgress.reduce(0) { $0 + $1.duration }
        weekIndicators = repo.dayIndicators()
        badgeGroups = buildBadgeGroups(streak: streak, bestSeconds: repo.bestStrictSeconds())
    }

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
            AchievementBadge(id: "sk1", icon: "figure.stand",     title: "Pemula",   color: .blue,                                       isObtained: bestSeconds >= 60),
            AchievementBadge(id: "sk2", icon: "figure.walk",      title: "Menengah", color: .cyan,                                       isObtained: bestSeconds >= 120),
            AchievementBadge(id: "sk3", icon: "star.fill",        title: "Pro",      color: Color(red: 0.9, green: 0.75, blue: 0.1),     isObtained: bestSeconds >= 180),
            AchievementBadge(id: "sk4", icon: "star.circle.fill", title: "Ahli",     color: .orange,                                     isObtained: bestSeconds >= 300),
            AchievementBadge(id: "sk5", icon: "trophy.fill",      title: "Master",   color: Color(red: 0.85, green: 0.65, blue: 0.05),   isObtained: bestSeconds >= 600),
        ]

        return [
            BadgeGroup(id: "streak", label: "Streak",  badges: streakBadges),
            BadgeGroup(id: "durasi", label: "Durasi",  badges: durationBadges),
            BadgeGroup(id: "skill",  label: "Skill",   badges: skillBadges),
        ]
    }

    // MARK: - Helpers

    private var headerSubtitle: String {
        if completedToday {
            return streak > 1 ? "Streak \(streak) hari kamu terjaga! 🔥" : "Bagus! Sudah plank hari ini 💪"
        } else if streak > 0 {
            return "Ayo teruskan streak \(streak) harimu 🔥"
        } else {
            return "Mulai streak pertamamu hari ini! 🚀"
        }
    }

    private func formatSeconds(_ total: Int) -> String {
        guard total > 0 else { return "0s" }
        if total < 60 { return "\(total)s" }
        let m = total / 60
        let s = total % 60
        return s > 0 ? "\(m)m \(s)s" : "\(m)m"
    }

    private func defaultWeeklyProgress() -> [DailyProgress] {
        let labels = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"]
        return labels.map { DailyProgress(day: $0, duration: 0) }
    }

    private func defaultIndicators() -> [DayIndicator] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayLabels = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"]
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today)!
        return (0..<7).map { i in
            let date = calendar.date(byAdding: .day, value: i, to: startOfWeek)!
            let label = dayLabels[calendar.component(.weekday, from: date) - 1]
            let isToday = calendar.isDate(date, inSameDayAs: today)
            return DayIndicator(label: label, isCompleted: false, isToday: isToday)
        }
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

// MARK: - Badge Group Section

struct BadgeGroupSection: View {
    let group: BadgeGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(group.label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textBody)
                Spacer()
                Text("\(group.obtainedCount)/\(group.badges.count)")
                    .font(.caption2)
                    .foregroundColor(.textCaption)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(group.badges) { badge in
                        BadgeItem(badge: badge)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }
        }
    }
}



#Preview {
    SetelWaktuView()
        .environmentObject(AppRouter())
}
