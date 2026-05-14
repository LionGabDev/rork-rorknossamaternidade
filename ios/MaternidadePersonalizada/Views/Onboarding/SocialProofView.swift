import SwiftUI

struct SocialProofView: View {
    let selectedPain: MainPain?
    let onContinue: () -> Void

    @State private var showCount: Bool = false
    @State private var showMessage: Bool = false
    @State private var showButton: Bool = false
    @State private var pulseScale: CGFloat = 1.0

    private var pain: MainPain {
        selectedPain ?? .limit
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(AppTheme.roseLight.opacity(0.4))
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseScale)

                    Circle()
                        .fill(AppTheme.roseLight)
                        .frame(width: 80, height: 80)

                    Image(systemName: "person.3.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(AppTheme.rose)
                }

                VStack(spacing: 16) {
                    if showCount {
                        Text("Você não está sozinha.")
                            .font(AppTheme.serifFont(.title2, weight: .bold))
                            .foregroundStyle(AppTheme.charcoal)
                            .multilineTextAlignment(.center)
                            .transition(.opacity.combined(with: .offset(y: 10)))
                    }

                    if showMessage {
                        VStack(spacing: 12) {
                            HStack(spacing: 0) {
                                Text(pain.socialProofCount)
                                    .font(AppTheme.serifFont(.largeTitle, weight: .bold))
                                    .foregroundStyle(AppTheme.rose)
                                Text(" mães")
                                    .font(AppTheme.serifFont(.title2, weight: .medium))
                                    .foregroundStyle(AppTheme.charcoal)
                            }

                            Text("aqui também sentiram\n\"\(pain.title)\" hoje.")
                                .font(AppTheme.sansFont(.body))
                                .foregroundStyle(AppTheme.charcoalLight)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)

                            Text("Todas encontraram um caminho.\nVocê também vai.")
                                .font(AppTheme.sansFont(.body, weight: .medium))
                                .foregroundStyle(AppTheme.charcoal)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.top, 4)
                        }
                        .transition(.opacity.combined(with: .offset(y: 10)))
                    }
                }
                .padding(.horizontal, 32)
            }

            Spacer()

            if showButton {
                Button {
                    onContinue()
                } label: {
                    Text("Continuar")
                        .font(AppTheme.sansFont(.body, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.rose)
                        .clipShape(.rect(cornerRadius: 14))
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
                .transition(.opacity.combined(with: .offset(y: 16)))
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: showCount)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.08
            }
            withAnimation(.easeOut(duration: 0.7).delay(0.5)) {
                showCount = true
            }
            withAnimation(.easeOut(duration: 0.7).delay(1.8)) {
                showMessage = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(3.5)) {
                showButton = true
            }
        }
    }
}
