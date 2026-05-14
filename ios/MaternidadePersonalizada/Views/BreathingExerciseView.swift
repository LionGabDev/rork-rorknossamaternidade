import SwiftUI

struct BreathingExerciseView: View {
    @State private var phase: BreathPhase = .ready
    @State private var circleScale: CGFloat = 0.6
    @State private var cycleCount: Int = 0
    @State private var isRunning: Bool = false

    private let totalCycles = 5

    nonisolated private enum BreathPhase: String, Sendable {
        case ready = "Pronta para começar?"
        case inhale = "Inspire..."
        case hold = "Segure..."
        case exhale = "Expire..."
        case done = "Parabéns! 🌿"
    }

    var body: some View {
        ZStack {
            AppTheme.cream
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                breathCircle

                VStack(spacing: 8) {
                    Text(phase.rawValue)
                        .font(AppTheme.serifFont(.title2, weight: .semibold))
                        .foregroundStyle(AppTheme.charcoal)
                        .contentTransition(.numericText())

                    if isRunning {
                        Text("Ciclo \(cycleCount) de \(totalCycles)")
                            .font(AppTheme.sansFont(.subheadline))
                            .foregroundStyle(AppTheme.charcoalLight)
                    } else if phase == .done {
                        Text("Você completou o exercício")
                            .font(AppTheme.sansFont(.subheadline))
                            .foregroundStyle(AppTheme.sage)
                    } else {
                        Text("3 minutos · Respiração 4-4-4")
                            .font(AppTheme.sansFont(.subheadline))
                            .foregroundStyle(AppTheme.charcoalLight)
                    }
                }

                Spacer()

                if !isRunning {
                    Button {
                        if phase == .done {
                            resetExercise()
                        } else {
                            startBreathing()
                        }
                    } label: {
                        Text(phase == .done ? "Fazer novamente" : "Começar")
                            .font(AppTheme.sansFont(.body, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppTheme.sage)
                            .clipShape(.rect(cornerRadius: 14))
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
                    .frame(height: 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Momento de Calma")
                    .font(AppTheme.serifFont(.headline, weight: .semibold))
                    .foregroundStyle(AppTheme.charcoal)
            }
        }
    }

    private var breathCircle: some View {
        ZStack {
            Circle()
                .fill(AppTheme.sageLight.opacity(0.2))
                .frame(width: 220, height: 220)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppTheme.sage.opacity(0.6), AppTheme.sageLight.opacity(0.3)],
                        center: .center,
                        startRadius: 10,
                        endRadius: 100
                    )
                )
                .frame(width: 180, height: 180)
                .scaleEffect(circleScale)

            Circle()
                .fill(AppTheme.sage.opacity(0.4))
                .frame(width: 80, height: 80)
                .scaleEffect(circleScale)

            Image(systemName: "leaf.fill")
                .font(.title)
                .foregroundStyle(.white.opacity(0.9))
                .scaleEffect(circleScale * 0.9 + 0.1)
        }
    }

    private func startBreathing() {
        isRunning = true
        cycleCount = 1
        // TODO: considerar adicionar breathing_started ao analytics em versão futura
        runCycle()
    }

    private func runCycle() {
        guard cycleCount <= totalCycles else {
            withAnimation(.easeInOut(duration: 0.5)) {
                phase = .done
                isRunning = false
                circleScale = 0.6
            }
            // TODO: considerar adicionar breathing_completed ao analytics em versão futura
            return
        }

        withAnimation(.easeInOut(duration: 4)) {
            phase = .inhale
            circleScale = 1.0
        }

        Task {
            try? await Task.sleep(for: .seconds(4))
            withAnimation(.easeInOut(duration: 0.3)) {
                phase = .hold
            }

            try? await Task.sleep(for: .seconds(4))
            withAnimation(.easeInOut(duration: 4)) {
                phase = .exhale
                circleScale = 0.6
            }

            try? await Task.sleep(for: .seconds(4))
            cycleCount += 1
            runCycle()
        }
    }

    private func resetExercise() {
        phase = .ready
        circleScale = 0.6
        cycleCount = 0
        isRunning = false
    }
}
