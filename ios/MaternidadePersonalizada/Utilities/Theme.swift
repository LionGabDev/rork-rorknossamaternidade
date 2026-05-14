import SwiftUI

enum AppTheme {
    static let rose = Color(red: 0.95, green: 0.71, blue: 0.75)
    static let roseDark = Color(red: 0.88, green: 0.55, blue: 0.62)
    static let roseLight = Color(red: 0.97, green: 0.84, blue: 0.87)
    static let sage = Color(red: 0.61, green: 0.69, blue: 0.53)
    static let sageDark = Color(red: 0.48, green: 0.56, blue: 0.40)
    static let sageLight = Color(red: 0.78, green: 0.84, blue: 0.72)
    static let cream = Color(red: 0.99, green: 0.96, blue: 0.94)
    static let creamDark = Color(red: 0.96, green: 0.92, blue: 0.88)
    static let charcoal = Color(red: 0.24, green: 0.21, blue: 0.21)
    static let charcoalLight = Color(red: 0.40, green: 0.36, blue: 0.36)

    static let cardBackground = Color(red: 1.0, green: 0.98, blue: 0.97)
    static let cardShadow = Color(red: 0.24, green: 0.21, blue: 0.21).opacity(0.06)

    static func serifFont(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .serif, weight: weight)
    }

    static func sansFont(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .system(style, weight: weight)
    }
}

struct WarmCardStyle: ViewModifier {
    var padding: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.cardBackground)
            .clipShape(.rect(cornerRadius: 16))
            .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 2)
    }
}

extension View {
    func warmCard(padding: CGFloat = 20) -> some View {
        modifier(WarmCardStyle(padding: padding))
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                AppTheme.rose.opacity(isDisabled ? 0.4 : 1.0)
            )
            .clipShape(.rect(cornerRadius: 14))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}
