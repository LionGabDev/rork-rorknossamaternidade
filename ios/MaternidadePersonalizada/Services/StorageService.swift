import Foundation

@Observable
class StorageService {
    var profile: UserProfile

    var onJournalReset: (() -> Void)?

    init() {
        if let data = UserDefaults.standard.data(forKey: StorageKeys.profile),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = decoded
        } else {
            self.profile = UserProfile()
        }
        StorageKeys.ensureVersion()
    }

    func save() {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: StorageKeys.profile)
    }

    func completeOnboarding() {
        profile.hasCompletedOnboarding = true
        save()
    }

    func setPremium(_ value: Bool) {
        profile.isPremium = value
        save()
    }

    func syncPremium(_ value: Bool) {
        if profile.isPremium != value {
            profile.isPremium = value
            save()
        }
    }

    func resetOnboarding() {
        let preservedPremium = profile.isPremium
        profile = UserProfile()
        profile.isPremium = preservedPremium
        save()
        StorageKeys.removeJournalData()
        onJournalReset?()
    }

    func resetAllDebug() {
        profile = UserProfile()
        save()
        StorageKeys.removeAll()
    }
}
