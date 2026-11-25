import BaseNavigationStack
import SwiftUI

/// One router per navigation stack; screens read it with `@Environment(AppRouter.self)`.
struct RootView: View {
    @State private var router = AppRouter()
    @AppStorage(OnboardingView.completedKey) private var hasCompletedOnboarding = false
    @AppStorage(AppAppearance.storageKey) private var appearance = AppAppearance.system.rawValue

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                BaseNavigationContainer(
                    router: router,
                    content: { ContentView() },
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
        .preferredColorScheme(AppAppearance(rawValue: appearance)?.colorScheme)
    }
}
