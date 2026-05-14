import Foundation

nonisolated enum AnalyticsEvent: String, Sendable {
    case onboardingStarted = "onboarding_started"
    case onboardingCompleted = "onboarding_completed"
    case paywallViewed = "paywall_viewed"
    case trialStarted = "trial_started"
    case subscriptionPurchased = "subscription_purchased"
    case hojeViewed = "hoje_viewed"
    case contentOpened = "content_opened"
    case journalEntryCreated = "journal_entry_created"
    case nathiaMessageSent = "nathia_message_sent"
    case shareTapped = "share_tapped"
}

@Observable
class AnalyticsService {
    static let shared = AnalyticsService()

    private(set) var eventLog: [(event: String, params: [String: String], date: Date)] = []
    private var onboardingStartTime: Date?

    func markOnboardingStart() {
        onboardingStartTime = Date()
    }

    func onboardingDurationSec() -> Int {
        guard let start = onboardingStartTime else { return 0 }
        return Int(Date().timeIntervalSince(start))
    }

    func track(_ event: AnalyticsEvent, params: [String: String] = [:]) {
        let entry = (event: event.rawValue, params: params, date: Date())
        eventLog.append(entry)

        #if DEBUG
        let paramStr = params.isEmpty ? "" : " | \(params)"
        print("[Analytics] \(event.rawValue)\(paramStr)")
        #endif
    }
}
