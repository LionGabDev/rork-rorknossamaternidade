import SwiftUI
import RevenueCat

enum PaywallVariant: String, Sendable {
    case acolhimento = "A"
    case rotina = "B"

    static func assigned() -> PaywallVariant {
        let key = "mp_paywall_variant"
        if let raw = UserDefaults.standard.string(forKey: key),
           let variant = PaywallVariant(rawValue: raw) {
            return variant
        }
        let variant: PaywallVariant = Bool.random() ? .acolhimento : .rotina
        UserDefaults.standard.set(variant.rawValue, forKey: key)
        return variant
    }

    var headline: String {
        switch self {
        case .acolhimento: return "Você merece mais\ndo que sobreviver."
        case .rotina: return "Você merece mais\ndo que sobreviver."
        }
    }

    var subheadline: String {
        switch self {
        case .acolhimento: return "junte-se a 15 mil Mães Valentes que escolheram parar de só aguentar e começar a liderar"
        case .rotina: return "junte-se a 15 mil Mães Valentes que escolheram parar de só aguentar e começar a liderar"
        }
    }

    var ctaNoTrialText: String {
        switch self {
        case .acolhimento: return "Quero começar agora"
        case .rotina: return "Quero começar agora"
        }
    }

    var benefits: [(icon: String, text: String, color: Color)] {
        switch self {
        case .acolhimento:
            return [
                ("sparkles", "Conteúdo personalizado para sua fase", AppTheme.rose),
                ("heart.text.clipboard.fill", "Acompanhamento semanal completo", AppTheme.roseDark),
                ("bell.badge.fill", "Lembretes e dicas no momento certo", AppTheme.sage),
                ("lock.open.fill", "Todos os artigos e guias premium", AppTheme.sageDark),
            ]
        case .rotina:
            return [
                ("calendar.badge.clock", "Checklist diário por fase", AppTheme.sage),
                ("figure.mind.and.body", "Exercícios de respiração guiados", AppTheme.roseDark),
                ("book.fill", "Diário de sentimentos ilimitado", AppTheme.rose),
                ("sparkles", "NathIA sem limites de conversa", AppTheme.sageDark),
            ]
        }
    }
}

struct PaywallView: View {
    let storage: StorageService
    @State private var premiumService: PremiumService
    let placement: String
    let onComplete: () -> Void
    let onSkip: (() -> Void)?

    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    private let variant: PaywallVariant

    private var selectedHasTrial: Bool {
        guard let package = premiumService.selectedPackage else { return false }
        return premiumService.isEligibleForTrial(package)
    }

    private var trialPeriodText: String? {
        guard selectedHasTrial,
              let period = premiumService.selectedPackage?.storeProduct.introductoryDiscount?.subscriptionPeriod else {
            return nil
        }
        return formatTrialPeriod(period)
    }

    private var subscriptionPeriodLabel: String {
        guard let period = premiumService.selectedPackage?.storeProduct.subscriptionPeriod else { return "" }
        return "/" + formatPeriodUnit(period.unit, value: period.value)
    }

    private var ctaMainText: String {
        guard let package = premiumService.selectedPackage else { return variant.ctaNoTrialText }
        if let trialText = trialPeriodText {
            return "Começar \(trialText)"
        }
        return "Assinar por \(package.storeProduct.localizedPriceString)\(subscriptionPeriodLabel)"
    }

    private var ctaSubtitle: String {
        guard let package = premiumService.selectedPackage else { return "" }
        let price = package.storeProduct.localizedPriceString
        if selectedHasTrial {
            return "depois \(price)\(subscriptionPeriodLabel)"
        }
        return ""
    }

    private func formatTrialPeriod(_ period: SubscriptionPeriod) -> String {
        let suffix = "grátis"
        switch (period.unit, period.value) {
        case (.day, 1): return "1 dia \(suffix)"
        case (.day, let v): return "\(v) dias \(suffix)"
        case (.week, 1): return "7 dias \(suffix)"
        case (.week, let v): return "\(v) semanas \(suffix)"
        case (.month, 1): return "1 mês \(suffix)"
        case (.month, let v): return "\(v) meses \(suffix)"
        case (.year, 1): return "1 ano \(suffix)"
        case (.year, let v): return "\(v) anos \(suffix)"
        @unknown default: return "teste \(suffix)"
        }
    }

    private func formatPeriodUnit(_ unit: SubscriptionPeriod.Unit, value: Int) -> String {
        switch (unit, value) {
        case (.day, 1): return "dia"
        case (.day, _): return "dias"
        case (.week, _): return "sem"
        case (.month, _): return "mês"
        case (.year, _): return "ano"
        @unknown default: return ""
        }
    }

