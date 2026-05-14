import Foundation

@Observable
class JournalService {
    var notes: [JournalNote] = []
    var symptomLogs: [SymptomLog] = []
    var milestones: [MilestoneItem] = []
    var moodEntries: [MoodEntry] = []
    var habits: [HabitItem] = []

    init() {
        loadAll()
    }

    func loadAll() {
        notes = load(key: StorageKeys.journalNotes) ?? []
        symptomLogs = load(key: StorageKeys.journalSymptoms) ?? []
        milestones = load(key: StorageKeys.journalMilestones) ?? defaultMilestones()
        moodEntries = load(key: StorageKeys.journalMoods) ?? []
        habits = load(key: StorageKeys.journalHabits) ?? defaultHabits()
    }

    func saveNote(_ note: JournalNote) {
        notes.insert(note, at: 0)
        save(notes, key: StorageKeys.journalNotes)
    }

    func saveSymptomLog(_ log: SymptomLog) {
        symptomLogs.insert(log, at: 0)
        save(symptomLogs, key: StorageKeys.journalSymptoms)
    }

    func toggleMilestone(_ id: UUID) {
        guard let idx = milestones.firstIndex(where: { $0.id == id }) else { return }
        milestones[idx].isCompleted.toggle()
        save(milestones, key: StorageKeys.journalMilestones)
    }

    func saveMood(_ entry: MoodEntry) {
        moodEntries.insert(entry, at: 0)
        save(moodEntries, key: StorageKeys.journalMoods)
    }

    func toggleHabit(_ id: UUID) {
        guard let idx = habits.firstIndex(where: { $0.id == id }) else { return }
        if habits[idx].isCompletedToday {
            habits[idx].streak = max(0, habits[idx].streak - 1)
            habits[idx].lastCompleted = nil
        } else {
            habits[idx].streak += 1
            habits[idx].lastCompleted = Date()
        }
        save(habits, key: StorageKeys.journalHabits)
    }

    func resetAll() {
        notes = []
        symptomLogs = []
        milestones = defaultMilestones()
        moodEntries = []
        habits = defaultHabits()
    }

    func saveSymptoms() {
        save(symptomLogs, key: StorageKeys.journalSymptoms)
    }

    func saveMoods() {
        save(moodEntries, key: StorageKeys.journalMoods)
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func load<T: Decodable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func defaultMilestones() -> [MilestoneItem] {
        [
            MilestoneItem(title: "Primeiro sorriso social"),
            MilestoneItem(title: "Sustentou a cabeça"),
            MilestoneItem(title: "Rolou de barriga"),
            MilestoneItem(title: "Sentou com apoio"),
            MilestoneItem(title: "Primeira papinha"),
            MilestoneItem(title: "Primeiros passos"),
        ]
    }

    private func defaultHabits() -> [HabitItem] {
        [
            HabitItem(title: "Beber água", icon: "drop.fill"),
            HabitItem(title: "Momento de calma", icon: "leaf.fill"),
            HabitItem(title: "Movimento do corpo", icon: "figure.walk"),
        ]
    }
}
