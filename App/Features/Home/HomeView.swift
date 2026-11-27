import BaseNavigationStack
import SwiftUI

/// Home "Cleanup": library headline, the four decks, last cleanup, banner ad.
struct HomeView: View {
    @Environment(LibraryModel.self) private var library
    @Environment(CleanupSession.self) private var session
    @Environment(UsageStore.self) private var usage
    @Environment(AppRouter.self) private var router
    @Environment(\.isPro) private var isPro
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if library.isLoading {
                    skeleton
                } else if library.isEmptyLibrary {
                    emptyLibrary
                } else {
                    content
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Palette.background)
        .navigationTitle("home.title")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.push(.settings)
                } label: {
                    Label("settings.title", systemImage: "gearshape")
                }
                .accessibilityIdentifier("home.settings")
            }
        }
        .task { library.refresh(session: session) }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { library.refresh(session: session) }
        }
    }

    @ViewBuilder
    private var content: some View {
        libraryCard
        accessNotice
        if let last = usage.lastCleanup {
            VStack(alignment: .leading, spacing: 4) {
                Text("home.lastCleanup").font(.subheadline).foregroundStyle(Palette.secondaryText)
                Text("home.lastCleanupBody \(String(localized: "noun.photos \(last.count)")) \(last.bytes.byteString)")
            }
            .cardBackground()
        }
        VStack(spacing: 8) {
            ForEach(DeckKind.allCases) { kind in
                DeckRow(kind: kind, openPaywall: { router.present(sheet: .paywall) })
            }
        }
        if !isPro {
            BannerAdView()
        }
    }

    private var libraryCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("home.library").font(.subheadline).foregroundStyle(Palette.secondaryText)
            Text(library.totalBytes?.byteString ?? "—")
                .font(.title.bold())
                .monospacedDigit()
                .contentTransition(.numericText())
            Text("home.itemCount \(library.itemCount)")
            Text("home.onPhone").font(.subheadline).foregroundStyle(Palette.secondaryText)
        }
        .cardBackground()
        .accessibilityElement(children: .combine)
        .animation(.smooth, value: library.totalBytes)
    }

    @ViewBuilder
    private var accessNotice: some View {
        switch library.access {
        case .notDetermined:
            notice(title: "home.needAccess", body: "onboarding.body.2", action: "onboarding.choose") {
                Task { await library.requestAccess(session: session) }
            }
        case .denied:
            notice(title: "home.denied.title", body: "home.denied.body", action: "home.openSettings") {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            }
        case .limited:
            notice(
                title: "home.limited.title",
                body: "home.limited.body \(library.itemCount)",
                action: "home.manageAccess",
                prominent: false
            ) {
                PhotoLibrary.presentLimitedPicker()
            }
        case .granted:
            EmptyView()
        }
    }

    private func notice(
        title: LocalizedStringKey, body: LocalizedStringKey, action: LocalizedStringKey, prominent: Bool = true,
        perform: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            Text(body)
            if prominent {
                Button(action: perform) { WideLabel(action) }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            } else {
                Button(action: perform) { WideLabel(action) }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
            }
        }
        .cardBackground(Palette.accentSoft)
    }

    private var emptyLibrary: some View {
        ContentUnavailableView {
            Label("home.empty.title", systemImage: "photo")
        } description: {
            Text("home.empty.body")
        } actions: {
            if library.access == .limited {
                Button("home.manageAccess") { PhotoLibrary.presentLimitedPicker() }
                    .buttonStyle(.bordered)
            }
        }
        .cardBackground()
    }

    /// Real layout with placeholder text, matching the mockup's loading state.
    private var skeleton: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("home.library")
                Text(verbatim: "00.0 GB").font(.title.bold())
                Text(verbatim: "00,000 items")
            }
            .cardBackground()
            ForEach(DeckKind.allCases) { kind in
                Text(kind.titleKey).frame(height: 40).cardBackground()
            }
        }
        .redacted(reason: .placeholder)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("home.loading")
    }
}

private struct DeckRow: View {
    let kind: DeckKind
    let openPaywall: () -> Void

    @Environment(LibraryModel.self) private var library
    @Environment(CleanupSession.self) private var session
    @Environment(AppRouter.self) private var router
    @Environment(\.isPro) private var isPro

    private var progress: Double { library.progress[kind] ?? 0 }
    private var ready: Bool { library.isReady(kind) }

    var body: some View {
        Button {
            if kind == .videos, !isPro {
                openPaywall()
            } else {
                router.push(.deck(kind))
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: kind.symbol)
                    .font(.title3)
                    .foregroundStyle(.tint)
                    .frame(width: 40, height: 40)
                    .background(Palette.accentSoft, in: .rect(cornerRadius: 10))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(kind.titleKey).font(.headline)
                    subtitle
                    if library.access.canRead, !ready {
                        ProgressView(value: progress).tint(.accentColor).accessibilityHidden(true)
                    }
                }
                Spacer(minLength: 8)
                if kind == .videos, !isPro {
                    Label("home.pro", systemImage: "lock.fill")
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Palette.accentSoft, in: .capsule)
                        .foregroundStyle(.tint)
                }
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Palette.secondaryText)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: 72)
            .padding(.horizontal, 16)
            .background(Palette.card, in: .rect(cornerRadius: Metrics.cardRadius))
            .contentShape(.rect(cornerRadius: Metrics.cardRadius))
        }
        .buttonStyle(.plain)
        .disabled(!ready)
        .opacity(ready ? 1 : 0.6)
        .accessibilityIdentifier("home.deck.\(kind.rawValue)")
    }

    @ViewBuilder
    private var subtitle: some View {
        Group {
            if !library.access.canRead {
                Text("home.needAccess")
            } else if !ready {
                Text("home.analyzing \(Int(progress * 100))")
            } else {
                let assets = session.assets(kind)
                Text("home.rowSubtitle \(assets.count) \(assets.totalBytes.byteString)")
            }
        }
        .font(.subheadline)
        .foregroundStyle(Palette.secondaryText)
    }
}
