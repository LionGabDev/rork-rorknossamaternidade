import SwiftUI

nonisolated enum OnboardingStep: Int, CaseIterable, Sendable {
    case welcome = 0
    case painTags = 1
    case socialProof = 2
    case juramento = 3
    case previewPlan = 4
    case paywall = 5
}

@Observable
class OnboardingViewModel {
    var currentStep: OnboardingStep = .welcome
    var selectedPain: MainPain?

    var stepIndex: Int {
        max(currentStep.rawValue - 1, 0)
    }

    var totalMiddleSteps: Int { 4 }

    func advance() {
        withAnimation(.easeInOut(duration: 0.4)) {
            guard let next = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }
            currentStep = next
        }
    }

    func goBack() {
        withAnimation(.easeInOut(duration: 0.4)) {
            guard let prev = OnboardingStep(rawValue: currentStep.rawValue - 1) else { return }
            currentStep = prev
        }
    }

    func applyToStorage(_ storage: StorageService) {
        storage.profile.mainPain = selectedPain
        if storage.profile.stage == nil {
            storage.profile.stage = .mother
        }
        storage.completeOnboarding()
        AnalyticsService.shared.track(.onboardingCompleted, params: [
            "pain": selectedPain?.rawValue ?? "none",
            "duration_sec": "\(AnalyticsService.shared.onboardingDurationSec())"
        ])
    }
}
