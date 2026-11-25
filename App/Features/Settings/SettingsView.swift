import StoreKit
import SwiftUI
import UIKit

/// Settings hub: appearance, support, legal links, about. `--with storekit` adds a Purchases section.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview
    @AppStorage(AppAppearance.storageKey) private var appearance = AppAppearance.system.rawValue

    var body: some View {
        Form {
            appearanceSection
            supportSection
            legalSection
            aboutSection
            PurchasesSection()
        }
        .navigationTitle("settings.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("settings.done") { dismiss() }
                    .accessibilityIdentifier("settings.done")
            }
        }
    }

    private var appearanceSection: some View {
        Section("settings.appearance") {
            Picker("settings.appearance", selection: $appearance) {
                ForEach(AppAppearance.allCases) { item in
                    Text(item.titleKey).tag(item.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }

    private var supportSection: some View {
        Section("settings.support") {
            NavigationLink {
                HelpView()
            } label: {
                Label("settings.help", systemImage: "questionmark.circle")
            }
            .accessibilityIdentifier("settings.help")

            if let email = AppConfiguration.supportEmail, let url = URL(string: "mailto:\(email)") {
                Link(destination: url) {
                    Label("settings.contact", systemImage: "envelope")
                }
            }

            Button {
                requestReview()
            } label: {
                Label("settings.rate", systemImage: "star")
            }

            if let shareURL = AppConfiguration.appStoreURL {
                ShareLink(item: shareURL) {
                    Label("settings.share", systemImage: "square.and.arrow.up")
                }
            }

            Button {
                openSystemSettings()
            } label: {
                Label("settings.systemSettings", systemImage: "gearshape.2")
            }
        }
    }

    @ViewBuilder
    private var legalSection: some View {
        if AppConfiguration.privacyURL != nil || AppConfiguration.termsURL != nil {
            Section("settings.legal") {
                if let url = AppConfiguration.privacyURL {
                    Link(destination: url) {
                        Label("settings.privacy", systemImage: "hand.raised")
                    }
                }
                if let url = AppConfiguration.termsURL {
                    Link(destination: url) {
                        Label("settings.terms", systemImage: "doc.text")
                    }
                }
            }
        }
    }

    private var aboutSection: some View {
        Section("settings.about") {
            NavigationLink {
                AboutView()
            } label: {
                Label("settings.about", systemImage: "info.circle")
            }
            .accessibilityIdentifier("settings.about")
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
