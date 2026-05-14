import SwiftUI

nonisolated enum HojeDestination: Hashable, Sendable {
    case checklist(MaternalStage, Int?)
    case breathing
    case tipDetail(MaternalStage)
    case journal(MaternalStage)
    case jornada
    case conteudo
}

struct MainTabView: View {
    let storage: StorageService
    let journal: JournalService
    let premiumService: PremiumService
    let inspirationService: InspirationService
    @State private var selectedTab: Int = 0
    @State private var showPaywall: Bool = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Hoje", systemImage: "sun.max.fill", value: 0) {
                NavigationStack {
                    HojeView(storage: storage, journal: journal, premiumService: premiumService, inspirationService: inspirationService, showPaywall: $showPaywall)
                        .navigationDestination(for: HojeDestination.self) { dest in
                            switch dest {
                            case .checklist(let stage, let week):
                                ChecklistView(stage: stage, pregnancyWeek: week)
                            case .breathing:
                                BreathingExerciseView()
                            case .tipDetail(let stage):
                                TipDetailView(stage: stage)
                            case .journal(let stage):
                                JournalNewEntryView(journal: journal, stage: stage)
                            case .jornada:
                                JornadaView(storage: storage, journal: journal)
                            case .conteudo:
                                ConteudoView(storage: storage, premiumService: premiumService, showPaywall: $showPaywall)
                            }
                        }
                }
            }

            Tab("Nath", systemImage: "heart.circle.fill", value: 1) {
                NavigationStack {
                    MundoDaNathView(storage: storage)
                }
            }

            Tab("Cuidados", systemImage: "list.bullet.clipboard.fill", value: 2) {
                NavigationStack {
                    MeusCuidadosView()
                }
            }

            Tab("NathIA", systemImage: "sparkles", value: 3) {
                NavigationStack {
                    NathIAView(premiumService: premiumService, showPaywall: $showPaywall)
                }
            }

            Tab("Perfil", systemImage: "person.crop.circle.fill", value: 4) {
                NavigationStack {
                    PerfilView(storage: storage, premiumService: premiumService, showPaywall: $showPaywall)
                }
            }
        }
        .tint(AppTheme.rose)
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallSheet(storage: storage, premiumService: premiumService, isPresented: $showPaywall)
        }
    }
}

private struct HojeView: View {
    let storage: StorageService
    let journal: JournalService
    let premiumService: PremiumService
    let inspirationService: InspirationService
    @Binding var showPaywall: Bool
    @State private var appeared: Bool = false

    private var greeting: String {
        let name = storage.profile.userName.isEmpty ? "Mamãe" : storage.profile.userName
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        if hour < 12 {
            timeGreeting = "Bom dia"
        } else if hour < 18 {
            timeGreeting = "Boa tarde"
        } else {
            timeGreeting = "Boa noite"
        }
        return "\(timeGreeting), \(name) 💛"
    }

    private var stageLabel: String? {
        guard let stage = storage.profile.stage else { return nil }
        switch stage {
        case .trying:
            return "Tentando engravidar · Preparando o caminho"
        case .pregnant:
            if let week = storage.profile.pregnancyWeek {
                return "Semana \(week) de gestação"
            }
            return "Grávida"
        case .postpartum:
            if let months = storage.profile.babyAgeMonths {
                let label = months == 1 ? "mês" : "meses"
                return "Bebê com \(months) \(label)"
            }
            return "Puerpério"
        case .mother:
            return "Mãe · Sua jornada única"
        }
    }

    var body: some View {
        ZStack {
            AppTheme.cream
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(greeting)
                            .font(AppTheme.serifFont(.title, weight: .bold))
                            .foregroundStyle(AppTheme.charcoal)

                        if let label = stageLabel {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(AppTheme.sage)
                                    .frame(width: 6, height: 6)
                                Text(label)
                                    .font(AppTheme.sansFont(.subheadline))
                                    .foregroundStyle(AppTheme.charcoalLight)
                            }
                        }
                    }
                    .padding(.top, 8)

                    todayBlocks
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Hoje")
                    .font(AppTheme.serifFont(.headline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
            AnalyticsService.shared.track(.hojeViewed, params: [
                "stage": storage.profile.stage?.rawValue ?? "none"
            ])
        }
    }

    private var currentStage: MaternalStage {
        storage.profile.stage ?? .mother
    }

    private var todayBlocks: some View {
        VStack(spacing: 12) {
            inspirationBlock

            NavigationLink(value: HojeDestination.journal(currentStage)) {
                HojeActionCard(
                    icon: "book.fill",
                    title: "Escrever no Diário",
                    subtitle: "Registre como você está hoje",
                    color: AppTheme.sageDark
                )
            }
            .buttonStyle(.plain)

            NavigationLink(value: HojeDestination.checklist(currentStage, storage.profile.pregnancyWeek)) {
                HojeActionCard(
                    icon: stageActionIcon,
                    title: stageActionTitle,
                    subtitle: stageActionSubtitle,
                    color: AppTheme.rose
                )
            }
            .buttonStyle(.plain)

            NavigationLink(value: HojeDestination.breathing) {
                HojeActionCard(
                    icon: "figure.mind.and.body",
                    title: "Momento de Calma",
                    subtitle: "Exercício de respiração · 3 min",
                    color: AppTheme.sage
                )
            }
            .buttonStyle(.plain)

            if !premiumService.isPremium {
                premiumBanner
            }
        }
    }

