import SwiftUI

struct PerfilView: View {
    let storage: StorageService
    let premiumService: PremiumService
    @Binding var showPaywall: Bool
    @State private var showEditSheet: Bool = false
    @State private var showResetConfirm: Bool = false

    var body: some View {
        ZStack {
            AppTheme.cream
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    profileHeader
                    actionsSection
                    placeholderSection
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
                Text("Perfil")
                    .font(AppTheme.serifFont(.headline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditProfileSheet(storage: storage)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .alert("Refazer Onboarding", isPresented: $showResetConfirm) {
            Button("Cancelar", role: .cancel) {}
            Button("Refazer", role: .destructive) {
                storage.resetOnboarding()
            }
        } message: {
            Text("Seu perfil e jornada serão apagados e você voltará ao início. Seu plano Premium será mantido.")
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.roseLight)
                    .frame(width: 72, height: 72)
                Text(storage.profile.userName.prefix(1).uppercased())
                    .font(AppTheme.serifFont(.title, weight: .bold))
                    .foregroundStyle(AppTheme.rose)
            }

            VStack(spacing: 4) {
                Text(storage.profile.userName.isEmpty ? "Mamãe" : storage.profile.userName)
                    .font(AppTheme.serifFont(.title3, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)

                if premiumService.isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.rose)
                        Text("Premium")
                            .font(AppTheme.sansFont(.caption, weight: .medium))
                            .foregroundStyle(AppTheme.rose)
                    }
                }

                if let stage = storage.profile.stage {
                    HStack(spacing: 6) {
                        Text(stage.title)
                            .font(AppTheme.sansFont(.subheadline))
                            .foregroundStyle(AppTheme.charcoalLight)

                        if stage == .pregnant, let w = storage.profile.pregnancyWeek {
                            Text("· Semana \(w)")
                                .font(AppTheme.sansFont(.subheadline))
                                .foregroundStyle(AppTheme.charcoalLight)
                        }
                        if stage == .postpartum, let m = storage.profile.babyAgeMonths {
                            let label = m == 1 ? "mês" : "meses"
                            Text("· \(m) \(label)")
                                .font(AppTheme.sansFont(.subheadline))
                                .foregroundStyle(AppTheme.charcoalLight)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .warmCard()
    }

    private var actionsSection: some View {
        VStack(spacing: 0) {
            PerfilRow(icon: "pencil", title: "Editar dados", color: AppTheme.sage) {
                showEditSheet = true
            }

            Divider().padding(.leading, 52)

            if premiumService.isPremium {
                PerfilRow(icon: "crown.fill", title: "Gerenciar assinatura", color: AppTheme.rose) {
                    showPaywall = true
                }
            } else {
                PerfilRow(icon: "crown.fill", title: "Assinar Premium", color: AppTheme.rose) {
                    showPaywall = true
                }
            }

            Divider().padding(.leading, 52)

            PerfilRow(icon: "arrow.counterclockwise", title: "Refazer onboarding", color: AppTheme.charcoalLight) {
                showResetConfirm = true
            }
        }
        .warmCard(padding: 0)
    }

    private var placeholderSection: some View {
        VStack(spacing: 0) {
            PerfilInfoRow(icon: "hand.raised.fill", title: "Privacidade", value: "Em breve", color: AppTheme.sage)
            Divider().padding(.leading, 52)
            PerfilInfoRow(icon: "square.and.arrow.up", title: "Exportar dados", value: "Em breve", color: AppTheme.sageDark)
        }
        .warmCard(padding: 0)
    }
}

private struct PerfilRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
                    .frame(width: 28)
                Text(title)
                    .font(AppTheme.sansFont(.body, weight: .medium))
                    .foregroundStyle(AppTheme.charcoal)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppTheme.charcoalLight.opacity(0.4))
            }
            .padding(16)
        }
        .buttonStyle(PerfilButtonStyle())
    }
}

private struct PerfilInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 28)
            Text(title)
                .font(AppTheme.sansFont(.body))
                .foregroundStyle(AppTheme.charcoal)
            Spacer()
            Text(value)
                .font(AppTheme.sansFont(.subheadline))
                .foregroundStyle(AppTheme.charcoalLight)
        }
        .padding(16)
    }
}

private struct PerfilButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? AppTheme.creamDark.opacity(0.3) : .clear)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

private struct EditProfileSheet: View {
    let storage: StorageService
    @Environment(\.dismiss) private var dismiss
    @State private var editName: String = ""
    @State private var editWeek: Int = 20
    @State private var editBabyAge: Int = 1
    @State private var hasAttemptedSave: Bool = false

    private var trimmedName: String {
        editName.trimmingCharacters(in: .whitespaces)
    }

