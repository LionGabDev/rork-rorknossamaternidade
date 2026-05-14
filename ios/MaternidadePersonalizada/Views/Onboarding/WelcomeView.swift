import SwiftUI

struct WelcomeView: View {
    let onStart: () -> Void

    @State private var breathScale: CGFloat = 0.85
    @State private var breathOpacity: Double = 0.3
    @State private var isBreathing: Bool = false
    @State private var showLine1: Bool = false
    @State private var showLine2: Bool = false
    @State private var showLine3: Bool = false
    @State private var showButton: Bool = false

    var body: some View {
        ZStack {
            AppTheme.cream
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                breathingOrb
                    .padding(.bottom, 48)

                VStack(spacing: 20) {
                    if showLine1 {
                        Text("Tire a armadura agora.")
                            .font(AppTheme.serifFont(.title3, weight: .medium))
                            .foregroundStyle(AppTheme.charcoal)
                            .multilineTextAlignment(.center)
                            .transition(.opacity.combined(with: .offset(y: 8)))
                    }

                    if showLine2 {
                        Text("Aqui dentro ninguém vai te julgar.\nVocê está segura.")
                            .font(AppTheme.sansFont(.body))
                            .foregroundStyle(AppTheme.charcoalLight)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .transition(.opacity.combined(with: .offset(y: 8)))
                    }

                    if showLine3 {
                        Text("Você sobreviveu a hoje.\nRespire.")
                            .font(AppTheme.serifFont(.title2, weight: .bold))
                            .foregroundStyle(AppTheme.rose)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .transition(.opacity.combined(with: .offset(y: 8)))
                    }
                }
                .padding(.horizontal, 32)

                Spacer()

                if showButton {
                    Button {
                        onStart()
                    } label: {
                        Text("Estou pronta")
                            .font(AppTheme.sansFont(.body, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppTheme.rose)
                            .clipShape(.rect(cornerRadius: 14))
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 50)
                    .transition(.opacity.combined(with: .offset(y: 16)))
                }
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: showLine3)
        .onAppear {
            startBreathingAnimation()
            startTextSequence()
        }
    }

    private var breathingOrb: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppTheme.roseLight.opacity(0.6), AppTheme.roseLight.opacity(0.0)],
                        center: .center,
                        startRadius: 20,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(breathScale)
                .opacity(breathOpacity)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppTheme.rose.opacity(0.25), AppTheme.roseLight.opacity(0.1)],
                        center: .center,
                        startRadius: 5,
                        endRadius: 50
                    )
                )
                .frame(width: 100, height: 100)
                .scaleEffect(breathScale)

            Circle()
                .fill(AppTheme.roseLight)
                .frame(width: 56, height: 56)

            Image(systemName: "wind")
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(AppTheme.rose)
        }
    }

    private func startBreathingAnimation() {
        withAnimation(
            .easeInOut(duration: 4.0)
            .repeatForever(autoreverses: true)
        ) {
            breathScale = 1.15
            breathOpacity = 0.7
            isBreathing = true
        }
    }

    private func startTextSequence() {
        withAnimation(.easeOut(duration: 0.8).delay(1.0)) {
            showLine1 = true
        }
        withAnimation(.easeOut(duration: 0.8).delay(3.5)) {
            showLine2 = true
        }
        withAnimation(.easeOut(duration: 0.8).delay(6.5)) {
            showLine3 = true
        }
        withAnimation(.easeOut(duration: 0.6).delay(8.5)) {
            showButton = true
        }
    }
}
