import StoreKit
import SwiftUI

/// `--with storekit` adds this section to Settings. Restore Purchases is required by App Review 3.1.1.
struct PurchasesSection: View {
    @Environment(\.isPro) private var isPro

    var body: some View {
        Section("settings.purchases") {
            if !isPro {
                NavigationLink("settings.viewPlans") {
                    PaywallView()
                }
            }
            Button("settings.restorePurchases") {
                Task { try? await AppStore.sync() }
            }
            if isPro, let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                Link("settings.manageSubscription", destination: url)
            }
        }
    }
}