    private var inspirationBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.caption)
                    .foregroundStyle(AppTheme.sage)
                Text("Inspiração do dia")
                    .font(AppTheme.sansFont(.caption, weight: .medium))
                    .foregroundStyle(AppTheme.sage)
                Spacer()
                if inspirationService.isLoading {
                    ProgressView()
                        .controlSize(.mini)
                        .tint(AppTheme.sage)
                }
            }

            if inspirationService.hasFetched {
                Text(inspirationService.quote)
                    .font(AppTheme.serifFont(.body, weight: .regular))
                    .foregroundStyle(AppTheme.charcoal)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                if !inspirationService.author.isEmpty {
                    Text("— \(inspirationService.author)")
                        .font(AppTheme.sansFont(.caption, weight: .medium))
                        .foregroundStyle(AppTheme.charcoalLight)
                }
            } else if !inspirationService.isLoading {
                Text(fallbackInspirationText)
                    .font(AppTheme.serifFont(.body, weight: .regular))
                    .foregroundStyle(AppTheme.charcoal)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [AppTheme.sageLight.opacity(0.3), AppTheme.sageLight.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppTheme.sage.opacity(0.15), lineWidth: 1)
        )
        .task {
            await inspirationService.fetchDailyQuote(stage: storage.profile.stage)
        }
    }

    private var fallbackInspirationText: String {
        guard let stage = storage.profile.stage else {
            return "Cada dia é uma nova oportunidade de crescer com amor."
        }
        switch stage {
        case .trying:
            return "Confie no seu corpo e no seu tempo. Cada passo que você dá é um passo em direção ao seu sonho."
        case .pregnant:
            return "Seu corpo está fazendo algo extraordinário agora. Respire fundo e sinta a conexão com seu bebê."
        case .postpartum:
            return "Você não precisa ser perfeita. Precisa ser presente. E isso você já é, todos os dias."
        case .mother:
            return "Ser mãe é aprender todos os dias que o amor pode ser ainda maior do que ontem."
        }
    }

    private var premiumBanner: some View {
        Button {
            showPaywall = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.roseLight)
                        .frame(width: 44, height: 44)
                    Image(systemName: "crown.fill")
                        .font(.body)
                        .foregroundStyle(AppTheme.rose)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Desbloqueie sua experiência completa")
                        .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                        .foregroundStyle(AppTheme.charcoal)
                    Text("7 dias grátis · conteúdo exclusivo para você")
                        .font(AppTheme.sansFont(.caption))
                        .foregroundStyle(AppTheme.charcoalLight)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.charcoalLight.opacity(0.5))
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [AppTheme.roseLight.opacity(0.4), AppTheme.roseLight.opacity(0.15)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(.rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(AppTheme.rose.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var stageActionIcon: String {
        switch storage.profile.stage {
        case .trying: return "heart.text.clipboard.fill"
        case .pregnant: return "calendar.badge.clock"
        case .postpartum: return "star.fill"
        case .mother: return "heart.text.clipboard.fill"
        case nil: return "heart.text.clipboard.fill"
        }
    }

    private var stageActionTitle: String {
        switch storage.profile.stage {
        case .trying: return "Checklist de Fertilidade"
        case .pregnant: return "Checklist da Semana"
        case .postpartum: return "Cuidados do Dia"
        case .mother: return "Checklist do Dia"
        case nil: return "Checklist do Dia"
        }
    }

    private var stageActionSubtitle: String {
        switch storage.profile.stage {
        case .trying: return "3 cuidados para seu ciclo"
        case .pregnant:
            let w = storage.profile.pregnancyWeek ?? 20
            return "Semana \(w) · 3 cuidados"
        case .postpartum: return "3 cuidados para você e o bebê"
        case .mother: return "3 cuidados pensados para você"
        case nil: return "3 cuidados pensados para você"
        }
    }
}

private struct HojeActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
                Text(subtitle)
                    .font(AppTheme.sansFont(.caption))
                    .foregroundStyle(AppTheme.charcoalLight)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.medium))
                .foregroundStyle(AppTheme.charcoalLight.opacity(0.4))
        }
        .warmCard(padding: 14)
    }
}

private struct PaywallSheet: View {
    let storage: StorageService
    let premiumService: PremiumService
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            PaywallView(
                storage: storage,
                premiumService: premiumService,
                placement: "home",
                onComplete: { isPresented = false },
                onSkip: { isPresented = false }
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                            .foregroundStyle(AppTheme.charcoalLight)
                    }
                }
            }
        }
    }
}
