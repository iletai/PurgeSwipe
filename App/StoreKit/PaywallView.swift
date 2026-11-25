import StoreKit
import SwiftUI

/// Apple's paywall: subscriptions of the group + restore button, lifetime unlock underneath.
/// Privacy Policy and Terms of Use are required on the paywall by App Review 3.1.2.
struct PaywallView: View {
    var body: some View {
        VStack(spacing: 0) {
            SubscriptionStoreView(groupID: Store.groupID)
                .storeButton(.visible, for: .restorePurchases)
            ProductView(id: Store.lifetimeID)
                .productViewStyle(.compact)
                .padding()
            legalLinks
        }
    }

    @ViewBuilder
    private var legalLinks: some View {
        HStack(spacing: 16) {
            if let url = AppConfiguration.privacyURL {
                Link("settings.privacy", destination: url)
            }
            if let url = AppConfiguration.termsURL {
                Link("settings.terms", destination: url)
            }
        }
        .font(.footnote)
        .padding(.bottom, 16)
    }
}

#Preview {
    PaywallView()
}
