import Foundation

nonisolated struct CareHabit: Codable, Sendable, Identifiable {
    let id: UUID
    let title: String
    let icon: String
    let category: CareCategory
    var streak: Int
    var lastCompleted: Date?
    var completedDates: [Date]

    var isCompletedToday: Bool {
        guard let last = lastCompleted else { return false }
        return Calendar.current.isDateInToday(last)
    }

    init(id: UUID = UUID(), title: String, icon: String, category: CareCategory, streak: Int = 0, lastCompleted: Date? = nil, completedDates: [Date] = []) {
        self.id = id
        self.title = title
        self.icon = icon
        self.category = category
        self.streak = streak
        self.lastCompleted = lastCompleted
        self.completedDates = completedDates
    }
}

nonisolated enum CareCategory: String, Codable, Sendable, CaseIterable, Identifiable {
    case health = "HEALTH"
    case nutrition = "NUTRITION"
    case wellness = "WELLNESS"
    case baby = "BABY"

    nonisolated var id: String { rawValue }

    var title: String {
        switch self {
        case .health: "Saúde"
        case .nutrition: "Nutrição"
        case .wellness: "Bem-estar"
        case .baby: "Bebê"
        }
    }

    var icon: String {
        switch self {
        case .health: "heart.fill"
        case .nutrition: "leaf.fill"
        case .wellness: "sparkles"
        case .baby: "figure.and.child.holdinghands"
        }
    }

    var color: String {
        switch self {
        case .health: "rose"
        case .nutrition: "sage"
        case .wellness: "roseDark"
        case .baby: "sageDark"
        }
    }
}
