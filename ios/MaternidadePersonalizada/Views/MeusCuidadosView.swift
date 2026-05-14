import SwiftUI

struct MeusCuidadosView: View {
    @State private var viewModel = CuidadosViewModel()
    @State private var showAddHabit: Bool = false

    var body: some View {
        ZStack {
            AppTheme.cream
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    progressHeader

                    categoryFilter

                    habitsGrid
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Meus Cuidados")
                    .font(AppTheme.serifFont(.headline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddHabit = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.body)
                        .foregroundStyle(AppTheme.rose)
                }
            }
        }
        .sheet(isPresented: $showAddHabit) {
            AddHabitSheet(onAdd: { title, icon, category in
                viewModel.addHabit(title: title, icon: icon, category: category)
            })
            .presentationDetents([.medium])
        }
    }

    private var progressHeader: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(AppTheme.creamDark, lineWidth: 8)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: viewModel.todayProgress)
                        .stroke(
                            LinearGradient(
                                colors: [AppTheme.rose, AppTheme.roseDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(duration: 0.5), value: viewModel.todayProgress)

                    VStack(spacing: 0) {
                        Text("\(viewModel.completedToday)")
                            .font(AppTheme.serifFont(.title2, weight: .bold))
                            .foregroundStyle(AppTheme.charcoal)
                        Text("de \(viewModel.totalHabits)")
                            .font(AppTheme.sansFont(.caption2))
                            .foregroundStyle(AppTheme.charcoalLight)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(progressMessage)
                        .font(AppTheme.serifFont(.title3, weight: .semibold))
                        .foregroundStyle(AppTheme.charcoal)
                    Text("Continue cuidando de você, mamãe 💕")
                        .font(AppTheme.sansFont(.subheadline))
                        .foregroundStyle(AppTheme.charcoalLight)
                }

                Spacer()
            }

            let streak = viewModel.habits.map(\.streak).max() ?? 0
            if streak > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text("Melhor sequência: \(streak) dia\(streak == 1 ? "" : "s")")
                        .font(AppTheme.sansFont(.caption, weight: .medium))
                        .foregroundStyle(AppTheme.charcoalLight)
                    Spacer()
                }
            }
        }
        .warmCard()
    }

    private var progressMessage: String {
        let pct = viewModel.todayProgress
        if pct == 0 { return "Bora começar!" }
        if pct < 0.5 { return "Bom começo!" }
        if pct < 1.0 { return "Quase lá!" }
        return "Parabéns! 🎉"
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(title: "Todos", icon: "square.grid.2x2.fill", isSelected: viewModel.selectedCategory == nil) {
                    withAnimation(.spring(duration: 0.3)) {
                        viewModel.selectedCategory = nil
                    }
                }

                ForEach(CareCategory.allCases) { cat in
                    categoryChip(title: cat.title, icon: cat.icon, isSelected: viewModel.selectedCategory == cat) {
                        withAnimation(.spring(duration: 0.3)) {
                            viewModel.selectedCategory = viewModel.selectedCategory == cat ? nil : cat
                        }
                    }
                }
            }
        }
        .contentMargins(.horizontal, 0)
    }

    private func categoryChip(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .font(AppTheme.sansFont(.caption, weight: .medium))
            }
            .foregroundStyle(isSelected ? .white : AppTheme.charcoal)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? AppTheme.rose : AppTheme.cardBackground)
            .clipShape(.capsule)
            .shadow(color: isSelected ? AppTheme.rose.opacity(0.3) : .clear, radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    private var habitsGrid: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.filteredHabits) { habit in
                HabitRow(habit: habit) {
                    withAnimation(.spring(duration: 0.35)) {
                        viewModel.toggleHabit(habit.id)
                    }
                } onDelete: {
                    withAnimation(.spring(duration: 0.3)) {
                        viewModel.removeHabit(habit.id)
                    }
                }
            }
        }
    }
}

private struct HabitRow: View {
    let habit: CareHabit
    let onToggle: () -> Void
    let onDelete: () -> Void

