import StoreKit
import SwiftUI

/// Apple's paywall: subscriptions of the group + restore button, lifetime unlock underneath.
/// Prices, the free trial and renewal terms come from StoreKit; nothing is hardcoded here.
/// Privacy Policy and Terms of Use are required on the paywall by App Review 3.1.2.
struct PaywallView: View {
    var body: some View {
        VStack(spacing: 0) {
            SubscriptionStoreView(groupID: Store.groupID) {
                benefits
            }
            .storeButton(.visible, for: .restorePurchases)
            ProductView(id: Store.lifetimeID)
                .productViewStyle(.compact)
                .padding()
            legalLinks
        }
    }

    private var benefits: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(["paywall.benefit.1", "paywall.benefit.2", "paywall.benefit.3", "paywall.benefit.4"], id: \.self) { key in
                Label(LocalizedStringKey(key), systemImage: "checkmark")
                    .labelStyle(BenefitLabelStyle())
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
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

private struct BenefitLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 12) {
            configuration.icon.foregroundStyle(.tint).fontWeight(.semibold)
            configuration.title
        }
    }
}

#Preview {
    PaywallView()
}
