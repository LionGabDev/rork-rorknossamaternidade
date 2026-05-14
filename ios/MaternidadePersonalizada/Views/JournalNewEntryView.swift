import SwiftUI

struct JournalNewEntryView: View {
    let journal: JournalService
    let stage: MaternalStage
    @Environment(\.dismiss) private var dismiss
    @State private var noteText: String = ""
    @State private var selectedMood: String = ""
    @State private var saved: Bool = false
    @FocusState private var isTextFocused: Bool

    private let moods: [(String, String)] = [
        ("Feliz", "😊"), ("Calma", "😌"), ("Cansada", "😴"), ("Ansiosa", "😰"), ("Grata", "🙏")
    ]

    private var placeholder: String {
        switch stage {
        case .trying: return "Como está se sentindo hoje no processo?"
        case .pregnant: return "Registre um momento da sua gestação..."
        case .postpartum: return "Como foi o dia com o bebê?"
        case .mother: return "O que está no seu coração hoje?"
        }
    }

    var body: some View {
        ZStack {
            AppTheme.cream
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    moodSelector
                    textEditor
                    recentEntries
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
                Text("Diário")
                    .font(AppTheme.serifFont(.headline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    saveEntry()
                } label: {
                    Text("Salvar")
                        .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                        .foregroundStyle(canSave ? AppTheme.rose : AppTheme.charcoalLight.opacity(0.4))
                }
                .disabled(!canSave)
            }
        }
        .onAppear {
            isTextFocused = true
        }
    }

    private var canSave: Bool {
        !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var moodSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "face.smiling.inverse")
                    .font(.caption)
                    .foregroundStyle(AppTheme.sage)
                Text("Como você está?")
                    .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }

            HStack(spacing: 0) {
                ForEach(moods, id: \.0) { label, emoji in
                    let isSelected = selectedMood == label
                    Button {
                        withAnimation(.spring(duration: 0.25)) {
                            selectedMood = isSelected ? "" : label
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(emoji)
                                .font(.title3)
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
        }
        .warmCard()
    }

    private var textEditor: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "pencil.line")
                    .font(.caption)
                    .foregroundStyle(AppTheme.rose)
                Text("Escreva livremente")
                    .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }

            TextField(placeholder, text: $noteText, axis: .vertical)
                .font(AppTheme.sansFont(.body))
                .foregroundStyle(AppTheme.charcoal)
                .lineLimit(5...12)
                .focused($isTextFocused)
                .padding(14)
                .background(Color.white)
                .clipShape(.rect(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(AppTheme.creamDark, lineWidth: 1)
                )

            if saved {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(AppTheme.sage)
                    Text("Salvo com sucesso!")
                        .font(AppTheme.sansFont(.caption, weight: .medium))
                        .foregroundStyle(AppTheme.sage)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .warmCard()
    }

    private var recentEntries: some View {
        Group {
            if !journal.notes.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundStyle(AppTheme.charcoalLight.opacity(0.5))
                        Text("Entradas recentes")
                            .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                            .foregroundStyle(AppTheme.charcoal)
                    }

                    ForEach(Array(journal.notes.prefix(5))) { note in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.text)
                                .font(AppTheme.sansFont(.subheadline))
                                .foregroundStyle(AppTheme.charcoal)
                                .lineLimit(2)
                            Text(note.date.formatted(.dateTime.day().month(.wide).hour().minute()))
                                .font(AppTheme.sansFont(.caption2))
                                .foregroundStyle(AppTheme.charcoalLight)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(AppTheme.cream)
                        .clipShape(.rect(cornerRadius: 10))
                    }
                }
                .warmCard()
            }
        }
    }

    private func saveEntry() {
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let moodPrefix = selectedMood.isEmpty ? "" : "\(selectedMood): "
        journal.saveNote(JournalNote(text: "\(moodPrefix)\(trimmed)"))
        let wordCount = trimmed.split(separator: " ").count
        AnalyticsService.shared.track(.journalEntryCreated, params: [
            "word_count": "\(wordCount)",
            "mood": selectedMood.isEmpty ? "none" : selectedMood
        ])

        if !selectedMood.isEmpty {
            journal.saveMood(MoodEntry(mood: selectedMood))
        }

        withAnimation(.spring(duration: 0.3)) {
            saved = true
            noteText = ""
            selectedMood = ""
        }

        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation { saved = false }
        }
    }
}
