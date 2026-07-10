import SwiftUI

struct OnboardingBackground: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            MeshGradient(
                width: 3,
                height: 3,
                points: meshPoints(at: timeline.date),
                colors: meshColors(at: timeline.date)
            )
        }
        .ignoresSafeArea()
    }

    private func meshPoints(at date: Date) -> [SIMD2<Float>] {
        let t = Float(date.timeIntervalSinceReferenceDate * 0.08)
        let sin1 = (sin(t) + 1) / 2
        let sin2 = (sin(t + 1.5) + 1) / 2
        let cos1 = (cos(t * 0.7) + 1) / 2
        let cos2 = (cos(t * 0.7 + 2.0) + 1) / 2

        return [
            .init(x: 0, y: 0),
            .init(x: 0.5 + sin1 * 0.06, y: 0.05 + cos1 * 0.04),
            .init(x: 1, y: 0),
            .init(x: 0.05 + cos2 * 0.04, y: 0.5 + sin2 * 0.06),
            .init(x: 0.5, y: 0.5),
            .init(x: 0.95 - cos2 * 0.04, y: 0.5 - sin2 * 0.06),
            .init(x: 0, y: 1),
            .init(x: 0.5 - sin1 * 0.06, y: 0.95 - cos1 * 0.04),
            .init(x: 1, y: 1)
        ]
    }

    private func meshColors(at date: Date) -> [Color] {
        let phase = (sin(date.timeIntervalSinceReferenceDate * 0.25) + 1) / 2
        return [
            AppTheme.cream,
            AppTheme.rose.opacity(0.08 + 0.06 * phase),
            AppTheme.cream,
            AppTheme.sage.opacity(0.06 + 0.04 * phase),
            AppTheme.cream,
            AppTheme.roseLight.opacity(0.12 + 0.06 * phase),
            AppTheme.cream,
            AppTheme.sage.opacity(0.05 + 0.04 * phase),
            AppTheme.cream
        ]
    }
}

#Preview {
    OnboardingBackground()
}
