import Foundation
import SwiftUI
import AppUpdateKit

@main
struct PurgeSwipeApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var hasSubscription = false
    @State private var hasLifetime = false
    @State private var updateAction: AppUpdateAction = .none

    init() {
        // UI tests start from a clean first run; a launch argument cannot override writes to the flag.
        if ProcessInfo.processInfo.arguments.contains("-resetOnboarding") {
            UserDefaults.standard.removeObject(forKey: OnboardingView.completedKey)
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.isPro, hasSubscription || hasLifetime)
                .subscriptionStatusTask(for: Store.groupID) { state in
                    guard case .success(let statuses) = state else { return }
                    hasSubscription = statuses.contains { $0.state == .subscribed || $0.state == .inGracePeriod }
                }
                .currentEntitlementTask(for: Store.lifetimeID) { state in
                    guard case .success(let result) = state else { return }
                    if case .verified(let transaction)? = result {
                        hasLifetime = transaction.revocationDate == nil
                    } else {
                        hasLifetime = false
                    }
                }
                .task {
                    await AppUpdateService.shared.check()
                    updateAction = AppUpdateService.shared.action
                }
                .onChange(of: scenePhase) { _, phase in
                    guard phase == .active else { return }
                    Task {
                        await AppUpdateService.shared.check()   // oncePerSession throttles
                        updateAction = AppUpdateService.shared.action
                    }
                }
                .appUpdateSheet(action: $updateAction, accentColor: .accentColor)
                .task { await Ads.start() }
        }
    }
}
