import Foundation

@Observable
class CuidadosViewModel {
    var habits: [CareHabit] = []
    var selectedCategory: CareCategory?
    private let storageKey = "mp_v1_care_habits"

    var filteredHabits: [CareHabit] {
        guard let cat = selectedCategory else { return habits }
        return habits.filter { $0.category == cat }
    }

    var completedToday: Int {
        habits.filter(\.isCompletedToday).count
    }

    var totalHabits: Int {
        habits.count
    }

    var todayProgress: Double {
        guard totalHabits > 0 else { return 0 }
        return Double(completedToday) / Double(totalHabits)
    }

    init() {
        loadHabits()
        if habits.isEmpty {
            habits = Self.defaultHabits()
            saveHabits()
        }
    }

    func toggleHabit(_ id: UUID) {
        guard let idx = habits.firstIndex(where: { $0.id == id }) else { return }
        if habits[idx].isCompletedToday {
            habits[idx].streak = max(0, habits[idx].streak - 1)
            habits[idx].lastCompleted = nil
            habits[idx].completedDates.removeAll { Calendar.current.isDateInToday($0) }
        } else {
            habits[idx].streak += 1
            habits[idx].lastCompleted = Date()
            habits[idx].completedDates.append(Date())
            // TODO: share_tapped — adicionar evento quando funcionalidade de compartilhamento for implementada
        }
        saveHabits()
    }

    func addHabit(title: String, icon: String, category: CareCategory) {
        let habit = CareHabit(title: title, icon: icon, category: category)
        habits.append(habit)
        saveHabits()
    }

    func removeHabit(_ id: UUID) {
        habits.removeAll { $0.id == id }
        saveHabits()
    }

    private func saveHabits() {
        guard let data = try? JSONEncoder().encode(habits) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func loadHabits() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([CareHabit].self, from: data) else { return }
        habits = decoded
    }

    private static func defaultHabits() -> [CareHabit] {
        [
            CareHabit(title: "Beber 2L de água", icon: "drop.fill", category: .health),
            CareHabit(title: "Tomar vitaminas", icon: "pill.fill", category: .nutrition),
            CareHabit(title: "Caminhar 15 min", icon: "figure.walk", category: .wellness),
            CareHabit(title: "Respiração consciente", icon: "wind", category: .wellness),
            CareHabit(title: "Comer frutas", icon: "carrot.fill", category: .nutrition),
            CareHabit(title: "Momento com o bebê", icon: "heart.fill", category: .baby),
            CareHabit(title: "Skincare", icon: "sparkles", category: .wellness),
            CareHabit(title: "Dormir 7h+", icon: "moon.fill", category: .health),
        ]
    }
}
