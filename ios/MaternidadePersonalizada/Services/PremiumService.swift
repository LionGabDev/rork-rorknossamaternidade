import Foundation
import RevenueCat

nonisolated enum PurchaseState: Sendable, Equatable {
    case idle
    case loading
    case success
    case error(String)
}

nonisolated enum PurchaseError: Error, Sendable, Equatable {
    case cancelled
    case paymentPending
    case networkError
    case storeError(String)
    case notAllowed
    case restoreFailed
    case unknown(String)

    var userMessage: String {
        switch self {
        case .cancelled:
            return "Compra cancelada. Sem problemas, estaremos aqui quando você decidir."
        case .paymentPending:
            return "Seu pagamento está sendo processado. O acesso será liberado assim que confirmado."
        case .networkError:
            return "Sem conexão. Verifique sua internet e tente novamente."
        case .storeError(let detail):
            return "Erro na App Store: \(detail). Tente novamente em alguns minutos."
        case .notAllowed:
            return "Compras não estão habilitadas neste dispositivo."
        case .restoreFailed:
            return "Não conseguimos restaurar suas compras. Tente novamente."
        case .unknown:
            return "Algo inesperado aconteceu. Tente novamente."
        }
    }

    static func from(_ error: Error) -> PurchaseError {
        guard let rcError = error as? ErrorCode else {
            return .unknown(error.localizedDescription)
        }
        switch rcError {
        case .purchaseCancelledError: return .cancelled
        case .paymentPendingError: return .paymentPending
        case .networkError: return .networkError
        case .purchaseNotAllowedError: return .notAllowed
        case .storeProblemError: return .storeError(error.localizedDescription)
        default: return .unknown(rcError.description)
        }
    }
}

@Observable
class PremiumService: NSObject {
    var purchaseState: PurchaseState = .idle
    var isPremium: Bool = false
    var offerings: Offerings?
    var selectedPackage: Package?
    var isLoadingOfferings: Bool = false
    var trialEligibility: [String: IntroEligibilityStatus] = [:]
    var lastError: PurchaseError?

    private let entitlementID = "premium"
    private let gracePeriodDays = 3
    private let cache = SubscriptionCache()
    private var isConfigured = false
    private var errorDismissTask: Task<Void, Never>?

    var isLoading: Bool {
        if case .loading = purchaseState { return true }
        return false
    }

    var currentOffering: Offering? {
        offerings?.current
    }

    var availablePackages: [Package] {
        currentOffering?.availablePackages ?? []
    }

    override init() {
        super.init()
        if let cached = cache.load() {
            isPremium = cached
        }
    }

