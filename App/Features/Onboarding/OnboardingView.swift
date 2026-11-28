import SwiftUI

/// First-run tour: the shelf-life promise, three how-it-works beats, then permission priming.
/// The last page asks for photo access through the system prompt; whatever the answer, the inbox opens.
struct OnboardingView: View {
    /// Persisted by RootView; UI tests override it with `-hasCompletedOnboarding NO`.
    static let completedKey = "hasCompletedOnboarding"

    let onFinish: () -> Void

    @Environment(LibraryModel.self) private var library
    @Environment(CleanupSession.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0
    @State private var isRequesting = false

    private static let lastPage = 4

    private var isWelcome: Bool { page == 0 }
    private var isPermission: Bool { page == Self.lastPage }

    var body: some View {
        ZStack {
            Group {
                if isWelcome {
                    Brand.hero
                } else {
                    Palette.background
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer(minLength: 16)
                footer
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .sensoryFeedback(.selection, trigger: page)
    }

    // MARK: Chrome

    private var header: some View {
        HStack {
            if isWelcome {
                HStack(spacing: 8) {
                    AppMark(size: 28)
                    Text(verbatim: "PurgeSwipe").font(.subheadline.weight(.bold))
                    Text("onboarding.kicker")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.18), in: .capsule)
                }
                .foregroundStyle(.white)
            }
            Spacer()
            if !isPermission {
                Button("onboarding.skip") { goToPermission() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isWelcome ? .white.opacity(0.9) : Palette.secondaryText)
                    .accessibilityIdentifier("onboarding.skip")
            }
        }
        .frame(minHeight: 56)
    }

    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: 18) {
            art
                .frame(maxWidth: .infinity)
                .frame(height: 236)
                .accessibilityHidden(true)
                .padding(.top, 4)

            if !isWelcome {
                Text(kicker)
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(Palette.teal)
            }

            Text(title)
                .font(isWelcome ? .display(34, weight: .bold) : .system(size: 30, weight: .bold))
                .foregroundStyle(isWelcome ? .white : .primary)
                .accessibilityAddTraits(.isHeader)

            Text(bodyKey)
                .font(.body)
                .foregroundStyle(isWelcome ? .white.opacity(0.86) : Palette.secondaryText)

            if isPermission {
                badges
            }
        }
        .id(page)
        .transition(.opacity)
    }

    private var footer: some View {
        VStack(spacing: 10) {
            dots
            Button {
                if isPermission { choosePhotos() } else { advance() }
            } label: {
                WideLabel(isPermission ? "onboarding.choose" : "onboarding.continue")
            }
            .buttonStyle(isWelcome ? BrandButtonStyle(gradient: LinearGradient(colors: [.white, .white], startPoint: .top, endPoint: .bottom), foreground: Palette.deckInk) : BrandButtonStyle())
            .disabled(isRequesting)
            .accessibilityIdentifier("onboarding.primary")

            if isWelcome {
                Button("onboarding.notNow") { goToPermission() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.86))
            }
        }
    }

    private var dots: some View {
        HStack(spacing: 8) {
            ForEach(0 ... Self.lastPage, id: \.self) { index in
                Capsule()
                    .fill(dotColor(index))
                    .frame(width: index == page ? 24 : 8, height: 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("onboarding.page \(page + 1) \(Self.lastPage + 1)"))
    }

    private func dotColor(_ index: Int) -> Color {
        if index == page {
            return isWelcome ? .white : Palette.blue
        }
        return isWelcome ? .white.opacity(0.35) : Palette.line
    }

    // MARK: Copy

    private var kicker: LocalizedStringKey {
        switch page {
        case 1, 2, 3: "onboarding.howItWorks \(page)"
        default: "onboarding.permission.kicker"
        }
    }

    private var title: LocalizedStringKey {
        switch page {
        case 0: "onboarding.title.1"
        case 1: "onboarding.title.2"
        case 2: "onboarding.title.3"
        case 3: "onboarding.title.4"
        default: "onboarding.title.5"
        }
    }

    private var bodyKey: LocalizedStringKey {
        switch page {
        case 0: "onboarding.body.1"
        case 1: "onboarding.body.2"
        case 2: "onboarding.body.3"
        case 3: "onboarding.body.4"
        default: "onboarding.body.5"
        }
    }

    private var badges: some View {
        VStack(spacing: 8) {
            ForEach(["onboarding.badge.device", "onboarding.badge.screenshots", "onboarding.badge.noAccount"], id: \.self) { key in
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Palette.teal)
                    Text(LocalizedStringKey(key))
                        .font(.subheadline)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
                .frame(minHeight: 40)
                .background(Palette.card, in: .rect(cornerRadius: Metrics.controlRadius))
            }
        }
        .padding(.top, 4)
    }

    // MARK: Artwork

    @ViewBuilder
    private var art: some View {
        switch page {
        case 0: WelcomeArt()
        case 1: TrayArt()
        case 2: SwipeArt()
        case 3: VaultArt()
        default: ShieldArt()
        }
    }

    // MARK: Actions

    private func advance() {
        guard page < Self.lastPage else { return }
        withAnimation(reduceMotion ? nil : .snappy) { page += 1 }
    }

    private func goToPermission() {
        withAnimation(reduceMotion ? nil : .snappy) { page = Self.lastPage }
    }

    private func choosePhotos() {
        isRequesting = true
        Task {
            await library.requestAccess(session: session)
            onFinish()
        }
    }
}

