import Foundation
import SwiftUI
import Combine

class HistoryViewModel: ObservableObject {
    @Published var totalSessions: Int = 0
    @Published var averageQuality: Int = 0
    @Published var streak: Int = 0
    @Published var historySections: [HistorySection] = []
    @Published var selectedItems: Set<UUID> = []
    @Published var availableYears: [Int] = []
    @Published var selectedYear: Int? = nil

    var filteredSections: [HistorySection] {
        guard let year = selectedYear else { return historySections }
        return historySections.filter { $0.header.hasSuffix(String(year)) }
    }

    init() {
        loadSessions()
    }

    func loadSessions() {
        let repo = SessionRepository.shared
        repo.invalidateCache()
        let records = repo.loadAll()

        totalSessions = records.count
        averageQuality = repo.averageQuality()
        streak = repo.currentStreak()
        historySections = groupByMonth(records)

        let years = Array(Set(records.map {
            Calendar.current.component(.year, from: $0.date)
        })).sorted(by: >)
        availableYears = years
        if selectedYear == nil || !years.contains(selectedYear ?? 0) {
            selectedYear = years.first
        }
    }

    private func groupByMonth(_ records: [SessionRecord]) -> [HistorySection] {
        guard !records.isEmpty else { return [] }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "MMMM yyyy"

        var grouped: [(key: String, date: Date, items: [SessionHistory])] = []
        var seen: [String: Int] = [:]

        for record in records {
            let key = formatter.string(from: record.date).uppercased()
            if let idx = seen[key] {
                grouped[idx].items.append(record.toSessionHistory())
            } else {
                seen[key] = grouped.count
                grouped.append((key: key, date: record.date, items: [record.toSessionHistory()]))
            }
        }

        return grouped
            .sorted { $0.date > $1.date }
            .map { HistorySection(header: $0.key, items: $0.items) }
    }

    // MARK: - Selection & Deletion

    func toggleSelection(for itemId: UUID) {
        if selectedItems.contains(itemId) {
            selectedItems.remove(itemId)
        } else {
            selectedItems.insert(itemId)
        }
    }

    func selectAll() {
        let allIds = filteredSections.flatMap { $0.items.map { $0.id } }
        selectedItems = Set(allIds)
    }

    var allVisibleSelected: Bool {
        let allIds = filteredSections.flatMap { $0.items.map { $0.id } }
        return !allIds.isEmpty && allIds.allSatisfy { selectedItems.contains($0) }
    }

    func deleteItems(ids: Set<UUID>) {
        guard !ids.isEmpty else { return }
        SessionRepository.shared.delete(ids: ids)
        loadSessions()
        selectedItems.removeAll()
    }
}
