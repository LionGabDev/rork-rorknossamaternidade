import Foundation

nonisolated struct Desabafo: Codable, Sendable, Identifiable {
    let id: UUID
    let text: String
    let tags: [DesabafoTag]
    let authorName: String
    let date: Date
    var likesCount: Int
    var isLiked: Bool
    var comments: [NathComment]

    init(id: UUID = UUID(), text: String, tags: [DesabafoTag], authorName: String, date: Date = Date(), likesCount: Int = 0, isLiked: Bool = false, comments: [NathComment] = []) {
        self.id = id
        self.text = text
        self.tags = tags
        self.authorName = authorName
        self.date = date
        self.likesCount = likesCount
        self.isLiked = isLiked
        self.comments = comments
    }
}

nonisolated enum DesabafoTag: String, CaseIterable, Codable, Sendable, Identifiable {
    case exhausted = "EXHAUSTED"
    case lonely = "LONELY"
    case guilty = "GUILTY"
    case anxious = "ANXIOUS"
    case overwhelmed = "OVERWHELMED"
    case sad = "SAD"
    case angry = "ANGRY"
    case grateful = "GRATEFUL"
    case hopeful = "HOPEFUL"
    case proud = "PROUD"
    case confused = "CONFUSED"
    case scared = "SCARED"

    nonisolated var id: String { rawValue }

    var label: String {
        switch self {
        case .exhausted: return "Tô exausta"
        case .lonely: return "Solidão"
        case .guilty: return "Culpa"
        case .anxious: return "Ansiedade"
        case .overwhelmed: return "Sobrecarregada"
        case .sad: return "Tristeza"
        case .angry: return "Raiva"
        case .grateful: return "Gratidão"
        case .hopeful: return "Esperança"
        case .proud: return "Orgulho"
        case .confused: return "Confusa"
        case .scared: return "Medo"
        }
    }

    var emoji: String {
        switch self {
        case .exhausted: return "😴"
        case .lonely: return "🤍"
        case .guilty: return "💭"
        case .anxious: return "😰"
        case .overwhelmed: return "🌊"
        case .sad: return "😢"
        case .angry: return "😤"
        case .grateful: return "🙏"
        case .hopeful: return "🌱"
        case .proud: return "💪"
        case .confused: return "🤷‍♀️"
        case .scared: return "😨"
        }
    }
}