// MARK: - Artwork

/// Fanned screenshot cards with age stamps, the welcome hero.
private struct WelcomeArt: View {
    var body: some View {
        ZStack {
            MiniCard(tint: Color(hex: 0xFF4D6A), angle: -11)
                .offset(x: -78, y: 8)
            MiniCard(tint: Color(hex: 0x14B8C6), angle: 0)
                .offset(y: -10)
            MiniCard(tint: Color(hex: 0x7B3FE4), angle: 10)
                .offset(x: 78, y: 6)
            Image(systemName: "sparkle")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color(hex: 0xFFD561))
                .offset(x: 112, y: -74)
        }
        .frame(maxWidth: .infinity)
    }
}

/// New shots landing in the inbox tray.
private struct TrayArt: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(hex: 0xE7ECFF))
            MiniCard(tint: Color(hex: 0x14B8C6), angle: -8)
                .offset(x: -42, y: -34)
            MiniCard(tint: Color(hex: 0x7B3FE4), angle: 7)
                .offset(x: 42, y: -30)
            Image(systemName: "tray.full.fill")
                .font(.system(size: 66, weight: .semibold))
                .foregroundStyle(Palette.blue)
                .offset(y: 62)
        }
        .clipShape(.rect(cornerRadius: 22))
    }
}

/// One card between a coral purge arrow and a teal keep arrow.
private struct SwipeArt: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(hex: 0xE7ECFF))
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Palette.coral.opacity(0.55), style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
                .frame(width: 108, height: 148)
                .rotationEffect(.degrees(-8))
                .offset(x: -34)
            MiniCard(tint: Color(hex: 0xFF4D6A), angle: 6)
                .offset(x: 6)
            Image(systemName: "arrow.left")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Palette.coral)
                .offset(x: -118)
            Image(systemName: "arrow.right")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Color(hex: 0x0A7B84))
                .offset(x: 118)
        }
        .clipShape(.rect(cornerRadius: 22))
    }
}

/// Pinned shots wait in the vault and age out after five weeks.
private struct VaultArt: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(hex: 0xE7ECFF))
            MiniCard(tint: Color(hex: 0x7B3FE4), angle: -7)
                .offset(x: -46, y: -46)
            MiniCard(tint: Color(hex: 0x14B8C6), angle: 6)
                .offset(x: 44, y: -40)
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white)
                .frame(width: 156, height: 92)
                .overlay {
                    ZStack {
                        Circle().fill(Palette.fill).frame(width: 48, height: 48)
                        Circle().strokeBorder(Palette.blue, lineWidth: 3).frame(width: 30, height: 30)
                        Capsule().fill(Palette.blue).frame(width: 4, height: 12).offset(y: 6)
                    }
                }
                .offset(y: 44)
        }
        .clipShape(.rect(cornerRadius: 22))
    }
}

/// Permission priming: a shield over the photo stack.
private struct ShieldArt: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(hex: 0xE7ECFF))
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
                .frame(width: 120, height: 156)
                .rotationEffect(.degrees(-8))
                .offset(x: -30)
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 78, weight: .semibold))
                .foregroundStyle(Palette.blue)
                .offset(x: 44, y: 24)
        }
        .clipShape(.rect(cornerRadius: 22))
    }
}

private struct MiniCard: View {
    let tint: Color
    let angle: Double

    var body: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(.white)
            .frame(width: 96, height: 132)
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(tint)
                    .frame(height: 46)
                    .padding(6)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 5) {
                    Capsule().fill(Palette.line).frame(width: 52, height: 5)
                    Capsule().fill(Palette.line).frame(width: 34, height: 5)
                }
                .padding(10)
            }
            .overlay(alignment: .topTrailing) {
                Text(verbatim: "9d")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Palette.deckInk)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Brand.gold, in: .capsule)
                    .rotationEffect(.degrees(-6))
                    .offset(x: 8, y: -8)
            }
            .shadow(color: Palette.deckInk.opacity(0.18), radius: 14, y: 10)
            .rotationEffect(.degrees(angle))
    }
}

#Preview {
    OnboardingView {}
        .environment(LibraryModel())
        .environment(CleanupSession())
}
