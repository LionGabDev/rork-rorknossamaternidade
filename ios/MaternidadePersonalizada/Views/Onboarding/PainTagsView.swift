import SwiftUI

struct PainTagsView: View {
    @Binding var selectedPain: MainPain?
    let onContinue: () -> Void
    @State private var appeared: Bool = false
    @State private var selectedIndex: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 32)

            headerSection
                .padding(.horizontal, 28)
                .padding(.bottom, 36)

            triageScale
                .padding(.horizontal, 28)
                .padding(.bottom, 28)

            VStack(spacing: 14) {
                ForEach(Array(MainPain.allCases.enumerated()), id: \.element.id) { index, pain in
                    let isSelected = selectedPain == pain

                    Button {
                        withAnimation(.spring(duration: 0.35, bounce: 0.25)) {
                            selectedPain = pain
                            selectedIndex = index
                        }
                        HapticFeedback.selection()
                    } label: {
                        HStack(spacing: 14) {
                            Text(pain.emoji)
                                .font(.system(size: 24))
                                .frame(width: 48, height: 48)
                                .background(
                                    Circle()
                                        .fill(isSelected ? AppTheme.roseLight : AppTheme.creamDark.opacity(0.5))
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(isSelected ? AppTheme.rose : Color.clear, lineWidth: 1.5)
                                )
                                .scaleEffect(isSelected ? 1.08 : 1.0)
                                .animation(.spring(duration: 0.3), value: isSelected)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(pain.title)
                                    .font(AppTheme.sansFont(.body, weight: .medium))
                                    .foregroundStyle(AppTheme.charcoal)

                                Text(intensityLabel(for: pain))
                                    .font(AppTheme.sansFont(.caption2))
                                    .foregroundStyle(AppTheme.charcoalLight)
                            }

                            Spacer()

                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(AppTheme.rose)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(isSelected ? AppTheme.roseLight.opacity(0.3) : AppTheme.cardBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(isSelected ? AppTheme.rose.opacity(0.5) : Color.clear, lineWidth: 1.5)
                        )
                        .shadow(
                            color: isSelected ? AppTheme.rose.opacity(0.15) : AppTheme.cardShadow,
                            radius: isSelected ? 10 : 3,
                            y: isSelected ? 4 : 1
                        )
                    }
                    .buttonStyle(.plain)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 18)
                    .animation(
                        .spring(duration: 0.5, bounce: 0.12).delay(Double(index) * 0.08),
                        value: appeared
                    )
                }
            }
            .padding(.horizontal, 24)

            Spacer()

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
                    .opacity(selectedPain != nil ? 1 : 0.35)
                )
                .clipShape(.rect(cornerRadius: 16))
                .shadow(color: AppTheme.rose.opacity(0.25), radius: selectedPain != nil ? 8 : 0, y: 3)
            }
            .disabled(selectedPain == nil)
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(.easeOut(duration: 0.5).delay(0.45), value: appeared)
        }
        .sensoryFeedback(.selection, trigger: selectedPain)
        .onAppear {
            withAnimation {
                appeared = true
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("O que mais pesou\nnas suas costas hoje?")
                .font(AppTheme.serifFont(.title2, weight: .bold))
                .foregroundStyle(AppTheme.charcoal)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            Text("Escolha com honestidade. Sua resposta vai moldar o caminho que preparamos para você.")
                .font(AppTheme.sansFont(.subheadline))
                .foregroundStyle(AppTheme.charcoalLight)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
    }

    private var triageScale: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Acalmada")
                    .font(AppTheme.sansFont(.caption2))
                    .foregroundStyle(AppTheme.sageDark)

                Spacer()

                Text("No limite")
                    .font(AppTheme.sansFont(.caption2))
                    .foregroundStyle(AppTheme.roseDark)
            }

            GeometryReader { proxy in
                let width = proxy.size.width
                let selectionProgress = selectedPain.map { Double($0.triageWeight) / 4.0 } ?? 0

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.sageLight, AppTheme.creamDark, AppTheme.roseLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 8)

                    Capsule()
                        .fill(AppTheme.rose)
                        .frame(width: selectionProgress > 0 ? width * selectionProgress : 0, height: 8)
                        .animation(.spring(duration: 0.45, bounce: 0.2), value: selectionProgress)

                    HStack(spacing: 0) {
                        ForEach(0..<5) { index in
                            Circle()
                                .fill(index == 0 ? AppTheme.sage : (index == 4 ? AppTheme.roseDark : AppTheme.charcoalLight))
                                .frame(width: 10, height: 10)
                                .offset(x: CGFloat(index) * (width / 4) - 5)
                                .opacity(selectedIndex != nil ? 1 : 0.5)
                        }
                    }
                    .frame(width: width, height: 10)
                }
            }
            .frame(height: 18)
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .clipShape(.rect(cornerRadius: 14))
        .shadow(color: AppTheme.cardShadow, radius: 4, y: 2)
    }

    private func intensityLabel(for pain: MainPain) -> String {
        switch pain {
        case .limit:
            return "Estou exausta, não aguento mais"
        case .guilt:
            return "Me cobro demais, me sinto insuficiente"
        case .loneliness:
            return "Me sinto sozinha, mesmo cercada"
        case .fear:
            return "Tenho medo de não dar conta"
        }
    }
}

private extension MainPain {
    var triageWeight: Int {
        switch self {
        case .limit: return 4
        case .guilt: return 2
        case .loneliness: return 3
        case .fear: return 2
        }
    }
}

#Preview {
    PainTagsView(selectedPain: .constant(nil), onContinue: {})
}
