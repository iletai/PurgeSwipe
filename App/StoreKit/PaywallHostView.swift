import BaseNavigationStack
import SwiftUI

/// Paywall sheet host for `--with nav`: adds the visible Close button.
struct PaywallHostView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        NavigationStack {
            PaywallView()
                .navigationTitle("paywall.title")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("common.close", systemImage: "xmark") { router.dismiss() }
                            .labelStyle(.iconOnly)
                            .accessibilityIdentifier("paywall.close")
                    }
                }
        }
    }
}
