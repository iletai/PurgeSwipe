import BaseNavigationStack
import SwiftUI

/// One router per navigation stack; screens read it with `@Environment(AppRouter.self)`.
struct RootView: View {
    @State private var router = AppRouter()
    @State private var library = LibraryModel()
    @State private var session = CleanupSession()
    @State private var usage = UsageStore()
    @AppStorage(OnboardingView.completedKey) private var hasCompletedOnboarding = false
    @AppStorage(AppAppearance.storageKey) private var appearance = AppAppearance.system.rawValue

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                BaseNavigationContainer(
                    router: router,
                    content: { HomeView() },
                    destination: { AppRouteView(route: $0) },
                    sheet: { AppSheetView(sheet: $0) },
                    cover: { _ in EmptyView() }
                )
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .environment(library)
        .environment(session)
        .environment(usage)
        // ATT and the ad SDK wait until the first-run tour is done.
        .task(id: hasCompletedOnboarding) {
            if hasCompletedOnboarding { await Ads.start() }
        }
        .preferredColorScheme(AppAppearance(rawValue: appearance)?.colorScheme)
    }
}