    func configure() {
        guard !isConfigured else { return }
        #if DEBUG
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY)
        #else
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY)
        #endif
        Purchases.shared.delegate = self
        isConfigured = true
    }

    func isEligibleForTrial(_ package: Package) -> Bool {
        guard let discount = package.storeProduct.introductoryDiscount,
              discount.paymentMode == .freeTrial else { return false }
        let status = trialEligibility[package.storeProduct.productIdentifier]
        return status == .eligible || status == .unknown
    }

    private nonisolated enum FetchResult: Sendable {
        case offerings(Offerings)
        case customerInfo(CustomerInfo)
    }

    func fetchOfferings() async {
        isLoadingOfferings = true
        do {
            let results = try await withThrowingTaskGroup(of: FetchResult.self) { group in
                group.addTask { @Sendable in
                    let offerings = try await Purchases.shared.offerings()
                    return .offerings(offerings)
                }
                group.addTask { @Sendable in
                    let info = try await Purchases.shared.customerInfo()
                    return .customerInfo(info)
                }
                var collected: [FetchResult] = []
                for try await result in group {
                    collected.append(result)
                }
                return collected
            }

            for result in results {
                switch result {
                case .offerings(let o):
                    offerings = o
                case .customerInfo(let info):
                    updatePremiumStatus(from: info)
                }
            }

            if selectedPackage == nil {
                selectedPackage = currentOffering?.availablePackages.first
            }
            await checkEligibility()
        } catch {
            purchaseState = .error("Não foi possível carregar os planos.")
        }
        isLoadingOfferings = false
    }

    private func checkEligibility() async {
        let products = availablePackages.map { $0.storeProduct }
        guard !products.isEmpty else { return }
        for product in products {
            let eligibility = await Purchases.shared.checkTrialOrIntroDiscountEligibility(product: product)
            trialEligibility[product.productIdentifier] = eligibility
        }
    }

    func checkEntitlement() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            updatePremiumStatus(from: info)
        } catch {
            if let cached = cache.load() {
                isPremium = cached
            } else {
                isPremium = false
            }
        }
    }

    func refreshStatus() async {
        if !cache.isExpired, let cached = cache.load() {
            isPremium = cached
            return
        }
        await checkEntitlement()
    }

    func purchase() async -> Bool {
        guard let package = selectedPackage else {
            purchaseState = .error("Selecione um plano.")
            return false
        }
        return await purchase(package: package)
    }

    func purchase(package: Package) async -> Bool {
        purchaseState = .loading
        lastError = nil
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if result.userCancelled {
                purchaseState = .idle
                return false
            }
            if result.customerInfo.entitlements[entitlementID]?.isActive == true {
                updatePremiumStatus(from: result.customerInfo)
                purchaseState = .success
                AnalyticsService.shared.track(.subscriptionPurchased, params: [
                    "product_id": package.storeProduct.productIdentifier
                ])
                return true
            }
            purchaseState = .idle
            return false
        } catch let error as ErrorCode {
            let purchaseErr = PurchaseError.from(error)
            setError(purchaseErr)
            if error == .purchaseCancelledError {
                purchaseState = .idle
            } else {
                purchaseState = .error(purchaseErr.userMessage)
            }
            return false
        } catch {
            let purchaseErr = PurchaseError.from(error)
            setError(purchaseErr)
            purchaseState = .error(purchaseErr.userMessage)
            return false
        }
    }

    func restore() async -> Bool {
        purchaseState = .loading
        lastError = nil
        do {
            let info = try await Purchases.shared.restorePurchases()
            updatePremiumStatus(from: info)
            purchaseState = isPremium ? .success : .idle
            return isPremium
        } catch {
            setError(.restoreFailed)
            purchaseState = .error(PurchaseError.restoreFailed.userMessage)
            return false
        }
    }

    var recommendedPackage: Package? {
        availablePackages.first { $0.packageType == .annual }
            ?? availablePackages.first { $0.packageType == .monthly }
            ?? availablePackages.first
    }

    private func updatePremiumStatus(from info: CustomerInfo) {
        let entitlement = info.entitlements[entitlementID]
        var active = entitlement?.isActive == true

        if !active, let expDate = entitlement?.expirationDate {
            let daysSince = Calendar.current.dateComponents([.day], from: expDate, to: Date()).day ?? 0
            if daysSince <= gracePeriodDays {
                active = true
            }
        }

        isPremium = active
        cache.save(active)
    }

    private func setError(_ error: PurchaseError) {
        lastError = error
        errorDismissTask?.cancel()
        errorDismissTask = Task {
            try? await Task.sleep(for: .seconds(10))
            if !Task.isCancelled {
                lastError = nil
            }
        }
    }
}

extension PremiumService: @preconcurrency PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        updatePremiumStatus(from: customerInfo)
    }
}

private struct SubscriptionCache {
    private let defaults = UserDefaults.standard
    private let stateKey = "mp_sub_cached_premium"
    private let dateKey = "mp_sub_cached_at"
    private let ttl: TimeInterval = 3600

    func save(_ isPremium: Bool) {
        defaults.set(isPremium, forKey: stateKey)
        defaults.set(Date().timeIntervalSince1970, forKey: dateKey)
    }

    func load() -> Bool? {
        guard defaults.object(forKey: stateKey) != nil else { return nil }
        return defaults.bool(forKey: stateKey)
    }

    var isExpired: Bool {
        let cachedAt = defaults.double(forKey: dateKey)
        guard cachedAt > 0 else { return true }
        return Date().timeIntervalSince1970 - cachedAt > ttl
    }
}
