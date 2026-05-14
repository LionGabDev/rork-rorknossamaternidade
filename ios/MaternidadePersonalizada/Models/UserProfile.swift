import Foundation

nonisolated struct UserProfile: Codable, Sendable {
    var userName: String = ""
    var stage: MaternalStage?
    var mainPain: MainPain?
    var pregnancyWeek: Int?
    var babyAgeMonths: Int?
    var hasCompletedOnboarding: Bool = false
    var isPremium: Bool = false
}
