import SwiftUI

/// Shelf Life design tokens (OpenDesign board v3). Light = Paper, dark = Night Ink.
enum Palette {
    // Canvas and surfaces
    static let background = Color(light: 0xF5F7FF, dark: 0x0B1030)
    static let card = Color(light: 0xFFFFFF, dark: 0x141A3D)
    static let fill = Color(light: 0xECEFFA, dark: 0x1B2350)
    static let line = Color(light: 0xE1E5F6, dark: 0x2A3363)
    static let secondaryText = Color(light: 0x5A6280, dark: 0xA6AFD0)
    static let accentSoft = Color(light: 0xE7ECFF, dark: 0x1C2550)

    // Brand hues
    static let teal = Color(light: 0x0A7B84, dark: 0x2FD3DF)
    static let blue = Color(light: 0x1E4FD8, dark: 0x7D9BFF)
    static let violet = Color(light: 0x6B32D6, dark: 0xB79CFF)
    static let gold = Color(light: 0x8A6400, dark: 0xFFD561)
    static let coral = Color(light: 0xD92B4B, dark: 0xFF6B85)

    // Status
    static let destructive = Color(light: 0xD92B4B, dark: 0xFF6B85)
    static let success = Color(light: 0x0A7B84, dark: 0x2FD3DF)
    /// The deck sits on Night Ink in both appearances, so its controls use fixed colors.
    static let deckKeep = Color(light: 0x14B8C6, dark: 0x14B8C6)
    static let deckDelete = Color(light: 0xFF4D6A, dark: 0xFF4D6A)
    static let deckInk = Color(light: 0x0B1030, dark: 0x0B1030)
}

/// Gradients and display type. Bricolage Grotesque is not bundled, so rounded SF is the native stand-in.
enum Brand {
    static let hero = LinearGradient(
        colors: [Color(hex: 0x14B8C6), Color(hex: 0x2F6BFF), Color(hex: 0x7B3FE4)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let button = LinearGradient(
        colors: [Color(hex: 0x0B7C8A), Color(hex: 0x2A5FE8), Color(hex: 0x6B32D6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gold = LinearGradient(
        colors: [Color(hex: 0xFFE29A), Color(hex: 0xFFD561), Color(hex: 0xF2AE3C)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let deck = LinearGradient(
        colors: [Color(hex: 0x131A44), Color(hex: 0x0B1030), Color(hex: 0x070A22)],
        startPoint: .top,
        endPoint: .bottom
    )

    static func tile(_ kind: DeckKind) -> LinearGradient {
        switch kind {
        case .screenshots:
            LinearGradient(colors: [Color(hex: 0x14B8C6), Color(hex: 0x2F6BFF)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .similar:
            LinearGradient(colors: [Color(hex: 0x7B3FE4), Color(hex: 0x2F6BFF)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .blurry:
            LinearGradient(colors: [Color(hex: 0xFFE29A), Color(hex: 0xF2AE3C)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .videos:
            LinearGradient(colors: [Color(hex: 0x1B2350), Color(hex: 0x7B3FE4)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

enum Metrics {
    static let cardRadius: CGFloat = 16
    static let controlRadius: CGFloat = 12
    static let heroRadius: CGFloat = 24
    static let tileRadius: CGFloat = 12
}

extension Font {
    /// Tabular, rounded display face for hero numerals.
    static func display(_ size: CGFloat, weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

extension Color {
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }

    init(hex: UInt32) {
        self.init(uiColor: UIColor(hex: hex))
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

/// Primary action: Shelf Life gradient, white label, 52 pt tall.
struct BrandButtonStyle: ButtonStyle {
    var gradient = Brand.button
    var foreground = Color.white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(gradient, in: .rect(cornerRadius: Metrics.cardRadius))
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
    }
}

extension ButtonStyle where Self == BrandButtonStyle {
    static var brand: BrandButtonStyle { BrandButtonStyle() }
}

/// Coral destructive action for the review footer.
struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(Palette.coral, in: .rect(cornerRadius: Metrics.cardRadius))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

extension ButtonStyle where Self == DestructiveButtonStyle {
    static var destructiveFill: DestructiveButtonStyle { DestructiveButtonStyle() }
}

/// App mark: the rounded gradient square with a photo stack.
struct AppMark: View {
    var size: CGFloat = 30

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
            .fill(Brand.hero)
            .frame(width: size, height: size)
            .overlay {
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                        .fill(.white.opacity(0.45))
                        .frame(width: size * 0.42, height: size * 0.5)
                        .rotationEffect(.degrees(-12))
                        .offset(x: -size * 0.06, y: size * 0.02)
                    RoundedRectangle(cornerRadius: size * 0.08, style: .continuous)
                        .fill(.white)
                        .frame(width: size * 0.42, height: size * 0.5)
                        .rotationEffect(.degrees(8))
                        .offset(x: size * 0.08, y: -size * 0.02)
                }
            }
            .accessibilityHidden(true)
    }
}

/// Gradient icon tile used by deck rows and the deck header.
struct DeckTile: View {
    let kind: DeckKind
    var size: CGFloat = 40

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
            .fill(Brand.tile(kind))
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: kind.symbol)
                    .font(.system(size: size * 0.45, weight: .semibold))
                    .foregroundStyle(kind == .blurry ? Palette.deckInk : .white)
            }
            .accessibilityHidden(true)
    }
}

/// Thin gradient progress line used by inbox rows and the deck header.
struct BrandProgressBar: View {
    var fraction: Double
    var height: CGFloat = 3

    var body: some View {
        GeometryReader { geometry in
            Capsule()
                .fill(Palette.fill)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(Brand.hero)
                        .frame(width: geometry.size.width * min(max(fraction, 0), 1))
                }
        }
        .frame(height: height)
        .accessibilityHidden(true)
    }
}
