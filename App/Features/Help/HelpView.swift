import SwiftUI

/// Self-service help: FAQ, contact, refunds, legal. Reachable from Settings.
struct HelpView: View {
    private let faqs = FAQ.all

    var body: some View {
        List {
            Section("help.faq") {
                ForEach(faqs) { faq in
                    DisclosureGroup {
                        Text(faq.answerKey)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    } label: {
                        Text(faq.questionKey)
                    }
                }
            }

            Section("help.contact") {
                if let email = AppConfiguration.supportEmail, let url = URL(string: "mailto:\(email)") {
                    Link(destination: url) {
                        Label("help.email", systemImage: "envelope")
                    }
                }
                if let url = AppConfiguration.supportURL {
                    Link(destination: url) {
                        Label("help.website", systemImage: "safari")
                    }
                }
                if let url = URL(string: "https://reportaproblem.apple.com") {
                    Link(destination: url) {
                        Label("help.refund", systemImage: "arrow.uturn.backward.circle")
                    }
                }
            }

            legalSection
        }
        .navigationTitle("help.title")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("help.root")
    }

    @ViewBuilder
    private var legalSection: some View {
        if AppConfiguration.privacyURL != nil || AppConfiguration.termsURL != nil {
            Section("help.legal") {
                if let url = AppConfiguration.privacyURL {
                    Link("help.privacy", destination: url)
                }
                if let url = AppConfiguration.termsURL {
                    Link("help.terms", destination: url)
                }
            }
        }
    }
}

private struct FAQ: Identifiable {
    let id: Int
    let questionKey: LocalizedStringKey
    let answerKey: LocalizedStringKey

    static var all: [FAQ] {
        [
            FAQ(id: 0, questionKey: "help.question.1", answerKey: "help.answer.1"),
            FAQ(id: 1, questionKey: "help.question.2", answerKey: "help.answer.2"),
            FAQ(id: 2, questionKey: "help.question.3", answerKey: "help.answer.3"),
            FAQ(id: 3, questionKey: "help.question.4", answerKey: "help.answer.4")
        ]
    }
}

#Preview {
    NavigationStack {
        HelpView()
    }
}