    private var nameError: String? {
        trimmedName.count < ValidationRanges.nameMinLength
            ? "Mínimo \(ValidationRanges.nameMinLength) caracteres"
            : nil
    }

    private var weekError: String? {
        guard storage.profile.stage == .pregnant else { return nil }
        if editWeek < ValidationRanges.pregnancyWeekMin || editWeek > ValidationRanges.pregnancyWeekMax {
            return "Semana deve estar entre \(ValidationRanges.pregnancyWeekMin) e \(ValidationRanges.pregnancyWeekMax)"
        }
        return nil
    }

    private var babyAgeError: String? {
        guard storage.profile.stage == .postpartum else { return nil }
        if editBabyAge < ValidationRanges.babyAgeMin || editBabyAge > ValidationRanges.babyAgeMax {
            return "Idade deve estar entre \(ValidationRanges.babyAgeMin) e \(ValidationRanges.babyAgeMax) meses"
        }
        return nil
    }

    private var isValid: Bool {
        nameError == nil && weekError == nil && babyAgeError == nil
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Seu nome")
                        .font(AppTheme.sansFont(.subheadline, weight: .medium))
                        .foregroundStyle(AppTheme.charcoal)

                    TextField("Seu primeiro nome", text: $editName)
                        .font(AppTheme.sansFont(.body))
                        .foregroundStyle(AppTheme.charcoal)
                        .padding(16)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    (hasAttemptedSave && nameError != nil) ? Color.red.opacity(0.4) : Color.clear,
                                    lineWidth: 1
                                )
                        )

                    if hasAttemptedSave, let error = nameError {
                        Text(error)
                            .font(AppTheme.sansFont(.caption))
                            .foregroundStyle(.red.opacity(0.8))
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                if storage.profile.stage == .pregnant {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Semana de gestação")
                            .font(AppTheme.sansFont(.subheadline, weight: .medium))
                            .foregroundStyle(AppTheme.charcoal)

                        HStack {
                            Text("Semana \(editWeek)")
                                .font(AppTheme.serifFont(.body, weight: .semibold))
                                .foregroundStyle(AppTheme.rose)
                            Spacer()
                        }
                        Slider(value: Binding(
                            get: { Double(editWeek) },
                            set: { editWeek = Int($0) }
                        ), in: Double(ValidationRanges.pregnancyWeekMin)...Double(ValidationRanges.pregnancyWeekMax), step: 1)
                        .tint(AppTheme.rose)

                        if hasAttemptedSave, let error = weekError {
                            Text(error)
                                .font(AppTheme.sansFont(.caption))
                                .foregroundStyle(.red.opacity(0.8))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }

                if storage.profile.stage == .postpartum {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Idade do bebê")
                            .font(AppTheme.sansFont(.subheadline, weight: .medium))
                            .foregroundStyle(AppTheme.charcoal)

                        let label = editBabyAge == 1 ? "mês" : "meses"
                        HStack {
                            Text("\(editBabyAge) \(label)")
                                .font(AppTheme.serifFont(.body, weight: .semibold))
                                .foregroundStyle(AppTheme.roseDark)
                            Spacer()
                        }
                        Slider(value: Binding(
                            get: { Double(editBabyAge) },
                            set: { editBabyAge = Int($0) }
                        ), in: Double(ValidationRanges.babyAgeMin)...Double(ValidationRanges.babyAgeMax), step: 1)
                        .tint(AppTheme.roseDark)

                        if hasAttemptedSave, let error = babyAgeError {
                            Text(error)
                                .font(AppTheme.sansFont(.caption))
                                .foregroundStyle(.red.opacity(0.8))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }

                Spacer()

                Button {
                    if isValid {
                        save()
                    } else {
                        withAnimation(.easeOut(duration: 0.25)) {
                            hasAttemptedSave = true
                        }
                    }
                } label: {
                    Text("Salvar")
                }
                .buttonStyle(PrimaryButtonStyle(isDisabled: !isValid && hasAttemptedSave))
                .sensoryFeedback(.warning, trigger: hasAttemptedSave)
            }
            .padding(24)
            .navigationTitle("Editar dados")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(AppTheme.charcoalLight)
                }
            }
        }
        .onAppear {
            editName = storage.profile.userName
            editWeek = storage.profile.pregnancyWeek ?? 20
            editBabyAge = storage.profile.babyAgeMonths ?? 1
        }
    }

    private func save() {
        storage.profile.userName = trimmedName
        if storage.profile.stage == .pregnant {
            storage.profile.pregnancyWeek = editWeek
        }
        if storage.profile.stage == .postpartum {
            storage.profile.babyAgeMonths = editBabyAge
        }
        storage.save()
        dismiss()
    }
}
