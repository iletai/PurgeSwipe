import SwiftUI

/// Design tokens from the OpenDesign mockup (light / dark pairs). The accent lives in the AccentColor asset.
enum Palette {
    static let background = Color(light: 0xF2F4F6, dark: 0x0E1114)
    static let card = Color(light: 0xFFFFFF, dark: 0x1A1F24)
    static let fill = Color(light: 0xE6EAEE, dark: 0x262D34)
    static let line = Color(light: 0xD9DEE3, dark: 0x2E353C)
    static let secondaryText = Color(light: 0x56626E, dark: 0xA3AEB9)
    static let accentSoft = Color(light: 0xDFF1EF, dark: 0x14312F)
    static let destructive = Color(light: 0xC62828, dark: 0xFF6B6B)
    /// The deck sits on black in both appearances, so its controls use fixed colors.
    static let deckKeep = Color(light: 0x1B7F3B, dark: 0x1B7F3B)
    static let deckDelete = Color(light: 0xC62828, dark: 0xC62828)
}

enum Metrics {
    static let cardRadius: CGFloat = 16
    static let controlRadius: CGFloat = 12
}

extension Color {
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

/// White-on-card container used across Home, Review and Settings-like content.
struct CardBackground: ViewModifier {
    var color = Palette.card

    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color, in: .rect(cornerRadius: Metrics.cardRadius))
    }
}

extension View {
    func cardBackground(_ color: Color = Palette.card) -> some View { modifier(CardBackground(color: color)) }
}

/// Button label that fills the width, so bordered styles stretch edge to edge.
struct WideLabel: View {
    let key: LocalizedStringKey

    init(_ key: LocalizedStringKey) { self.key = key }

    var body: some View { Text(key).frame(maxWidth: .infinity) }
}
