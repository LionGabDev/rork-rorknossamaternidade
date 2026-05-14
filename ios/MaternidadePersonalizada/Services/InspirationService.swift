import Foundation

nonisolated struct ZenQuoteResponse: Codable, Sendable {
    let q: String
    let a: String
}

@Observable
class InspirationService {
    var quote: String = ""
    var author: String = ""
    var isLoading: Bool = false
    var hasFetched: Bool = false

    private let cacheQuoteKey = "inspiration_quote"
    private let cacheAuthorKey = "inspiration_author"
    private let cacheDateKey = "inspiration_date"

    func fetchDailyQuote(stage: MaternalStage?) async {
        if loadFromCache() { return }

        isLoading = true
        defer { isLoading = false }

        let apiURL = "https://zenquotes.io/api/today"
        guard let url = URL(string: apiURL) else {
            applyFallback(stage: stage)
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                applyFallback(stage: stage)
                return
            }
            let quotes = try JSONDecoder().decode([ZenQuoteResponse].self, from: data)
            if let first = quotes.first, first.q != "Too many requests. Obtain an auth key for unlimited access at https://zenquotes.io" {
                quote = "\u{201C}\(first.q)\u{201D}"
                author = first.a
                hasFetched = true
                saveToCache(quote: quote, author: author)
            } else {
                applyFallback(stage: stage)
            }
        } catch {
            applyFallback(stage: stage)
        }
    }

    private func loadFromCache() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        guard let cachedDate = UserDefaults.standard.object(forKey: cacheDateKey) as? Date,
              Calendar.current.isDate(cachedDate, inSameDayAs: today),
              let q = UserDefaults.standard.string(forKey: cacheQuoteKey),
              let a = UserDefaults.standard.string(forKey: cacheAuthorKey) else {
            return false
        }
        quote = q
        author = a
        hasFetched = true
        return true
    }

    private func saveToCache(quote: String, author: String) {
        UserDefaults.standard.set(Date(), forKey: cacheDateKey)
        UserDefaults.standard.set(quote, forKey: cacheQuoteKey)
        UserDefaults.standard.set(author, forKey: cacheAuthorKey)
    }

    private func applyFallback(stage: MaternalStage?) {
        let pool = Self.fallbackQuotes(for: stage)
        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let pick = pool[dayIndex % pool.count]
        quote = pick.text
        author = pick.author
        hasFetched = true
        saveToCache(quote: quote, author: author)
    }

    private static func fallbackQuotes(for stage: MaternalStage?) -> [(text: String, author: String)] {
        var shared: [(String, String)] = [
            ("Cada dia é uma nova oportunidade de crescer com amor.", ""),
            ("Ser mãe é descobrir forças que você não sabia que tinha.", ""),
            ("O amor de mãe é o combustível que permite a um ser humano fazer o impossível.", "Marion C. Garretty"),
            ("Não existe manual para ser mãe, mas existe coração.", ""),
            ("A maternidade é a maior escola de paciência e amor.", ""),
            ("Cuide de você para poder cuidar de quem mais ama.", ""),
            ("Você não precisa ser perfeita. Precisa ser presente.", ""),
            ("Respire fundo. Você está fazendo um trabalho incrível.", ""),
        ]

        switch stage {
        case .trying:
            shared.append(contentsOf: [
                ("Confie no seu corpo e no seu tempo. Cada passo conta.", ""),
                ("A espera tem o poder de fortalecer o desejo mais bonito.", ""),
            ])
        case .pregnant:
            shared.append(contentsOf: [
                ("Seu corpo está criando vida. Isso é extraordinário.", ""),
                ("Cada semana é um novo capítulo dessa história linda.", ""),
            ])
        case .postpartum:
            shared.append(contentsOf: [
                ("Os primeiros dias são intensos, mas passam. O amor fica.", ""),
                ("Peça ajuda. Aceitar apoio é um ato de coragem.", ""),
            ])
        case .mother, nil:
            shared.append(contentsOf: [
                ("Ser mãe é aprender que o amor pode ser maior a cada dia.", ""),
                ("Seus filhos não precisam de uma mãe perfeita, precisam de uma mãe feliz.", ""),
            ])
        }

        return shared
    }
}
