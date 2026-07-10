import SwiftUI

struct SocialProofView: View {
    let selectedPain: MainPain?
    let onContinue: () -> Void

    @State private var showHeader: Bool = false
    @State private var showCount: Bool = false
    @State private var showMessage: Bool = false
    @State private var showButton: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var floatingOffset: CGFloat = 0

    private var pain: MainPain {
        selectedPain ?? .limit
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                communityOrb

                VStack(spacing: 18) {
                    if showHeader {
                        Text("Você não está sozinha.")
                            .font(AppTheme.serifFont(.title2, weight: .bold))
                            .foregroundStyle(AppTheme.charcoal)
                            .multilineTextAlignment(.center)
                            .transition(.opacity.combined(with: .offset(y: 10)))
                    }

                    if showCount {
                        VStack(spacing: 12) {
                            HStack(spacing: 0) {
                                Text(pain.socialProofCount)
                                    .font(AppTheme.serifFont(.largeTitle, weight: .bold))
                                    .foregroundStyle(AppTheme.roseDark)
                                Text(" mães")
                                    .font(AppTheme.serifFont(.title2, weight: .medium))
                                    .foregroundStyle(AppTheme.charcoal)
                            }

                            Text("aqui também sentiram\n\"\(pain.title)\" hoje.")
                                .font(AppTheme.sansFont(.body))
                                .foregroundStyle(AppTheme.charcoalLight)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .transition(.opacity.combined(with: .offset(y: 10)))
                    }

                    if showMessage {
                        Text("Todas encontraram um caminho.\nVocê também vai.")
                            .font(AppTheme.sansFont(.body, weight: .medium))
                            .foregroundStyle(AppTheme.charcoal)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppTheme.roseLight.opacity(0.25))
                            )
                            .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    }
                }
                .padding(.horizontal, 32)
            }

            Spacer()

            if showButton {
                Button {
                    HapticFeedback.impact(.medium)
                    onContinue()
                } label: {
                    HStack(spacing: 8) {
                        Text("Continuar")
                            .font(AppTheme.sansFont(.body, weight: .semibold))

                        Image(systemName: "arrow.right")
                            .font(.body.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.rose, AppTheme.roseDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 16))
                    .shadow(color: AppTheme.rose.opacity(0.25), radius: 8, y: 3)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
                .transition(.opacity.combined(with: .offset(y: 16)))
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: showCount)
        .onAppear {
            startAnimationSequence()
        }
    }

    private var communityOrb: some View {
        ZStack {
            Circle()
                .fill(AppTheme.roseLight.opacity(0.35))
                .frame(width: 130, height: 130)
                .scaleEffect(pulseScale)
                .offset(y: floatingOffset)

            Circle()
                .fill(AppTheme.roseLight.opacity(0.6))
                .frame(width: 90, height: 90)
                .offset(y: floatingOffset)

            HStack(spacing: -8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(AppTheme.cardBackground)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .strokeBorder(AppTheme.rose.opacity(0.3), lineWidth: 1)
                        )
                        .overlay(
                            Image(systemName: ["person.fill", "person.fill", "person.fill"][index])
                                .font(.system(size: 16))
                                .foregroundStyle(AppTheme.roseDark)
                        )
                        .offset(y: index == 1 ? -6 : 0)
                }
            }
            .offset(y: floatingOffset)
        }
        .animation(
            .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
            value: pulseScale
        )
        .animation(
            .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
            value: floatingOffset
        )
    }

    private func startAnimationSequence() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.08
        }
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            floatingOffset = -8
        }
        withAnimation(.easeOut(duration: 0.7).delay(0.4)) {
            showHeader = true
        }
        withAnimation(.easeOut(duration: 0.7).delay(1.2)) {
            showCount = true
        }
        withAnimation(.easeOut(duration: 0.7).delay(2.2)) {
            showMessage = true
        }
        withAnimation(.easeOut(duration: 0.5).delay(3.4)) {
            showButton = true
        }
    }
}

#Preview {
    SocialProofView(selectedPain: .limit, onContinue: {})
}
