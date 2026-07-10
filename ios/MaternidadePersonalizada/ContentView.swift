import SwiftUI

struct ContentView: View {
    @State private var storage = StorageService()
    @State private var journal = JournalService()
    @State private var premiumService = PremiumService()
    @State private var inspirationService = InspirationService()
    @State private var appPhase: AppPhase = .splash
    @State private var isDataReady: Bool = false

    nonisolated private enum AppPhase {
        case splash
        case onboarding
        case home
    }

    var body: some View {
        Group {
            switch appPhase {
            case .splash:
                SplashScreenView {
                    completeSplashIfReady()
                }
                .zIndex(1)

            case .onboarding:
                OnboardingContainerView(storage: storage, premiumService: premiumService) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        appPhase = .home
                    }
                }

            case .home:
                MainTabView(storage: storage, journal: journal, premiumService: premiumService, inspirationService: inspirationService)
            }
        }
        .task {
            premiumService.configure()
            await premiumService.checkEntitlement()
            storage.syncPremium(premiumService.isPremium)
            wireJournalReset()
            isDataReady = true
            completeSplashIfReady()
        }
        .onChange(of: storage.profile.hasCompletedOnboarding) { _, newValue in
            if !newValue {
                withAnimation(.easeInOut(duration: 0.5)) {
                    appPhase = .onboarding
                }
            }
        }
    }

    private func wireJournalReset() {
        storage.onJournalReset = { [weak journal] in
            Task { @MainActor in
                journal?.resetAll()
            }
        }
    }

    private func completeSplashIfReady() {
        guard appPhase == .splash, isDataReady else { return }
        withAnimation(.easeInOut(duration: 0.5)) {
            resolvePhase()
        }
    }

    private func resolvePhase() {
        if storage.profile.hasCompletedOnboarding {
            appPhase = .home
        } else {
            appPhase = .onboarding
        }
    }
}