    private func periodInMonths(_ period: SubscriptionPeriod) -> Int {
        switch period.unit {
        case .month: return period.value
        case .year: return period.value * 12
        default: return 1
        }
    }

    init(
        storage: StorageService,
        premiumService: PremiumService? = nil,
        placement: String = "home",
        onComplete: @escaping () -> Void,
        onSkip: (() -> Void)?
    ) {
        self.storage = storage
        self._premiumService = State(initialValue: premiumService ?? PremiumService())
        self.placement = placement
        self.onComplete = onComplete
        self.onSkip = onSkip
        self.variant = PaywallVariant.assigned()
    }

    var body: some View {
        ZStack {
            AppTheme.cream
                .ignoresSafeArea()

            if premiumService.isLoadingOfferings {
                LoadingStateView(message: "Preparando seus planos...")
            } else if premiumService.availablePackages.isEmpty && !premiumService.isLoadingOfferings {
                emptyOfferingsState
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 40)
                        heroSection
                        benefitsSection
                        planCards
                        ctaButton
                        restoreButton
                        guaranteeText
                        skipButton
                    }
                    .padding(.horizontal, 28)
                }
                .scrollIndicators(.hidden)
            }
        }
        .alert("Ops!", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
        .task {
            await premiumService.fetchOfferings()
            let offeringId = premiumService.currentOffering?.identifier ?? "default"
            AnalyticsService.shared.track(.paywallViewed, params: [
                "placement": placement,
                "offering_id": offeringId,
                "variant": variant.rawValue
            ])
        }
        .onChange(of: premiumService.purchaseState) { _, newValue in
            if case .error(let msg) = newValue {
                errorMessage = msg
                showError = true
            }
        }
    }

    private var emptyOfferingsState: some View {
        ErrorStateView(
            message: "Verifique sua conexão e tente novamente.",
            retryAction: { Task { await premiumService.fetchOfferings() } }
        )
        .overlay(alignment: .bottom) {
            if let onSkip {
                Button {
                    onSkip()
                } label: {
                    Text("Continuar sem plano")
                        .font(AppTheme.sansFont(.footnote))
                        .foregroundStyle(AppTheme.charcoalLight)
                        .underline()
                }
                .padding(.bottom, 50)
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.roseLight.opacity(0.5))
                    .frame(width: 90, height: 90)
                    .blur(radius: 15)

                Circle()
                    .fill(AppTheme.roseLight)
                    .frame(width: 70, height: 70)

                Image(systemName: "flame.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(AppTheme.rose)
            }

            VStack(spacing: 8) {
                Text(variant.headline)
                    .font(AppTheme.serifFont(.title2, weight: .bold))
                    .foregroundStyle(AppTheme.charcoal)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                Text(variant.subheadline.prefix(1).uppercased() + variant.subheadline.dropFirst())
                    .font(AppTheme.sansFont(.subheadline))
                    .foregroundStyle(AppTheme.charcoalLight)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .padding(.bottom, 28)
    }

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(variant.benefits, id: \.text) { benefit in
                BenefitRow(icon: benefit.icon, text: benefit.text, color: benefit.color)
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: AppTheme.cardShadow, radius: 6, y: 2)
        .padding(.bottom, 24)
    }

    private func monthlyBreakdownText(for package: Package) -> String? {
        guard package.packageType == .annual,
              let subPeriod = package.storeProduct.subscriptionPeriod else { return nil }
        let months = periodInMonths(subPeriod)
        guard months > 1 else { return nil }
        let monthlyPrice = package.storeProduct.price as Decimal / Decimal(months)
        let currencyCode = package.storeProduct.currencyCode ?? "USD"
        let formatted = monthlyPrice.formatted(.currency(code: currencyCode))
        return "(\(formatted)/\(formatPeriodUnit(.month, value: 1)))"
    }

    private var planCards: some View {
        VStack(spacing: 10) {
            ForEach(premiumService.availablePackages, id: \.identifier) { package in
                PlanCardRow(
                    package: package,
                    isSelected: premiumService.selectedPackage?.identifier == package.identifier,
                    periodLabel: package.storeProduct.subscriptionPeriod.map { "/" + formatPeriodUnit($0.unit, value: $0.value) },
                    monthlyBreakdown: monthlyBreakdownText(for: package),
                    onSelect: {
                        withAnimation(.spring(duration: 0.3)) {
                            premiumService.selectedPackage = package
                        }
                    }
                )
            }
        }
        .padding(.bottom, 24)
        .sensoryFeedback(.selection, trigger: premiumService.selectedPackage?.identifier)
    }

    private var ctaButton: some View {
        Button {
            Task {
                guard let package = premiumService.selectedPackage else { return }
                let hasTrial = package.storeProduct.introductoryDiscount?.paymentMode == .freeTrial
                let success = await premiumService.purchase()
                if success {
                    storage.syncPremium(premiumService.isPremium)
                    if hasTrial {
                        AnalyticsService.shared.track(.trialStarted, params: [
                            "product_id": package.storeProduct.productIdentifier,
                            "price": package.storeProduct.localizedPriceString
                        ])
                    }
                    AnalyticsService.shared.track(.subscriptionPurchased, params: [
                        "product_id": package.storeProduct.productIdentifier,
                        "price": package.storeProduct.localizedPriceString,
                        "is_trial": "\(hasTrial)",
                        "variant": variant.rawValue
                    ])
                    onComplete()
                }
            }
        } label: {
            Group {
                if premiumService.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    VStack(spacing: 3) {
                        Text(ctaMainText)
                            .font(AppTheme.sansFont(.body, weight: .bold))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.75)
                            .lineLimit(1)

                        if !ctaSubtitle.isEmpty {
                            Text(ctaSubtitle)
                                .font(AppTheme.sansFont(.caption))
                                .foregroundStyle(.white.opacity(0.85))
                                .minimumScaleFactor(0.75)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(AppTheme.rose)
            .clipShape(.rect(cornerRadius: 14))
        }
        .disabled(premiumService.isLoading || premiumService.selectedPackage == nil)
        .padding(.bottom, 12)
    }

    private var restoreButton: some View {
        Button {
            Task {
                let restored = await premiumService.restore()
                if restored {
                    storage.syncPremium(true)
                    onComplete()
                }
            }
        } label: {
            Text("Restaurar compras")
                .font(AppTheme.sansFont(.footnote))
                .foregroundStyle(AppTheme.charcoalLight)
        }
        .disabled(premiumService.isLoading)
        .padding(.bottom, 12)
    }

    private var guaranteeText: some View {
        HStack(spacing: 6) {
            Image(systemName: "lock.shield.fill")
                .font(.caption2)
                .foregroundStyle(AppTheme.sage)
            Text("Cancele quando quiser · Sem compromisso")
                .font(AppTheme.sansFont(.caption))
                .foregroundStyle(AppTheme.charcoalLight)
        }
        .padding(.bottom, 16)
    }

    @ViewBuilder
    private var skipButton: some View {
        if let onSkip {
            Button {
                onSkip()
            } label: {
                Text("Continuar com versão gratuita")
                    .font(AppTheme.sansFont(.footnote))
                    .foregroundStyle(AppTheme.charcoalLight.opacity(0.7))
                    .underline()
            }
            .disabled(premiumService.isLoading)
            .padding(.bottom, 50)
        }
    }
}

private struct PlanCardRow: View {
    let package: Package
    let isSelected: Bool
    let periodLabel: String?
    let monthlyBreakdown: String?
    let onSelect: () -> Void

    private var isAnnual: Bool { package.packageType == .annual }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                selectionIndicator
                packageInfo
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? AppTheme.roseLight.opacity(0.2) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? AppTheme.rose.opacity(0.4) : AppTheme.creamDark, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var selectionIndicator: some View {
        ZStack {
            Circle()
                .fill(isSelected ? AppTheme.rose : .clear)
                .frame(width: 22, height: 22)
            Circle()
                .strokeBorder(isSelected ? AppTheme.rose : AppTheme.creamDark, lineWidth: 2)
                .frame(width: 22, height: 22)
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }

    private var packageInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                Text(package.storeProduct.localizedTitle)
                    .font(AppTheme.sansFont(.body, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)

                if isAnnual {
                    Text("Mais Popular")
                        .font(AppTheme.sansFont(.caption2, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppTheme.sage)
                        .clipShape(.rect(cornerRadius: 6))
                }
            }

            priceRow
        }
    }

    private var priceRow: some View {
        HStack(spacing: 6) {
            Text(package.storeProduct.localizedPriceString)
                .font(AppTheme.sansFont(.subheadline, weight: .medium))
                .foregroundStyle(AppTheme.rose)

            if let periodLabel {
                Text(periodLabel)
                    .font(AppTheme.sansFont(.caption))
                    .foregroundStyle(AppTheme.charcoalLight)
            }

            if let monthlyBreakdown {
                Text(monthlyBreakdown)
                    .font(AppTheme.sansFont(.caption))
                    .foregroundStyle(AppTheme.charcoalLight)
            }
        }
    }
}

private struct BenefitRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
                .frame(width: 24)

            Text(text)
                .font(AppTheme.sansFont(.subheadline))
                .foregroundStyle(AppTheme.charcoal)
        }
    }
}
