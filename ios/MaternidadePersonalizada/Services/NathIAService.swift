import Foundation

nonisolated struct ToolkitMessage: Codable, Sendable {
    let role: String
    let content: String
}

nonisolated struct ToolkitRequest: Codable, Sendable {
    let messages: [ToolkitMessage]
    let system: String?
}

@Observable
class NathIAService {
    var isLoading: Bool = false
    var error: String?

    private let baseURL: String = Config.EXPO_PUBLIC_TOOLKIT_URL

    func sendMessage(messages: [ChatMessage]) async -> String? {
        isLoading = true
        error = nil
        defer { isLoading = false }

        let toolkitMessages = messages.map { msg in
            ToolkitMessage(role: msg.role == .user ? "user" : "assistant", content: msg.content)
        }

        let endpoint = baseURL.isEmpty
            ? "https://toolkit.rork.com/agent/chat"
            : "\(baseURL)/agent/chat"

        guard let url = URL(string: endpoint) else {
            error = "URL inválida"
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let body = ToolkitRequest(messages: toolkitMessages, system: NathIASystemPrompt.value)

        do {
            request.httpBody = try JSONEncoder().encode(body)
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                error = "Resposta inválida"
                return nil
            }

            if http.statusCode == 200 {
                if let text = String(data: data, encoding: .utf8) {
                    let cleaned = parseStreamResponse(text)
                    if !cleaned.isEmpty {
                        return cleaned
                    }
                }
                error = "Resposta vazia"
                return nil
            } else {
                error = "Erro ao conectar (\(http.statusCode))"
                return nil
            }
        } catch {
            self.error = "Não foi possível conectar. Tente novamente."
            return nil
        }
    }

    private func parseStreamResponse(_ raw: String) -> String {
        var result = ""
        let lines = raw.components(separatedBy: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("0:") {
                let content = trimmed.dropFirst(2).trimmingCharacters(in: .whitespaces)
                if content.hasPrefix("\"") && content.hasSuffix("\"") {
                    let inner = String(content.dropFirst().dropLast())
                    let unescaped = inner
                        .replacingOccurrences(of: "\\n", with: "\n")
                        .replacingOccurrences(of: "\\\"", with: "\"")
                        .replacingOccurrences(of: "\\\\", with: "\\")
                    result += unescaped
                }
            } else if !trimmed.isEmpty && !trimmed.hasPrefix("d:") && !trimmed.hasPrefix("e:") && !trimmed.hasPrefix("f:") {
                if let data = trimmed.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let text = json["text"] as? String {
                    result += text
                } else if let data = trimmed.data(using: .utf8),
                          let str = String(data: data, encoding: .utf8),
                          !str.contains("{") {
                    result += str
                }
            }
        }
        if result.isEmpty {
            result = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return result
    }
}
