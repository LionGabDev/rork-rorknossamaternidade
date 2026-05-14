import Foundation

nonisolated enum StorageKeys: Sendable {
    private static let namespace = "mp_v1_"
    static let storageVersion = "\(namespace)version"
    static let currentVersion = 1

    static let profile = "\(namespace)user_profile"
    static let journalNotes = "\(namespace)journal_notes"
    static let journalSymptoms = "\(namespace)journal_symptoms"
    static let journalMilestones = "\(namespace)journal_milestones"
    static let journalMoods = "\(namespace)journal_moods"
    static let journalHabits = "\(namespace)journal_habits"

    static let allJournalKeys: [String] = [
        journalNotes, journalSymptoms, journalMilestones, journalMoods, journalHabits,
    ]

    static let allKeys: [String] = [profile, storageVersion] + allJournalKeys

    static func removeJournalData() {
        let defaults = UserDefaults.standard
        for key in allJournalKeys {
            defaults.removeObject(forKey: key)
        }
    }

    static func removeAll() {
        let defaults = UserDefaults.standard
        for key in allKeys {
            defaults.removeObject(forKey: key)
        }
    }

    static func ensureVersion() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: storageVersion) == nil {
            defaults.set(currentVersion, forKey: storageVersion)
        }
    }
}

nonisolated enum ValidationRanges: Sendable {
    static let nameMinLength = 2
    static let pregnancyWeekMin = 4
    static let pregnancyWeekMax = 42
    static let babyAgeMin = 0
    static let babyAgeMax = 24
}
