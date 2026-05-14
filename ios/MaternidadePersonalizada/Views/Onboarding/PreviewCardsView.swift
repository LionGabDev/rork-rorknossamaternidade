import SwiftUI

struct PreviewCardsView: View {
    let selectedPain: MainPain?
    let onContinue: () -> Void
    @State private var appeared: Bool = false

    private var pain: MainPain {
        selectedPain ?? .limit
    }

    private let dayIcons = ["drop.fill", "flame.fill", "person.3.fill", "trophy.fill"]
    private let dayColors: [Color] = [AppTheme.sage, AppTheme.roseDark, AppTheme.rose, AppTheme.sageDark]

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 24)

            VStack(spacing: 10) {
                Text("Seu Plano de 4 Dias")
                    .font(AppTheme.serifFont(.title2, weight: .bold))
                    .foregroundStyle(AppTheme.charcoal)
                    .multilineTextAlignment(.center)

                Text("para \"\(pain.title)\" está pronto.")
                    .font(AppTheme.sansFont(.subheadline))
                    .foregroundStyle(AppTheme.charcoalLight)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 28)

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(Array(pain.planDays.enumerated()), id: \.offset) { index, day in
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
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .warmCard(padding: 16)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 18)
                        .animation(
                            .spring(duration: 0.5, bounce: 0.15).delay(Double(index) * 0.12),
                            value: appeared
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)

            VStack(spacing: 8) {
                Text("Desbloqueie o plano completo com a NathIA.")
                    .font(AppTheme.sansFont(.caption))
                    .foregroundStyle(AppTheme.charcoalLight)

                Button {
                    onContinue()
                } label: {
                    Text("Ver como desbloquear")
                        .font(AppTheme.sansFont(.body, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppTheme.rose)
                        .clipShape(.rect(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
        .sensoryFeedback(.impact(weight: .light), trigger: appeared)
        .onAppear {
            withAnimation {
                appeared = true
            }
        }
    }
}
