import SwiftUI

struct PainTagsView: View {
    @Binding var selectedPain: MainPain?
    let onContinue: () -> Void
    @State private var appeared: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 32)

            VStack(spacing: 12) {
                Text("O que mais pesou\nnas suas costas hoje?")
                    .font(AppTheme.serifFont(.title2, weight: .bold))
                    .foregroundStyle(AppTheme.charcoal)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)

            VStack(spacing: 14) {
                ForEach(Array(MainPain.allCases.enumerated()), id: \.element.id) { index, pain in
                    let isSelected = selectedPain == pain

                    Button {
                        withAnimation(.spring(duration: 0.35)) {
                            selectedPain = pain
                        }
                    } label: {
                        HStack(spacing: 14) {
                            Text(pain.emoji)
                                .font(.system(size: 22))
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(isSelected ? AppTheme.roseLight : AppTheme.creamDark.opacity(0.5))
                                )

                            Text(pain.title)
                                .font(AppTheme.sansFont(.body, weight: .medium))
                                .foregroundStyle(AppTheme.charcoal)

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
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isSelected ? AppTheme.roseLight.opacity(0.25) : AppTheme.cardBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(isSelected ? AppTheme.rose.opacity(0.4) : Color.clear, lineWidth: 1.5)
                        )
                        .shadow(color: AppTheme.cardShadow, radius: isSelected ? 6 : 2, y: 1)
                    }
                    .buttonStyle(.plain)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 14)
                    .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.1), value: appeared)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button {
                onContinue()
            } label: {
                Text("Continuar")
                    .font(AppTheme.sansFont(.body, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppTheme.rose.opacity(selectedPain != nil ? 1.0 : 0.35))
                    .clipShape(.rect(cornerRadius: 14))
            }
            .disabled(selectedPain == nil)
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
        .sensoryFeedback(.selection, trigger: selectedPain)
        .onAppear {
            withAnimation {
                appeared = true
            }
        }
    }
}
