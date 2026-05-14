import Foundation

nonisolated enum MaternalStage: String, CaseIterable, Codable, Sendable, Identifiable {
    case trying = "TRYING"
    case pregnant = "PREGNANT"
    case postpartum = "POSTPARTUM"
    case mother = "MOTHER"

    nonisolated var id: String { rawValue }

    var title: String {
        switch self {
        case .trying: "Tentando engravidar"
        case .pregnant: "Grávida"
        case .postpartum: "Puerpério"
        case .mother: "Mãe"
        }
    }

    var subtitle: String {
        switch self {
        case .trying: "Preparando o caminho"
        case .pregnant: "Esperando meu bebê"
        case .postpartum: "Primeiros meses"
        case .mother: "Minha jornada"
        }
    }

    var icon: String {
        switch self {
        case .trying: "heart.circle.fill"
        case .pregnant: "moon.stars.fill"
        case .postpartum: "star.fill"
        case .mother: "sparkles"
        }
    }

    var emoji: String {
        switch self {
        case .trying: "🌸"
        case .pregnant: "🤰"
        case .postpartum: "👶"
        case .mother: "💛"
        }
    }
}
