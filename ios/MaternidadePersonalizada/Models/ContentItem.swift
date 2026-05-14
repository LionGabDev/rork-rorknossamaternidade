import Foundation

nonisolated struct ContentItem: Identifiable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let icon: String
    let type: ContentType
    let isPremium: Bool
    let duration: String?

    nonisolated enum ContentType: String, Sendable {
        case audio
        case video
        case article
        case thread
    }
}

extension ContentItem {
    static let mockFeed: [ContentItem] = [
        ContentItem(
            id: UUID(), title: "Respiração para acalmar",
            subtitle: "Áudio guiado · Cantinho da Criadora",
            icon: "waveform.circle.fill", type: .audio,
            isPremium: false, duration: "5 min"
        ),
        ContentItem(
            id: UUID(), title: "O corpo depois do parto",
            subtitle: "Vídeo · Conversa honesta",
            icon: "play.rectangle.fill", type: .video,
            isPremium: true, duration: "12 min"
        ),
        ContentItem(
            id: UUID(), title: "Amamentação sem culpa",
            subtitle: "Artigo · Dicas práticas",
            icon: "doc.text.fill", type: .article,
            isPremium: false, duration: "4 min leitura"
        ),
        ContentItem(
            id: UUID(), title: "Sono do bebê: o que funciona",
            subtitle: "Áudio · Com especialista",
            icon: "waveform.circle.fill", type: .audio,
            isPremium: true, duration: "8 min"
        ),
        ContentItem(
            id: UUID(), title: "Relação com o parceiro",
            subtitle: "Vídeo · Sem filtro",
            icon: "play.rectangle.fill", type: .video,
            isPremium: false, duration: "10 min"
        ),
    ]

    static let mockThreads: [ContentItem] = [
        ContentItem(
            id: UUID(), title: "Alguém mais com dificuldade para dormir?",
            subtitle: "12 respostas · Atualizado há 2h",
            icon: "bubble.left.and.bubble.right.fill", type: .thread,
            isPremium: true, duration: nil
        ),
        ContentItem(
            id: UUID(), title: "Melhores posições para amamentar",
            subtitle: "8 respostas · Atualizado há 5h",
            icon: "bubble.left.and.bubble.right.fill", type: .thread,
            isPremium: true, duration: nil
        ),
        ContentItem(
            id: UUID(), title: "Ansiedade pós-parto: como lidar?",
            subtitle: "23 respostas · Atualizado ontem",
            icon: "bubble.left.and.bubble.right.fill", type: .thread,
            isPremium: true, duration: nil
        ),
    ]
}
