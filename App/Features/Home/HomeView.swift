import BaseNavigationStack
import SwiftUI

/// Home "Inbox": the weekly screenshot pile, by deck, plus the older queue and the last cleanup.
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
            VStack(spacing: 20) {
                if library.isLoading {
                    skeleton
                } else if library.isEmptyLibrary {
                    emptyLibrary
                } else if library.access.canRead {
                    hero
                    if let last = usage.lastCleanup { lastCleanupCard(last) }
                    byDeck
                    olderQueue
                } else {
                    accessNotice
                }
                if !isPro { BannerAdView() }
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

    // MARK: Inbox data

    private var screenshots: [CleanupAsset] { session.assets(.screenshots) }
    private var screenshotsReady: Bool { library.isReady(.screenshots) }

    /// Shots taken since the last confirmed cleanup (all of them on the first run).
    private var newShots: [CleanupAsset] {
        let cutoff = usage.lastCleanupDate ?? .distantPast
        return screenshots.filter { ($0.creationDate ?? .distantPast) > cutoff }
    }

    private var olderShots: [CleanupAsset] {
        let cutoff = Date.now.addingTimeInterval(-30 * 86_400)
        return screenshots.filter { asset in
            guard let date = asset.creationDate else { return false }
            return date < cutoff
        }
    }

    private var largestDeckBytes: Int64 {
        max(1, DeckKind.allCases.map { session.assets($0).totalBytes }.max() ?? 1)
    }

    // MARK: Hero

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("home.hero.badge", systemImage: "sparkles")
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(Palette.deckInk)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Brand.gold, in: .capsule)
                Spacer(minLength: 8)
                if usage.lastCleanupDate == nil {
                    Text("home.hero.firstRun")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.82))
                }
            }

            if screenshotsReady {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(newShots.count.formatted())
                        .font(.display(58))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                    Text("home.hero.newShots")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                Text(usage.lastCleanupDate == nil
                    ? "home.hero.total \(newShots.totalBytes.byteString)"
                    : "home.hero.since \(newShots.totalBytes.byteString)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                Button {
                    router.push(.deck(.screenshots))
                } label: {
                    Text("home.hero.start")
                        .font(.headline)
                        .foregroundStyle(Palette.deckInk)
                        .padding(.horizontal, 22)
                        .frame(minHeight: 46)
                        .background(.white, in: .capsule)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("home.start")
                .padding(.top, 4)
            } else {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 88)
                Text("home.analyzing \(Int((library.progress[.screenshots] ?? 0) * 100))")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Brand.hero, in: .rect(cornerRadius: Metrics.heroRadius))
        .shadow(color: Palette.blue.opacity(0.28), radius: 24, y: 12)
        .accessibilityElement(children: .contain)
    }

    // MARK: Sections

    private var byDeck: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("home.byDeck", detail: screenshotsReady ? Text("home.itemCount \(library.itemCount)") : nil)
            VStack(spacing: 8) {
                ForEach(DeckKind.allCases) { kind in
                    InboxDeckRow(kind: kind, largestDeckBytes: largestDeckBytes) {
                        if kind == .videos, !isPro {
                            router.present(sheet: .paywall)
                        } else {
                            router.push(.deck(kind))
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var olderQueue: some View {
        if screenshotsReady, !olderShots.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader("home.older", detail: nil, pro: !isPro)
                Button {
                    if !isPro { router.present(sheet: .paywall) }
                } label: {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: Metrics.tileRadius, style: .continuous)
                            .fill(Palette.gold.opacity(0.16))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Palette.gold)
                            }
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("home.older.count \(olderShots.count)")
                                .font(.headline)
                            Text("home.older.body \(olderShots.totalBytes.byteString)")
                                .font(.footnote)
                                .foregroundStyle(Palette.secondaryText)
                        }
                        Spacer(minLength: 8)
                        if !isPro {
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Palette.secondaryText)
                                .accessibilityHidden(true)
                        }
                    }
                    .padding(12)
                    .background(Palette.card, in: .rect(cornerRadius: Metrics.cardRadius))
                    .contentShape(.rect(cornerRadius: Metrics.cardRadius))
                }
                .buttonStyle(.plain)
                .disabled(isPro)
                .accessibilityIdentifier("home.older")
            }
        }
    }

    private func sectionHeader(_ title: LocalizedStringKey, detail: Text?, pro: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).font(.title3.bold())
            if pro {
                Text("home.pro")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Palette.gold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Palette.gold.opacity(0.14), in: .capsule)
            }
            Spacer()
            if let detail {
                detail
                    .font(.subheadline)
                    .foregroundStyle(Palette.secondaryText)
                    .monospacedDigit()
            }
        }
    }

    private func lastCleanupCard(_ last: UsageStore.LastCleanup) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(Palette.success)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("home.lastCleanup").font(.subheadline.weight(.semibold))
                    if let date = last.date {
                        Text(date, format: .dateTime.day().month(.abbreviated))
                            .font(.subheadline)
                            .foregroundStyle(Palette.secondaryText)
                    }
                }
                Text("home.lastCleanupBody \(String(localized: "noun.photos \(last.count)")) \(last.bytes.byteString)")
                    .font(.footnote)
                    .foregroundStyle(Palette.secondaryText)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.card, in: .rect(cornerRadius: Metrics.cardRadius))
    }

    // MARK: States

    @ViewBuilder
    private var accessNotice: some View {
        switch library.access {
        case .notDetermined:
            notice(
                symbol: "photo.on.rectangle.angled",
                title: "home.needAccess",
                body: "home.needAccessBody",
                action: "onboarding.choose",
                prominent: true
            ) {
                Task { await library.requestAccess(session: session) }
            }
        case .denied:
            notice(
                symbol: "lock.slash",
                title: "home.denied.title",
                body: "home.denied.body",
                action: "home.openSettings",
                prominent: true
            ) {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            }
        case .limited:
            notice(
                symbol: "photo.badge.plus",
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
        symbol: String, title: LocalizedStringKey, body: LocalizedStringKey, action: LocalizedStringKey,
        prominent: Bool, perform: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: Metrics.tileRadius, style: .continuous)
                .fill(Palette.accentSoft)
                .frame(width: 52, height: 52)
                .overlay {
                    Image(systemName: symbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Palette.blue)
                }
                .accessibilityHidden(true)
            Text(title).font(.title3.bold())
            Text(body).foregroundStyle(Palette.secondaryText)
            if prominent {
                Button(action: perform) { WideLabel(action) }
                    .buttonStyle(.brand)
            } else {
                Button(action: perform) { WideLabel(action) }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
            }
        }
        .cardBackground()
    }

    private var emptyLibrary: some View {
        ContentUnavailableView {
            Label("home.empty.title", systemImage: "photo.on.rectangle.angled")
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

    /// Inbox-shaped shimmer, not grey boxes.
    private var skeleton: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: Metrics.heroRadius)
                .fill(Brand.hero)
                .frame(height: 190)
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 10) {
                        Capsule().fill(.white.opacity(0.5)).frame(width: 120, height: 14)
                        Capsule().fill(.white.opacity(0.7)).frame(width: 90, height: 46)
                        Capsule().fill(.white.opacity(0.4)).frame(width: 180, height: 12)
                    }
                    .padding(20)
                }
            VStack(spacing: 8) {
                ForEach(DeckKind.allCases) { kind in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: Metrics.tileRadius)
                            .fill(Brand.tile(kind))
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading, spacing: 6) {
                            Capsule().fill(Palette.fill).frame(width: 110, height: 12)
                            Capsule().fill(Palette.fill).frame(width: 150, height: 9)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(Palette.card, in: .rect(cornerRadius: Metrics.cardRadius))
                }
            }
        }
        .redacted(reason: .placeholder)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("home.loading")
    }
}

