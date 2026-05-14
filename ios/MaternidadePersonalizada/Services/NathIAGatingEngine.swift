import Foundation

nonisolated enum GatingState: Equatable, Sendable {
    case unlocked
    case freeZone(messagesRemaining: Int)
    case softGate
    case hardGate

    var isInputEnabled: Bool {
        switch self {
        case .unlocked, .freeZone, .softGate: return true
        case .hardGate: return false
        }
    }

    var showPaywallCTA: Bool {
        switch self {
        case .softGate, .hardGate: return true
        default: return false
        }
    }
}

nonisolated struct GatingResult: Sendable {
    let canProceed: Bool
    let injectedResponse: String?
    let shouldShowPaywall: Bool
}

@Observable
class NathIAGatingEngine {
    private(set) var gatingState: GatingState = .unlocked

    private let premiumService: PremiumService
    private let freeMessageLimit: Int
    private let softGateCount: Int
    private let cooldownHours: Int
    private let countKey = "mp_gating_msg_count"
    private let resetKey = "mp_gating_last_reset"

    private let softGateResponse = """
    Para eu te dar a estratégia completa e acompanhar sua jornada de perto, \
    preciso que você entre para o plano completo. 💜

    Lá dentro, eu vou ser sua companheira 24h — sem limites, sem pressa, com tudo \
    que você precisa pra se sentir segura.
    """

    private let hardGateMessage = """
    Eu adoraria continuar te ajudando! 🤗

    Para conversas ilimitadas comigo e acesso ao conteúdo completo, \
    entre para o plano premium. Vai ser uma honra te ter lá dentro.
    """

    private var messageCount: Int {
        get { UserDefaults.standard.integer(forKey: countKey) }
        set { UserDefaults.standard.set(newValue, forKey: countKey) }
    }

    private var lastResetDate: Date? {
        get { UserDefaults.standard.object(forKey: resetKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: resetKey) }
    }

    init(
        premiumService: PremiumService,
        freeMessageLimit: Int = 3,
        softGateCount: Int = 1,
        cooldownHours: Int = 24
    ) {
        self.premiumService = premiumService
        self.freeMessageLimit = freeMessageLimit
        self.softGateCount = softGateCount
        self.cooldownHours = cooldownHours
        checkCooldown()
        recalculate()
    }

    func handleMessageSend() -> GatingResult {
        if premiumService.isPremium {
            return GatingResult(canProceed: true, injectedResponse: nil, shouldShowPaywall: false)
        }

        checkCooldown()
        messageCount += 1
        recalculate()

        switch gatingState {
        case .unlocked:
            return GatingResult(canProceed: true, injectedResponse: nil, shouldShowPaywall: false)

        case .freeZone(let remaining):
            let hint: String? = remaining == 0
                ? "\n\n_💡 Essa foi sua última mensagem gratuita de hoje. Entre para o premium para conversas ilimitadas._"
                : nil
            return GatingResult(canProceed: true, injectedResponse: hint, shouldShowPaywall: false)

        case .softGate:
            return GatingResult(canProceed: true, injectedResponse: softGateResponse, shouldShowPaywall: false)

        case .hardGate:
            return GatingResult(canProceed: false, injectedResponse: nil, shouldShowPaywall: true)
        }
    }

    var currentMessageCount: Int { messageCount }

    var messagesRemaining: Int {
        max(0, freeMessageLimit - messageCount)
    }

    func resetCounter() {
        messageCount = 0
        lastResetDate = Date()
        recalculate()
    }

    func recalculate() {
        if premiumService.isPremium {
            gatingState = .unlocked
            return
        }

        let softGateEnd = freeMessageLimit + softGateCount

        if messageCount < freeMessageLimit {
            let remaining = freeMessageLimit - messageCount
            gatingState = .freeZone(messagesRemaining: remaining)
        } else if messageCount < softGateEnd {
            gatingState = .softGate
        } else {
            gatingState = .hardGate
        }
    }

    private func checkCooldown() {
        guard cooldownHours > 0 else { return }
        if let lastReset = lastResetDate {
            let hoursSince = Date().timeIntervalSince(lastReset) / 3600
            if hoursSince >= Double(cooldownHours) {
                messageCount = 0
                lastResetDate = Date()
            }
        } else {
            lastResetDate = Date()
        }
    }
}
