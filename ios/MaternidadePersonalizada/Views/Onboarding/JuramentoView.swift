import SwiftUI

struct JuramentoView: View {
    let onContinue: () -> Void

    @State private var showIcon: Bool = false
    @State private var showText: Bool = false
    @State private var showButton: Bool = false
    @State private var hasPromised: Bool = false
    @State private var glowOpacity: Double = 0.4

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 36) {
                if showIcon {
                    ZStack {
                        Circle()
                            .fill(AppTheme.roseLight.opacity(glowOpacity))
                            .frame(width: 120, height: 120)
                            .blur(radius: 18)

                        Circle()
                            .fill(AppTheme.roseLight)
                            .frame(width: 80, height: 80)

                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(AppTheme.rose)
                    }
                    .transition(.scale(scale: 0.7).combined(with: .opacity))
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: glowOpacity
                    )
                }

                if showText {
                    VStack(spacing: 20) {
                        Text("Nosso único trato:")
                            .font(AppTheme.sansFont(.subheadline, weight: .medium))
                            .foregroundStyle(AppTheme.charcoalLight)

                        Text("Aqui dentro, você não\nprecisa ser perfeita.")
                            .font(AppTheme.serifFont(.title2, weight: .bold))
                            .foregroundStyle(AppTheme.charcoal)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)

                        Text("Pode chegar com cansaço, culpa, medo.\nEu seguro o espaço para você.")
                            .font(AppTheme.sansFont(.body))
                            .foregroundStyle(AppTheme.charcoalLight)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.top, 4)
                    }
                    .transition(.opacity.combined(with: .offset(y: 12)))
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            if showButton {
                VStack(spacing: 16) {
                    Button {
                        withAnimation(.spring(duration: 0.4)) {
                            hasPromised = true
                        }
                        HapticFeedback.impact(.heavy)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            onContinue()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if hasPromised {
                                Image(systemName: "checkmark")
                                    .font(.body.weight(.bold))
                                    .transition(.scale.combined(with: .opacity))
                            }

                            Text(hasPromised ? "Promessa feita" : "Eu Prometo")
                                .font(AppTheme.sansFont(.body, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: hasPromised
                                    ? [AppTheme.sage, AppTheme.sageDark]
                                    : [AppTheme.rose, AppTheme.roseDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 16))
                        .shadow(color: (hasPromised ? AppTheme.sage : AppTheme.rose).opacity(0.3), radius: 8, y: 3)
                        .scaleEffect(hasPromised ? 1.02 : 1.0)
                    }
                    .disabled(hasPromised)

                    if hasPromised {
                        Text("Sua promessa foi guardada com carinho.")
                            .font(AppTheme.sansFont(.caption))
                            .foregroundStyle(AppTheme.sageDark)
                            .transition(.opacity.combined(with: .offset(y: 6)))
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 50)
                .transition(.opacity.combined(with: .offset(y: 16)))
            }
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: hasPromised)
        .onAppear {
            withAnimation(.spring(duration: 0.6).delay(0.3)) {
                showIcon = true
            }
            withAnimation(.easeOut(duration: 0.7).delay(1.0)) {
                showText = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(2.2)) {
                showButton = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                glowOpacity = 0.8
            }
        }
    }
}

#Preview {
    JuramentoView(onContinue: {})
}
