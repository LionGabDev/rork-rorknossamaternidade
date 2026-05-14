import SwiftUI

struct DesabafoComposerView: View {
    let userName: String
    let onSubmit: (String, [DesabafoTag]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    @State private var selectedTags: Set<DesabafoTag> = []
    @FocusState private var isTextFocused: Bool

    private var canSubmit: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection

                    tagsSection

                    textSection

                    supportMessage
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(AppTheme.cream)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                            .foregroundStyle(AppTheme.charcoalLight)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Desabafar")
                        .font(AppTheme.serifFont(.headline, weight: .semibold))
                        .foregroundStyle(AppTheme.charcoal)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onSubmit(trimmed, Array(selectedTags))
                        dismiss()
                    } label: {
                        Text("Publicar")
                            .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                            .foregroundStyle(canSubmit ? .white : AppTheme.charcoalLight.opacity(0.5))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(canSubmit ? AppTheme.rose : AppTheme.creamDark)
                            .clipShape(.capsule)
                    }
                    .disabled(!canSubmit)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isTextFocused = true
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Circle()
                    .fill(AppTheme.roseLight)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Text(String(displayName.prefix(1)).uppercased())
                            .font(AppTheme.sansFont(.subheadline, weight: .bold))
                            .foregroundStyle(AppTheme.roseDark)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                        .foregroundStyle(AppTheme.charcoal)
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 9))
                        Text("Anônimo para outras mães")
                            .font(AppTheme.sansFont(.caption2))
                    }
                    .foregroundStyle(AppTheme.sage)
                }
            }
        }
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Como você está se sentindo?")
                .font(AppTheme.sansFont(.subheadline, weight: .medium))
                .foregroundStyle(AppTheme.charcoal)

            FlowLayout(spacing: 8) {
                ForEach(DesabafoTag.allCases) { tag in
                    TagChip(
                        tag: tag,
                        isSelected: selectedTags.contains(tag),
                        onTap: {
                            withAnimation(.spring(duration: 0.25)) {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }
                        }
                    )
                }
            }
        }
    }

    private var textSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Conta pra gente...")
                .font(AppTheme.sansFont(.subheadline, weight: .medium))
                .foregroundStyle(AppTheme.charcoal)

            TextField("Escreva aqui o que está no seu coração. Este é um espaço seguro, sem julgamentos. 💛", text: $text, axis: .vertical)
                .font(AppTheme.sansFont(.body))
                .foregroundStyle(AppTheme.charcoal)
                .lineLimit(4...12)
                .focused($isTextFocused)
                .padding(16)
                .background(AppTheme.cardBackground)
                .clipShape(.rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            isTextFocused ? AppTheme.rose.opacity(0.4) : AppTheme.creamDark,
                            lineWidth: 1
                        )
                )

            HStack {
                Spacer()
                Text("\(text.count)/500")
                    .font(AppTheme.sansFont(.caption2))
                    .foregroundStyle(text.count > 450 ? AppTheme.roseDark : AppTheme.charcoalLight)
            }
        }
        .onChange(of: text) { _, newValue in
            if newValue.count > 500 {
                text = String(newValue.prefix(500))
            }
        }
    }

    private var supportMessage: some View {
        HStack(spacing: 10) {
            Image(systemName: "heart.circle.fill")
                .font(.title3)
                .foregroundStyle(AppTheme.sage)

            Text("Você não está sozinha. Cada desabafo é um passo para se sentir mais leve.")
                .font(AppTheme.sansFont(.caption))
                .foregroundStyle(AppTheme.charcoalLight)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(AppTheme.sageLight.opacity(0.2))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var displayName: String {
        userName.isEmpty ? "Mamãe" : userName
    }
}

private struct TagChip: View {
    let tag: DesabafoTag
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                Text(tag.emoji)
                    .font(.system(size: 14))
                Text(tag.label)
                    .font(AppTheme.sansFont(.caption, weight: isSelected ? .semibold : .regular))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? AppTheme.rose.opacity(0.15) : AppTheme.cardBackground)
            .foregroundStyle(isSelected ? AppTheme.roseDark : AppTheme.charcoal)
            .clipShape(.capsule)
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? AppTheme.rose.opacity(0.5) : AppTheme.creamDark,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}