    private var categoryColor: Color {
        switch habit.category {
        case .health: AppTheme.rose
        case .nutrition: AppTheme.sage
        case .wellness: AppTheme.roseDark
        case .baby: AppTheme.sageDark
        }
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(habit.isCompletedToday ? categoryColor : categoryColor.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: habit.isCompletedToday ? "checkmark" : habit.icon)
                        .font(.body.weight(habit.isCompletedToday ? .bold : .regular))
                        .foregroundStyle(habit.isCompletedToday ? .white : categoryColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(habit.title)
                        .font(AppTheme.sansFont(.body, weight: .medium))
                        .foregroundStyle(habit.isCompletedToday ? AppTheme.charcoalLight : AppTheme.charcoal)
                        .strikethrough(habit.isCompletedToday, color: AppTheme.charcoalLight.opacity(0.5))

                    HStack(spacing: 8) {
                        Text(habit.category.title)
                            .font(AppTheme.sansFont(.caption2))
                            .foregroundStyle(categoryColor)

                        if habit.streak > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.orange)
                                Text("\(habit.streak)")
                                    .font(AppTheme.sansFont(.caption2, weight: .semibold))
                                    .foregroundStyle(AppTheme.charcoalLight)
                            }
                        }
                    }
                }

                Spacer()

                if habit.isCompletedToday {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(categoryColor)
                }
            }
            .padding(12)
            .background(AppTheme.cardBackground)
            .clipShape(.rect(cornerRadius: 14))
            .shadow(color: AppTheme.cardShadow, radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .medium), trigger: habit.isCompletedToday)
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Remover", systemImage: "trash")
            }
        }
    }
}

private struct AddHabitSheet: View {
    let onAdd: (String, String, CareCategory) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var selectedIcon: String = "heart.fill"
    @State private var selectedCategory: CareCategory = .health

    private let icons = ["heart.fill", "drop.fill", "leaf.fill", "figure.walk", "moon.fill", "pill.fill", "sparkles", "sun.max.fill", "cup.and.saucer.fill", "book.fill", "music.note", "face.smiling"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nome do hábito")
                        .font(AppTheme.sansFont(.subheadline, weight: .medium))
                        .foregroundStyle(AppTheme.charcoal)
                    TextField("Ex: Tomar chá de camomila", text: $title)
                        .font(AppTheme.sansFont(.body))
                        .padding(14)
                        .background(AppTheme.cream)
                        .clipShape(.rect(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Ícone")
                        .font(AppTheme.sansFont(.subheadline, weight: .medium))
                        .foregroundStyle(AppTheme.charcoal)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                        ForEach(icons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title3)
                                    .foregroundStyle(selectedIcon == icon ? .white : AppTheme.charcoal)
                                    .frame(width: 44, height: 44)
                                    .background(selectedIcon == icon ? AppTheme.rose : AppTheme.creamDark.opacity(0.4))
                                    .clipShape(.rect(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Categoria")
                        .font(AppTheme.sansFont(.subheadline, weight: .medium))
                        .foregroundStyle(AppTheme.charcoal)
                    HStack(spacing: 8) {
                        ForEach(CareCategory.allCases) { cat in
                            Button {
                                selectedCategory = cat
                            } label: {
                                Text(cat.title)
                                    .font(AppTheme.sansFont(.caption, weight: .medium))
                                    .foregroundStyle(selectedCategory == cat ? .white : AppTheme.charcoal)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == cat ? AppTheme.rose : AppTheme.creamDark.opacity(0.4))
                                    .clipShape(.capsule)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Spacer()

                Button {
                    let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    onAdd(trimmed, selectedIcon, selectedCategory)
                    dismiss()
                } label: {
                    Text("Adicionar Hábito")
                }
                .buttonStyle(PrimaryButtonStyle(isDisabled: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(20)
            .navigationTitle("Novo Hábito")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(AppTheme.charcoalLight)
                }
            }
        }
    }
}
