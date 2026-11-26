import BaseNavigationStack
import StoreKit
import SwiftUI

/// Pro status, plans, Restore Purchases (App Review 3.1.1) and subscription management.
struct PurchasesSection: View {
    @Environment(\.isPro) private var isPro
    @Environment(AppRouter.self) private var router
    @State private var restoreResult: LocalizedStringKey?

    var body: some View {
        Section("settings.purchases") {
            Text(isPro ? "settings.proActive" : "settings.freePlan")
            if !isPro {
                Button("settings.viewPlans") { router.present(sheet: .paywall) }
                    .accessibilityIdentifier("settings.viewPlans")
            }
            Button("settings.restorePurchases") {
                Task {
                    try? await AppStore.sync()
                    restoreResult = await Store.hasPro() ? "settings.restored" : "settings.restoreNone"
                }
            }
            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                Link("settings.manageSubscription", destination: url)
            }
        }
        .alert(restoreResult ?? "", isPresented: Binding(get: { restoreResult != nil }, set: { if !$0 { restoreResult = nil } })) {
            Button("common.ok") {}
        }
    }
}
