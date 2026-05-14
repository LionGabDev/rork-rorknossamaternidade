import SwiftUI

struct ContentView: View {
    @State private var storage = StorageService()
    @State private var journal = JournalService()
    @State private var premiumService = PremiumService()
    @State private var inspirationService = InspirationService()
    @State private var appPhase: AppPhase = .loading

    nonisolated private enum AppPhase {
        case loading
        case onboarding
        case home
    }

    var body: some View {
        Group {
            switch appPhase {
            case .loading:
                ZStack {
                    AppTheme.cream
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(AppTheme.rose)
                }

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
            resolvePhase()
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

    private func resolvePhase() {
        if storage.profile.hasCompletedOnboarding {
            appPhase = .home
        } else {
            appPhase = .onboarding
        }
    }
}
