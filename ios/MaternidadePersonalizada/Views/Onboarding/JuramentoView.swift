import SwiftUI

struct JuramentoView: View {
    let onContinue: () -> Void

    @State private var showIcon: Bool = false
    @State private var showText: Bool = false
    @State private var showButton: Bool = false
    @State private var hasPromised: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 36) {
                if showIcon {
                    ZStack {
                        Circle()
                            .fill(AppTheme.roseLight.opacity(0.5))
                            .frame(width: 100, height: 100)
                            .blur(radius: 12)

                        Circle()
                            .fill(AppTheme.roseLight)
                            .frame(width: 72, height: 72)

                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(AppTheme.rose)
                    }
                    .transition(.scale(scale: 0.7).combined(with: .opacity))
                }

                if showText {
                    VStack(spacing: 16) {
                        Text("Nosso único trato:")
                            .font(AppTheme.sansFont(.subheadline, weight: .medium))
                            .foregroundStyle(AppTheme.charcoalLight)

                        Text("Aqui dentro, você não\nprecisa ser perfeita.")
                            .font(AppTheme.serifFont(.title2, weight: .bold))
                            .foregroundStyle(AppTheme.charcoal)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
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
                        .background(hasPromised ? AppTheme.sage : AppTheme.rose)
                        .clipShape(.rect(cornerRadius: 14))
                    }
                    .disabled(hasPromised)
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
        }
    }
}
