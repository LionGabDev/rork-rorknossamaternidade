import Foundation

nonisolated struct NathPost: Codable, Sendable, Identifiable {
    let id: UUID
    let imageURL: String?
    let caption: String
    let date: Date
    var likesCount: Int
    var isLiked: Bool
    var comments: [NathComment]

    init(id: UUID = UUID(), imageURL: String? = nil, caption: String, date: Date = Date(), likesCount: Int = 0, isLiked: Bool = false, comments: [NathComment] = []) {
        self.id = id
        self.imageURL = imageURL
        self.caption = caption
        self.date = date
        self.likesCount = likesCount
        self.isLiked = isLiked
        self.comments = comments
    }
}

nonisolated struct NathComment: Codable, Sendable, Identifiable {
    let id: UUID
    let authorName: String
    let text: String
    let date: Date

    init(id: UUID = UUID(), authorName: String, text: String, date: Date = Date()) {
        self.id = id
        self.authorName = authorName
        self.text = text
        self.date = date
    }
}
