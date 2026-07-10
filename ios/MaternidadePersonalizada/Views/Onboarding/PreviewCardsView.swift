import SwiftUI

struct PreviewCardsView: View {
    let selectedPain: MainPain?
    let onContinue: () -> Void
    @State private var appeared: Bool = false
    @State private var revealedCards: Set<Int> = []

    private var pain: MainPain {
        selectedPain ?? .limit
    }

    private let dayIcons = ["drop.fill", "flame.fill", "person.3.fill", "trophy.fill"]
    private let dayColors: [Color] = [AppTheme.sage, AppTheme.roseDark, AppTheme.rose, AppTheme.sageDark]

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 24)

            headerSection
                .padding(.horizontal, 28)
                .padding(.bottom, 28)

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(Array(pain.planDays.enumerated()), id: \.offset) { index, day in
                        let isRevealed = revealedCards.contains(index)

                        HStack(alignment: .top, spacing: 16) {
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(dayColors[index].opacity(0.12))
                                        .frame(width: 48, height: 48)

                                    Image(systemName: dayIcons[index])
                                        .font(.body)
                                        .foregroundStyle(dayColors[index])
                                }

                                Text("Dia \(day.day)")
                                    .font(AppTheme.sansFont(.caption2, weight: .semibold))
                                    .foregroundStyle(dayColors[index])
                            }
                            .frame(width: 56)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(day.title)
                                    .font(AppTheme.sansFont(.subheadline, weight: .semibold))
                                    .foregroundStyle(AppTheme.charcoal)

                                Text(day.description)
                                    .font(AppTheme.sansFont(.caption))
                                    .foregroundStyle(AppTheme.charcoalLight)
                                    .lineSpacing(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.cardBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(AppTheme.rose.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: AppTheme.cardShadow, radius: 6, y: 2)
                        .opacity(isRevealed ? 1 : 0.3)
                        .offset(y: isRevealed ? 0 : 18)
                        .scaleEffect(isRevealed ? 1 : 0.96)
                        .animation(
                            .spring(duration: 0.55, bounce: 0.14).delay(Double(index) * 0.18),
                            value: isRevealed
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)

            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.rose)

                    Text("Desbloqueie o plano completo com a NathIA.")
                        .font(AppTheme.sansFont(.caption))
                        .foregroundStyle(AppTheme.charcoalLight)
                }

                Button {
                    HapticFeedback.impact(.medium)
                    onContinue()
                } label: {
                    HStack(spacing: 8) {
                        Text("Ver como desbloquear")
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
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(.easeOut(duration: 0.6).delay(0.9), value: appeared)
        }
        .sensoryFeedback(.impact(weight: .light), trigger: appeared)
        .onAppear {
            withAnimation {
                appeared = true
            }
            revealCardsSequentially()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("Seu Plano de 4 Dias")
                .font(AppTheme.serifFont(.title2, weight: .bold))
                .foregroundStyle(AppTheme.charcoal)
                .multilineTextAlignment(.center)

            Text("para \"\(pain.title)\" está pronto.")
                .font(AppTheme.sansFont(.subheadline))
                .foregroundStyle(AppTheme.charcoalLight)
                .multilineTextAlignment(.center)

            Text("Cada dia é um passo pequeno — mas juntos formam uma mudança real.")
                .font(AppTheme.sansFont(.caption))
                .foregroundStyle(AppTheme.charcoalLight)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.top, 4)
        }
    }

    private func revealCardsSequentially() {
        for index in 0..<pain.planDays.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.18 + 0.2) {
                HapticFeedback.impact(.light)
                revealedCards.insert(index)
            }
        }
    }
}

#Preview {
    PreviewCardsView(selectedPain: .limit, onContinue: {})
}
