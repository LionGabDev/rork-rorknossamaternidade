import SwiftUI

struct JornadaView: View {
    let storage: StorageService
    let journal: JournalService

    private var stage: MaternalStage {
        storage.profile.stage ?? .mother
    }

    var body: some View {
        ZStack {
            AppTheme.cream
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    switch stage {
                    case .pregnant:
                        pregnantContent
                    case .postpartum:
                        postpartumContent
                    case .trying:
                        tryingContent
                    case .mother:
                        motherContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Jornada")
                    .font(AppTheme.serifFont(.headline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }
        }

    }

    // MARK: - Pregnant

    private var pregnantContent: some View {
        VStack(spacing: 20) {
            weekHighlightCard
            pregnantNoteCard
        }
    }

    private var weekHighlightCard: some View {
        let week = storage.profile.pregnancyWeek ?? 20
        return VStack(spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.roseLight)
                        .frame(width: 56, height: 56)
                    Text("\(week)")
                        .font(AppTheme.serifFont(.title, weight: .bold))
                        .foregroundStyle(AppTheme.rose)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Semana \(week)")
                        .font(AppTheme.serifFont(.title3, weight: .semibold))
                        .foregroundStyle(AppTheme.charcoal)
                    Text(weekDescription(week))
                        .font(AppTheme.sansFont(.subheadline))
                        .foregroundStyle(AppTheme.charcoalLight)
                        .lineSpacing(2)
                }

                Spacer()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.creamDark)
                        .frame(height: 6)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.rose, AppTheme.roseDark],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(week) / 42.0, height: 6)
                }
            }
            .frame(height: 6)

            HStack {
                Text("Início")
                    .font(AppTheme.sansFont(.caption2))
                    .foregroundStyle(AppTheme.charcoalLight)
                Spacer()
                Text("\(Int((Double(week) / 42.0) * 100))% da gestação")
                    .font(AppTheme.sansFont(.caption2, weight: .medium))
                    .foregroundStyle(AppTheme.rose)
                Spacer()
                Text("42 sem")
                    .font(AppTheme.sansFont(.caption2))
                    .foregroundStyle(AppTheme.charcoalLight)
            }
        }
        .warmCard()
    }

    // MARK: - Postpartum

    private var postpartumContent: some View {
        VStack(spacing: 20) {
            milestonesCard
            postpartumNoteCard
        }
    }

    private var milestonesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(AppTheme.roseDark)
                Text("Marcos do bebê")
                    .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
                Spacer()
                let done = journal.milestones.filter(\.isCompleted).count
                Text("\(done)/\(journal.milestones.count)")
                    .font(AppTheme.sansFont(.caption, weight: .medium))
                    .foregroundStyle(AppTheme.charcoalLight)
            }

            ForEach(journal.milestones) { item in
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        journal.toggleMilestone(item.id)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(item.isCompleted ? AppTheme.sage : AppTheme.creamDark)

                        Text(item.title)
                            .font(AppTheme.sansFont(.body))
                            .foregroundStyle(item.isCompleted ? AppTheme.charcoalLight : AppTheme.charcoal)
                            .strikethrough(item.isCompleted, color: AppTheme.charcoalLight)
                    }
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.selection, trigger: item.isCompleted)
            }
        }
        .warmCard()
    }

    // MARK: - Trying

    private var tryingContent: some View {
        VStack(spacing: 20) {
            symptomLogCard
            tryingNoteCard
        }
    }

    private var symptomLogCard: some View {
        let symptoms = ["Cólica", "Náusea", "Cansaço", "Inchaço", "Dor de cabeça", "Sensibilidade"]

        return VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "heart.text.clipboard.fill")
                    .font(.caption)
                    .foregroundStyle(AppTheme.rose)
                Text("Sintomas de hoje")
                    .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }

            let todayLog = journal.symptomLogs.first(where: {
                Calendar.current.isDateInToday($0.date)
            })

            let columns = [GridItem(.adaptive(minimum: 90), spacing: 8)]
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(symptoms, id: \.self) { symptom in
                    let isSelected = todayLog?.symptoms.contains(symptom) == true
                    Button {
                        saveSymptomToggle(symptom)
                    } label: {
                        Text(symptom)
                            .font(AppTheme.sansFont(.caption, weight: .medium))
                            .foregroundStyle(isSelected ? .white : AppTheme.charcoal)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(isSelected ? AppTheme.rose : AppTheme.creamDark.opacity(0.5))
                            .clipShape(.rect(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .warmCard()
    }

    // MARK: - Mother

    private var motherContent: some View {
        VStack(spacing: 20) {
            moodCard
            habitsCard
        }
    }

    private var moodCard: some View {
        let moods = [("Feliz", "😊"), ("Calma", "😌"), ("Cansada", "😴"), ("Ansiosa", "😰"), ("Triste", "😢")]
        let todayMood = journal.moodEntries.first(where: {
            Calendar.current.isDateInToday($0.date)
        })

        return VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "face.smiling.inverse")
                    .font(.caption)
                    .foregroundStyle(AppTheme.sage)
                Text("Como você está hoje?")
                    .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }

            HStack(spacing: 0) {
                ForEach(moods, id: \.0) { label, emoji in
                    let isSelected = todayMood?.mood == label
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            saveMood(label)
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(emoji)
                                .font(.title2)
                                .scaleEffect(isSelected ? 1.2 : 1.0)
                            Text(label)
                                .font(AppTheme.sansFont(.caption2, weight: isSelected ? .semibold : .regular))
                                .foregroundStyle(isSelected ? AppTheme.charcoal : AppTheme.charcoalLight)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isSelected ? AppTheme.sageLight.opacity(0.4) : .clear)
                        .clipShape(.rect(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.selection, trigger: isSelected)
                }
            }

            if let mood = todayMood {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.sage)
                    Text("Humor registrado: \(mood.mood)")
                        .font(AppTheme.sansFont(.caption))
                        .foregroundStyle(AppTheme.charcoalLight)
                }
            }
        }
        .warmCard()
    }

    private var habitsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.caption)
                    .foregroundStyle(AppTheme.roseDark)
                Text("Mini hábitos")
                    .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }

            ForEach(journal.habits) { habit in
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        journal.toggleHabit(habit.id)
                    }
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(habit.isCompletedToday ? AppTheme.sage : AppTheme.creamDark.opacity(0.5))
                                .frame(width: 40, height: 40)
                            Image(systemName: habit.icon)
                                .font(.body)
                                .foregroundStyle(habit.isCompletedToday ? .white : AppTheme.charcoalLight)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(habit.title)
                                .font(AppTheme.sansFont(.body, weight: .medium))
                                .foregroundStyle(AppTheme.charcoal)
                            if habit.streak > 0 {
                                Text("\(habit.streak) dia\(habit.streak == 1 ? "" : "s") seguido\(habit.streak == 1 ? "" : "s")")
                                    .font(AppTheme.sansFont(.caption))
                                    .foregroundStyle(AppTheme.sage)
                            }
                        }

                        Spacer()

                        if habit.isCompletedToday {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppTheme.sage)
                        }
                    }
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.impact(weight: .light), trigger: habit.isCompletedToday)
            }
        }
        .warmCard()
    }

    // MARK: - Shared Note Cards

    @State private var noteText: String = ""

    private var pregnantNoteCard: some View {
        noteCardView(
            title: "Diário da gestação",
            icon: "pencil.line",
            color: AppTheme.sage,
            placeholder: "Como você está se sentindo hoje?",
            entries: Array(journal.notes.prefix(3)).map { ($0.date, $0.text) }
        ) {
            guard !noteText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            journal.saveNote(JournalNote(text: noteText.trimmingCharacters(in: .whitespaces)))
            noteText = ""
        }
    }

    private var postpartumNoteCard: some View {
        noteCardView(
            title: "Anotações",
            icon: "note.text",
            color: AppTheme.roseDark,
            placeholder: "Registre um momento especial...",
            entries: Array(journal.notes.prefix(3)).map { ($0.date, $0.text) }
        ) {
            guard !noteText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            journal.saveNote(JournalNote(text: noteText.trimmingCharacters(in: .whitespaces)))
            noteText = ""
        }
    }

    private var tryingNoteCard: some View {
        noteCardView(
            title: "Anotações do dia",
            icon: "pencil.line",
            color: AppTheme.sage,
            placeholder: "Algo que queira registrar...",
            entries: Array(journal.notes.prefix(3)).map { ($0.date, $0.text) }
        ) {
            guard !noteText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            journal.saveNote(JournalNote(text: noteText.trimmingCharacters(in: .whitespaces)))
            noteText = ""
        }
    }

    private func noteCardView(
        title: String, icon: String, color: Color, placeholder: String,
        entries: [(Date, String)], onSave: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(title)
                    .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }

            HStack(spacing: 10) {
                TextField(placeholder, text: $noteText, axis: .vertical)
                    .font(AppTheme.sansFont(.body))
                    .lineLimit(3)
                    .foregroundStyle(AppTheme.charcoal)

                Button {
                    onSave()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(noteText.trimmingCharacters(in: .whitespaces).isEmpty ? AppTheme.creamDark : AppTheme.rose)
                }
                .disabled(noteText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(14)
            .background(Color.white)
            .clipShape(.rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(AppTheme.creamDark, lineWidth: 1)
            )

            if entries.isEmpty {
                HStack {
                    Spacer()
                    Text("Nenhuma anotação ainda")
                        .font(AppTheme.sansFont(.caption))
                        .foregroundStyle(AppTheme.charcoalLight)
                    Spacer()
                }
                .padding(.top, 4)
            } else {
                ForEach(Array(entries), id: \.0) { date, text in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(text)
                            .font(AppTheme.sansFont(.subheadline))
                            .foregroundStyle(AppTheme.charcoal)
                            .lineLimit(2)
                        Text(date.formatted(.dateTime.day().month(.wide)))
                            .font(AppTheme.sansFont(.caption2))
                            .foregroundStyle(AppTheme.charcoalLight)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(AppTheme.cream)
                    .clipShape(.rect(cornerRadius: 8))
                }
            }
        }
        .warmCard()
    }

    // MARK: - Helpers

    private func weekDescription(_ week: Int) -> String {
        switch week {
        case 4...12: return "Primeiro trimestre — formação dos órgãos"
        case 13...27: return "Segundo trimestre — crescimento acelerado"
        case 28...42: return "Terceiro trimestre — preparação para o parto"
        default: return "Sua jornada está começando"
        }
    }

    private func saveSymptomToggle(_ symptom: String) {
        if let idx = journal.symptomLogs.firstIndex(where: { Calendar.current.isDateInToday($0.date) }) {
            if journal.symptomLogs[idx].symptoms.contains(symptom) {
                journal.symptomLogs[idx].symptoms.removeAll { $0 == symptom }
            } else {
                journal.symptomLogs[idx].symptoms.append(symptom)
            }
            journal.saveSymptoms()
        } else {
            journal.saveSymptomLog(SymptomLog(symptoms: [symptom]))
        }
    }

    private func saveMood(_ mood: String) {
        if let idx = journal.moodEntries.firstIndex(where: { Calendar.current.isDateInToday($0.date) }) {
            journal.moodEntries[idx].mood = mood
            journal.saveMoods()
        } else {
            journal.saveMood(MoodEntry(mood: mood))
        }
    }
}
