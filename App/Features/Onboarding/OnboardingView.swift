import SwiftUI

/// First-run value tour. No login wall and no permission prompts: permissions wait for the feature that needs them.
struct OnboardingView: View {
    /// Persisted by RootView; UI tests override it with `-hasCompletedOnboarding NO`.
    static let completedKey = "hasCompletedOnboarding"

    let onFinish: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0

    private let pages = OnboardingPage.all

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if page < pages.count - 1 {
                    Button("onboarding.skip") { onFinish() }
                        .accessibilityIdentifier("onboarding.skip")
                }
            }
            .padding()

            TabView(selection: $page) {
                ForEach(pages) { item in
                    OnboardingPageView(page: item)
                        .tag(item.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(reduceMotion ? nil : .easeInOut, value: page)

            HStack(spacing: 8) {
                ForEach(pages) { item in
                    Circle()
                        .fill(item.id == page ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .accessibilityHidden(true)
                }
            }
            .padding(.bottom, 24)

            Button(page == pages.count - 1 ? "onboarding.getStarted" : "onboarding.continue") {
                if page == pages.count - 1 {
                    onFinish()
                } else {
                    withAnimation(reduceMotion ? nil : .easeInOut) {
                        page += 1
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .accessibilityIdentifier("onboarding.primary")
        }
        .background(Color(uiColor: .systemBackground))
    }
}

private struct OnboardingPage: Identifiable {
    let id: Int
    let systemImage: String
    let titleKey: LocalizedStringKey
    let bodyKey: LocalizedStringKey

    static var all: [OnboardingPage] {
        [
            OnboardingPage(id: 0, systemImage: "sparkles", titleKey: "onboarding.title.1", bodyKey: "onboarding.body.1"),
            OnboardingPage(id: 1, systemImage: "lock.shield", titleKey: "onboarding.title.2", bodyKey: "onboarding.body.2"),
            OnboardingPage(id: 2, systemImage: "slider.horizontal.3", titleKey: "onboarding.title.3", bodyKey: "onboarding.body.3")
        ]
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    @ScaledMetric(relativeTo: .largeTitle) private var iconSize = 64

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: page.systemImage)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            Text(page.titleKey)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text(page.bodyKey)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    OnboardingView {}
}
