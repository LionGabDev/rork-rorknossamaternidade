import SwiftUI

struct SplashScreenView: View {
    let onAnimationComplete: () -> Void

    @State private var showBloom: Bool = false
    @State private var showTitle: Bool = false
    @State private var showTagline: Bool = false
    @State private var bloomScale: CGFloat = 0.6
    @State private var bloomRotation: Double = -12
    @State private var gradientPhase: CGFloat = 0

    var body: some View {
        ZStack {
            animatedBackground

            VStack(spacing: 0) {
                Spacer()

                bloomLogo
                    .padding(.bottom, 40)

                VStack(spacing: 16) {
                    if showTitle {
                        Text("Mães")
                            .font(AppTheme.serifFont(.largeTitle, weight: .bold))
                            .foregroundStyle(AppTheme.charcoal)
                            +
                        Text(" Valentes")
                            .font(AppTheme.serifFont(.largeTitle, weight: .bold))
                            .foregroundStyle(AppTheme.roseDark)
                    }

                    if showTagline {
                        Text("Acolhimento real para quem carrega o mundo nas costas.")
                            .font(AppTheme.sansFont(.body))
                            .foregroundStyle(AppTheme.charcoalLight)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 48)
                            .transition(.opacity.combined(with: .offset(y: 10)))
                    }
                }
                .multilineTextAlignment(.center)
                .animation(.easeOut(duration: 0.8), value: showTitle)

                Spacer()
            }
            .padding(.top, 40)
        }
        .onAppear {
            startEntranceSequence()
        }
    }

    private var bloomLogo: some View {
        ZStack {
            ForEach(0..<6) { index in
                PetalShape()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.rose.opacity(0.55),
                                AppTheme.roseLight.opacity(0.25)
                            ],
                            center: .center,
                            startRadius: 2,
                            endRadius: 28
                        )
                    )
                    .frame(width: 28, height: 44)
                    .offset(y: -22)
                    .rotationEffect(.degrees(Double(index) * 60))
                    .opacity(showBloom ? 1 : 0)
                    .scaleEffect(showBloom ? 1 : 0.4)
                    .animation(
                        .spring(duration: 0.9, bounce: 0.3).delay(Double(index) * 0.06),
                        value: showBloom
                    )
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppTheme.cream, AppTheme.roseLight.opacity(0.6)],
                        center: .center,
                        startRadius: 2,
                        endRadius: 32
                    )
                )
                .frame(width: 52, height: 52)
                .opacity(showBloom ? 1 : 0)
                .scaleEffect(showBloom ? 1 : 0.6)
                .animation(.spring(duration: 0.8, bounce: 0.2).delay(0.15), value: showBloom)

            Image(systemName: "heart.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(AppTheme.roseDark)
                .opacity(showBloom ? 1 : 0)
                .scaleEffect(showBloom ? 1 : 0.5)
                .animation(.spring(duration: 0.7, bounce: 0.2).delay(0.35), value: showBloom)
        }
        .frame(width: 120, height: 120)
        .rotationEffect(.degrees(bloomRotation))
        .scaleEffect(bloomScale)
        .animation(
            .easeInOut(duration: 3.5).repeatForever(autoreverses: true),
            value: bloomScale
        )
        .animation(
            .easeInOut(duration: 6).repeatForever(autoreverses: true),
            value: bloomRotation
        )
    }

    private var animatedBackground: some View {
        TimelineView(.animation) { timeline in
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    .init(x: 0, y: 0), .init(x: 0.5, y: 0), .init(x: 1, y: 0),
                    .init(x: 0, y: 0.5), .init(x: 0.5, y: 0.5), .init(x: 1, y: 0.5),
                    .init(x: 0, y: 1), .init(x: 0.5, y: 1), .init(x: 1, y: 1)
                ],
                colors: meshColors(at: timeline.date)
            )
        }
        .ignoresSafeArea()
    }

    private func meshColors(at date: Date) -> [Color] {
        let phase = sin(date.timeIntervalSinceReferenceDate * 0.4) * 0.5 + 0.5
        let roseTint = AppTheme.rose.opacity(0.12 + 0.08 * phase)
        let sageTint = AppTheme.sage.opacity(0.06 + 0.05 * phase)
        return [
            AppTheme.cream, roseTint, AppTheme.cream,
            sageTint, AppTheme.cream, roseTint,
            AppTheme.cream, sageTint, AppTheme.cream
        ]
    }

    private func startEntranceSequence() {
        bloomScale = 1.0
        bloomRotation = 0

        withAnimation(.spring(duration: 0.9, bounce: 0.3)) {
            showBloom = true
        }

        withAnimation(.easeOut(duration: 0.8).delay(0.9)) {
            showTitle = true
        }

        withAnimation(.easeOut(duration: 0.7).delay(1.6)) {
            showTagline = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            withAnimation(.easeInOut(duration: 0.6)) {
                onAnimationComplete()
            }
        }
    }
}

private struct PetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.5, y: h * 0.05))
        path.addCurve(
            to: CGPoint(x: w * 0.95, y: h * 0.75),
            control1: CGPoint(x: w * 0.9, y: h * 0.25),
            control2: CGPoint(x: w * 0.95, y: h * 0.55)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h * 0.95),
            control1: CGPoint(x: w * 0.85, y: h * 0.9),
            control2: CGPoint(x: w * 0.65, y: h * 0.95)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.05, y: h * 0.75),
            control1: CGPoint(x: w * 0.35, y: h * 0.95),
            control2: CGPoint(x: w * 0.05, y: h * 0.55)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h * 0.05),
            control1: CGPoint(x: w * 0.05, y: h * 0.25),
            control2: CGPoint(x: w * 0.1, y: h * 0.25)
        )
        path.closeSubpath()

        return path
    }
}

#Preview {
    SplashScreenView(onAnimationComplete: {})
}
