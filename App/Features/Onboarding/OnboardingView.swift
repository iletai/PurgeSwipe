import SwiftUI

/// First-run tour, two pages. Page 2 asks for photo access through the system prompt; whatever the answer, Home opens
/// (denied and limited access have their own states there). No login, no cancel button before the system prompt.
struct OnboardingView: View {
    /// Persisted by RootView; UI tests override it with `-hasCompletedOnboarding NO`.
    static let completedKey = "hasCompletedOnboarding"

    let onFinish: () -> Void

    @Environment(LibraryModel.self) private var library
    @Environment(CleanupSession.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if page == 0 {
                    Button("onboarding.skip") { goToPermissionPage() }
                        .accessibilityIdentifier("onboarding.skip")
                }
            }
            .frame(minHeight: 52)

            Group {
                if page == 0 { OnboardingArt.cards } else { OnboardingArt.privacy }
            }
            .frame(maxWidth: 280, maxHeight: .infinity)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 16) {
                Text(page == 0 ? "onboarding.title.1" : "onboarding.title.2")
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)
                Text(page == 0 ? "onboarding.body.1" : "onboarding.body.2")
                    .foregroundStyle(Palette.secondaryText)
                dots
                Button {
                    if page == 0 { goToPermissionPage() } else { choosePhotos() }
                } label: {
                    WideLabel(page == 0 ? "onboarding.continue" : "onboarding.choose")
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: Metrics.controlRadius))
                .controlSize(.large)
                .disabled(isRequesting)
                .accessibilityIdentifier("onboarding.primary")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .id(page)
            .transition(.opacity)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .background(Palette.background)
        .sensoryFeedback(.selection, trigger: page)
    }

    private var dots: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< 2, id: \.self) { index in
                Capsule()
                    .fill(index == page ? Color.accentColor : Palette.line)
                    .frame(width: index == page ? 24 : 8, height: 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("onboarding.page \(page + 1) 2"))
    }

    private func goToPermissionPage() {
        withAnimation(reduceMotion ? nil : .snappy) { page = 1 }
    }

    private func choosePhotos() {
        isRequesting = true
        Task {
            await library.requestAccess(session: session)
            onFinish()
        }
    }
}

/// Simple shape illustrations standing in for the mockup's two SVGs.
private enum OnboardingArt {
    static var cards: some View {
        VStack(spacing: 24) {
            ZStack {
                RoundedRectangle(cornerRadius: 18).fill(Palette.fill).frame(width: 124, height: 190).rotationEffect(.degrees(-9))
                RoundedRectangle(cornerRadius: 18)
                    .fill(Palette.card)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Palette.line, lineWidth: 2))
                    .frame(width: 124, height: 190)
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: 10).fill(Palette.accentSoft).frame(height: 104).padding(14)
                    }
                    .rotationEffect(.degrees(7))
            }
            HStack(spacing: 40) {
                Image(systemName: "arrow.left").foregroundStyle(Palette.destructive)
                Image(systemName: "arrow.right").foregroundStyle(Palette.deckKeep)
            }
            .font(.largeTitle.weight(.bold))
        }
    }

    static var privacy: some View { PrivacyArt() }
}

private struct PrivacyArt: View {
    @ScaledMetric(relativeTo: .largeTitle) private var size = 96

    var body: some View {
        Image(systemName: "photo.on.rectangle.angled")
            .font(.system(size: size))
            .foregroundStyle(.tint)
            .padding(48)
            .background(Palette.accentSoft, in: .circle)
    }
}

#Preview {
    OnboardingView {}
        .environment(LibraryModel())
        .environment(CleanupSession())
}
