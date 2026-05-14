import Foundation

@Observable
class NathIAViewModel {
    var messages: [ChatMessage] = []
    var inputText: String = ""
    var isLoading: Bool = false
    var showPaywall: Bool = false

    let gatingEngine: NathIAGatingEngine

    private let service = NathIAService()
    private let storageKey = "mp_v1_nathia_chat"
    private let premiumService: PremiumService

    var gatingState: GatingState {
        gatingEngine.gatingState
    }

    var hasValidInput: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var messagesRemaining: Int {
        gatingEngine.messagesRemaining
    }

    var userMessageCount: Int {
        gatingEngine.currentMessageCount
    }

    init(premiumService: PremiumService) {
        self.premiumService = premiumService
        self.gatingEngine = NathIAGatingEngine(premiumService: premiumService)
        loadMessages()
        if messages.isEmpty {
            let welcome = ChatMessage(
                role: .assistant,
                content: "Oi, mamãe! 💕 Eu sou a NathIA, sua companheira virtual de maternidade. Pode me perguntar qualquer coisa sobre cuidados com o bebê, autocuidado, amamentação, ou só desabafar mesmo. Tô aqui pra você! 🤗"
            )
            messages.append(welcome)
            saveMessages()
        }
    }

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isLoading else { return }

        let gateResult = gatingEngine.handleMessageSend()

        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        inputText = ""
        saveMessages()

        AnalyticsService.shared.track(.nathiaMessageSent, params: [
            "message_length": "\(text.count)",
            "gating_state": "\(gatingState)"
        ])

        if !gateResult.canProceed {
            showPaywall = true
            AnalyticsService.shared.track(.paywallViewed, params: [
                "context": "nathia_hard_gate"
            ])
            return
        }

        isLoading = true

        Task {
            let response = await service.sendMessage(messages: messages)
            if var responseText = response {
                if let injected = gateResult.injectedResponse {
                    responseText += "\n\n---\n\n" + injected
                }
                let assistantMessage = ChatMessage(role: .assistant, content: responseText)
                messages.append(assistantMessage)
            } else {
                let fallback = ChatMessage(
                    role: .assistant,
                    content: "Desculpa, mamãe! Tive um probleminha aqui. 😅 Tenta de novo daqui a pouquinho?"
                )
                messages.append(fallback)
            }
            isLoading = false
            saveMessages()

            if gateResult.shouldShowPaywall {
                try? await Task.sleep(for: .seconds(1.5))
                showPaywall = true
            }
        }
    }

    func clearChat() {
        messages = [
            ChatMessage(
                role: .assistant,
                content: "Oi, mamãe! 💕 Chat limpinho! Pode começar uma nova conversa comigo. Tô aqui pra você! 🤗"
            )
        ]
        saveMessages()
    }

    func refreshGating() {
        gatingEngine.recalculate()
    }

    private func saveMessages() {
        let recent = Array(messages.suffix(50))
        guard let data = try? JSONEncoder().encode(recent) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func loadMessages() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([ChatMessage].self, from: data) else { return }
        messages = decoded
    }
}
