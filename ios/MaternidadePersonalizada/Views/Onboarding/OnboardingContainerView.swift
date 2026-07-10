import SwiftUI

struct OnboardingContainerView: View {
    @State private var viewModel = OnboardingViewModel()
    let storage: StorageService
    let premiumService: PremiumService
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            OnboardingBackground()

            VStack(spacing: 0) {
                if viewModel.currentStep != .welcome && viewModel.currentStep != .paywall {
                    HStack {
                        Button {
                            viewModel.goBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.body.weight(.medium))
                                .foregroundStyle(AppTheme.charcoalLight)
                                .frame(width: 44, height: 44)
                        }

                        Spacer()

                        StepDots(
                            current: viewModel.stepIndex,
                            total: viewModel.totalMiddleSteps
                        )

                        Spacer()

                        Spacer().frame(width: 44)
                    }
                    .padding(.horizontal, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                ZStack {
                    switch viewModel.currentStep {
                    case .welcome:
                        WelcomeView {
                            viewModel.advance()
                        }
                        .transition(.asymmetric(
                            insertion: .opacity,
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                    case .painTags:
                        PainTagsView(
                            selectedPain: $viewModel.selectedPain,
                            onContinue: { viewModel.advance() }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                    case .socialProof:
                        SocialProofView(
                            selectedPain: viewModel.selectedPain,
                            onContinue: { viewModel.advance() }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                    case .juramento:
                        JuramentoView {
                            viewModel.advance()
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                    case .previewPlan:
                        PreviewCardsView(
                            selectedPain: viewModel.selectedPain,
                            onContinue: { viewModel.advance() }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                    case .paywall:
                        PaywallView(
                            storage: storage,
                            premiumService: premiumService,
                            placement: "onboarding",
                            onComplete: {
                                viewModel.applyToStorage(storage)
                                onComplete()
                            },
                            onSkip: {
                                viewModel.applyToStorage(storage)
                                onComplete()
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            AnalyticsService.shared.markOnboardingStart()
            AnalyticsService.shared.track(.onboardingStarted, params: ["source": "app_launch"])
        }
    }
}

private struct StepDots: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? AppTheme.rose : AppTheme.creamDark)
                    .frame(width: index == current ? 20 : 6, height: 6)
                    .animation(.spring(duration: 0.3), value: current)
            }
        }
    }
}
