import Foundation

@Observable
class MundoDaNathViewModel {
    var posts: [NathPost] = []
    var desabafos: [Desabafo] = []
    private let storageKey = "mp_v1_nath_posts"
    private let desabafosKey = "mp_v1_desabafos"

    init() {
        loadPosts()
        loadDesabafos()
        if posts.isEmpty {
            posts = Self.samplePosts()
            savePosts()
        }
    }

    func toggleLike(_ postId: UUID) {
        guard let idx = posts.firstIndex(where: { $0.id == postId }) else { return }
        posts[idx].isLiked.toggle()
        posts[idx].likesCount += posts[idx].isLiked ? 1 : -1
        savePosts()
        // TODO: share_tapped — ligar aqui quando compartilhar post for implementado
    }

    func addComment(to postId: UUID, authorName: String, text: String) {
        guard let idx = posts.firstIndex(where: { $0.id == postId }) else { return }
        let comment = NathComment(authorName: authorName, text: text)
        posts[idx].comments.append(comment)
        savePosts()
        // TODO: share_tapped — ligar aqui quando comentário for compartilhado
    }

    func addDesabafo(text: String, tags: [DesabafoTag], authorName: String) {
        let name = authorName.isEmpty ? "Mamãe Valente" : authorName
        let desabafo = Desabafo(text: text, tags: tags, authorName: name)
        desabafos.insert(desabafo, at: 0)
        saveDesabafos()
    }

    func toggleDesabafoLike(_ id: UUID) {
        guard let idx = desabafos.firstIndex(where: { $0.id == id }) else { return }
        desabafos[idx].isLiked.toggle()
        desabafos[idx].likesCount += desabafos[idx].isLiked ? 1 : -1
        saveDesabafos()
    }

    func addDesabafoComment(to id: UUID, authorName: String, text: String) {
        guard let idx = desabafos.firstIndex(where: { $0.id == id }) else { return }
        let comment = NathComment(authorName: authorName, text: text)
        desabafos[idx].comments.append(comment)
        saveDesabafos()
    }

    private func savePosts() {
        guard let data = try? JSONEncoder().encode(posts) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func loadPosts() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([NathPost].self, from: data) else { return }
        posts = decoded
    }

    private func saveDesabafos() {
        guard let data = try? JSONEncoder().encode(desabafos) else { return }
        UserDefaults.standard.set(data, forKey: desabafosKey)
    }

    private func loadDesabafos() {
        guard let data = UserDefaults.standard.data(forKey: desabafosKey),
              let decoded = try? JSONDecoder().decode([Desabafo].self, from: data) else { return }
        desabafos = decoded
    }

    private static func samplePosts() -> [NathPost] {
        let cal = Calendar.current
        let now = Date()
        return [
            NathPost(
                imageURL: "https://pub-e001eb4506b145aa938b5d3badbff6a5.r2.dev/attachments/1ewa5475ljztisu2zkho4",
                caption: "Domingo de chamego com meu pequeno e a Luna 🐶💙 Esses momentos simples são os mais especiais da minha vida. Não troco por nada!",
                date: cal.date(byAdding: .hour, value: -2, to: now) ?? now,
                likesCount: 234
            ),
            NathPost(
                caption: "Mães, vocês sabiam que é NORMAL se sentir exausta e feliz ao mesmo tempo? 🤍 Hoje tive um dia intenso, mas quando olho pra carinha dele dormindo, tudo vale a pena. Cuidem de vocês também, tá? Vocês merecem!",
                date: cal.date(byAdding: .hour, value: -8, to: now) ?? now,
                likesCount: 412
            ),
            NathPost(
                imageURL: "https://pub-e001eb4506b145aa938b5d3badbff6a5.r2.dev/attachments/eoitk4lshjcjsh7oeizyg",
                caption: "Voltei pro treino! 💪 Respeitando meu corpo, no meu tempo. Nada de cobrança, só amor próprio. Quem mais tá nessa jornada comigo?",
                date: cal.date(byAdding: .day, value: -1, to: now) ?? now,
                likesCount: 567
            ),
            NathPost(
                caption: "Dica rápida: quando o bebê tá muito agitado, coloquem ele no colo e façam aquele balanço suave. Funciona como mágica! 🌙✨ O ritmo lembra o útero e acalma rapidinho.",
                date: cal.date(byAdding: .day, value: -2, to: now) ?? now,
                likesCount: 189
            ),
            NathPost(
                caption: "Recebi tantas mensagens lindas de vocês essa semana... 🥹💕 Cada uma me motiva a continuar compartilhando nossa jornada. Obrigada por estarem comigo! Esse app é nosso cantinho.",
                date: cal.date(byAdding: .day, value: -3, to: now) ?? now,
                likesCount: 891
            ),
        ]
    }
}
