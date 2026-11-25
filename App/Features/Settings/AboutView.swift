import SwiftUI

/// Version, copyright, legal links, acknowledgments. Reachable from Settings.
struct AboutView: View {
    var body: some View {
        List {
            Section {
                LabeledContent("about.version", value: AppInfo.versionDescription)
                if let copyright = AppInfo.copyright {
                    Text(copyright)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            legalSection

            Section("about.acknowledgments") {
                Text("about.acknowledgments.body")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("about.title")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("about.root")
    }

    @ViewBuilder
    private var legalSection: some View {
        if AppConfiguration.privacyURL != nil || AppConfiguration.termsURL != nil {
            Section("about.legal") {
                if let url = AppConfiguration.privacyURL {
                    Link("about.privacy", destination: url)
                }
                if let url = AppConfiguration.termsURL {
                    Link("about.terms", destination: url)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
