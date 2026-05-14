import Foundation

nonisolated enum ContentPreference: String, CaseIterable, Codable, Sendable, Identifiable {
    case practical = "PRACTICAL"
    case emotional = "EMOTIONAL"
    case scientific = "SCIENTIFIC"

    nonisolated var id: String { rawValue }

    var label: String {
        switch self {
        case .practical: "Dicas Práticas"
        case .emotional: "Apoio Emocional"
        case .scientific: "Base Científica"
        }
    }

    var icon: String {
        switch self {
        case .practical: "lightbulb.fill"
        case .emotional: "heart.fill"
        case .scientific: "book.fill"
        }
    }
}
