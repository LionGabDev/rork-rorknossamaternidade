import Foundation

nonisolated enum MainPain: String, CaseIterable, Codable, Sendable, Identifiable {
    case limit = "LIMIT"
    case guilt = "GUILT"
    case loneliness = "LONELINESS"
    case fear = "FEAR"

    nonisolated var id: String { rawValue }

    var title: String {
        switch self {
        case .limit: return "Tô no meu limite"
        case .guilt: return "Me sinto culpada"
        case .loneliness: return "Tô sozinha nisso"
        case .fear: return "Tô com medo de errar"
        }
    }

    var emoji: String {
        switch self {
        case .limit: return "🔥"
        case .guilt: return "💭"
        case .loneliness: return "🤍"
        case .fear: return "😰"
        }
    }

    var socialProofCount: String {
        switch self {
        case .limit: return "12.450"
        case .guilt: return "9.830"
        case .loneliness: return "11.270"
        case .fear: return "8.690"
        }
    }

    var planDays: [(day: Int, title: String, description: String)] {
        [
            (1, "Batismo Sensorial", "Reconecte com seu corpo e seus sentidos. Um ritual de 5 minutos para desligar o piloto automático."),
            (2, "Extração do Veneno", "Coloque para fora o que está te corroendo. Sem filtro, sem julgamento."),
            (3, "Prova Social", "Descubra que milhares de mães sentem exatamente o que você sente — e encontraram um caminho."),
            (4, "Celebração da Maestria", "Reconheça o quanto você já conquistou. Você é mais forte do que imagina.")
        ]
    }
}
