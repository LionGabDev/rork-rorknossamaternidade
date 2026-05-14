import Foundation

nonisolated struct ChatMessage: Codable, Sendable, Identifiable {
    let id: UUID
    let role: ChatRole
    let content: String
    let date: Date

    init(id: UUID = UUID(), role: ChatRole, content: String, date: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.date = date
    }
}

nonisolated enum ChatRole: String, Codable, Sendable {
    case user
    case assistant
}