/// One deck as an inbox row: gradient tile, count and size, share-of-inbox bar.
private struct InboxDeckRow: View {
    let kind: DeckKind
    let largestDeckBytes: Int64
    let action: () -> Void

    @Environment(LibraryModel.self) private var library
    @Environment(CleanupSession.self) private var session
    @Environment(\.isPro) private var isPro

    private var progress: Double { library.progress[kind] ?? 0 }
    private var ready: Bool { library.isReady(kind) }
    private var assets: [CleanupAsset] { session.assets(kind) }

    private var fraction: Double {
        ready ? Double(assets.totalBytes) / Double(largestDeckBytes) : progress
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                DeckTile(kind: kind)
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(kind.titleKey).font(.headline)
                        Spacer(minLength: 8)
                        if ready {
                            Text(assets.totalBytes.byteString)
                                .font(.subheadline)
                                .foregroundStyle(Palette.secondaryText)
                                .monospacedDigit()
                        } else if kind == .videos, !isPro {
                            Label("home.pro", systemImage: "lock.fill")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Palette.gold)
                        }
                    }
                    HStack {
                        subtitle
                        Spacer(minLength: 0)
                    }
                    BrandProgressBar(fraction: fraction)
                        .padding(.top, 2)
                }
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Palette.secondaryText)
                    .accessibilityHidden(true)
            }
            .padding(12)
            .background(Palette.card, in: .rect(cornerRadius: Metrics.cardRadius))
            .contentShape(.rect(cornerRadius: Metrics.cardRadius))
        }
        .buttonStyle(.plain)
        .disabled(!ready)
        .opacity(ready ? 1 : 0.75)
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
                Text(verbatim: assets.countLabel)
            }
        }
        .font(.footnote)
        .foregroundStyle(Palette.secondaryText)
    }
}
