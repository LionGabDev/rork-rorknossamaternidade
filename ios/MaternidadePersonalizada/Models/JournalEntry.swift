import Foundation

nonisolated struct JournalNote: Codable, Sendable, Identifiable {
    var id: UUID = UUID()
    var date: Date = Date()
    var text: String = ""
}

nonisolated struct SymptomLog: Codable, Sendable, Identifiable {
    var id: UUID = UUID()
    var date: Date = Date()
    var symptoms: [String] = []
    var note: String = ""
}

nonisolated struct MilestoneItem: Codable, Sendable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
}

nonisolated struct MoodEntry: Codable, Sendable, Identifiable {
    var id: UUID = UUID()
    var date: Date = Date()
    var mood: String = ""
    var note: String = ""
}

nonisolated struct HabitItem: Codable, Sendable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var icon: String
    var streak: Int = 0
    var lastCompleted: Date?

    var isCompletedToday: Bool {
        guard let last = lastCompleted else { return false }
        return Calendar.current.isDateInToday(last)
    }
}
