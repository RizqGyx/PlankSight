import Foundation

final class SessionRepository {
    static let shared = SessionRepository()
    private init() {}

    private let fileURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("planksight_sessions.json")
    }()

    private var cache: [SessionRecord]?

    // MARK: - CRUD

    func save(_ record: SessionRecord) {
        var all = loadAll()
        all.insert(record, at: 0)
        cache = all
        persist(all)
    }

    func loadAll() -> [SessionRecord] {
        if let cached = cache { return cached }
        guard
            let data = try? Data(contentsOf: fileURL),
            let decoded = try? JSONDecoder().decode([SessionRecord].self, from: data)
        else { return [] }
        cache = decoded
        return decoded
    }

    func load(id: UUID) -> SessionRecord? {
        loadAll().first { $0.id == id }
    }

    func delete(ids: Set<UUID>) {
        var all = loadAll()
        all.removeAll { ids.contains($0.id) }
        cache = all
        persist(all)
    }

    func invalidateCache() { cache = nil }

    private func persist(_ records: [SessionRecord]) {
        guard let data = try? JSONEncoder().encode(records) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    // MARK: - Dashboard Stats

    func weeklyProgress() -> [DailyProgress] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayLabels = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"]
        let all = loadAll()
        return (0..<7).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let label = dayLabels[calendar.component(.weekday, from: date) - 1]
            let total = all
                .filter { calendar.isDate($0.date, inSameDayAs: date) }
                .reduce(0) { $0 + $1.strictSeconds }
            return DailyProgress(day: label, duration: total)
        }
    }

    func currentStreak() -> Int {
        let calendar = Calendar.current
        let all = loadAll()
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        while all.contains(where: { calendar.isDate($0.date, inSameDayAs: checkDate) }) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        return streak
    }

    func hasCompletedToday() -> Bool {
        let calendar = Calendar.current
        return loadAll().contains { calendar.isDateInToday($0.date) }
    }

    func averageQuality() -> Int {
        let all = loadAll()
        guard !all.isEmpty else { return 0 }
        return all.reduce(0) { $0 + $1.qualityPercent } / all.count
    }

    func totalCount() -> Int { loadAll().count }

    func dayIndicators() -> [DayIndicator] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayLabels = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"]
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today)!
        let all = loadAll()
        return (0..<7).map { i in
            let date = calendar.date(byAdding: .day, value: i, to: startOfWeek)!
            let label = dayLabels[calendar.component(.weekday, from: date) - 1]
            let completed = all.contains { calendar.isDate($0.date, inSameDayAs: date) }
            let isToday = calendar.isDate(date, inSameDayAs: today)
            return DayIndicator(label: label, isCompleted: completed, isToday: isToday)
        }
    }

    // MARK: - Badge Checks

    func hasEverReached60Seconds() -> Bool {
        loadAll().contains { $0.totalDisplaySeconds >= 60 }
    }

    func hasPerfectSession() -> Bool {
        loadAll().contains { $0.qualityPercent == 100 }
    }

    func isMasterPlank() -> Bool {
        loadAll().count >= 50
    }

    func bestStrictSeconds() -> Int {
        loadAll().map { $0.strictSeconds }.max() ?? 0
    }
}
