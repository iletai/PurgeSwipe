import BaseNavigationStack
import SwiftUI

/// Marked items grid, one system-confirmed deletion, then the "moved to Recently Deleted" summary.
struct ReviewView: View {
    private enum Phase: Equatable {
        case idle, deleting, cancelled, failed
        case success(summary: String)
    }

    @Environment(CleanupSession.self) private var session
    @Environment(UsageStore.self) private var usage
    @Environment(AppRouter.self) private var router
    @Environment(\.isPro) private var isPro
    @Environment(\.openURL) private var openURL

    @State private var phase = Phase.idle

    private var marked: [CleanupAsset] { session.marked }
    private var capped: Bool { usage.isCapped(isPro: isPro) }
    private var overCap: Bool { capped && marked.count > usage.remainingToday() }

    var body: some View {
        Group {
            if case let .success(summary) = phase {
                successView(summary)
            } else if marked.isEmpty {
                ContentUnavailableView {
                    Label("review.empty.title", systemImage: "trash")
                } description: {
                    Text("review.empty.body")
                } actions: {
                    Button("deck.backToCleanup") { router.popToRoot() }.buttonStyle(.bordered)
                }
            } else {
                grid
            }
        }
        .background(Palette.background)
        .navigationTitle("review.title")
        .navigationBarBackButtonHidden(isSuccess)
        .sensoryFeedback(trigger: phase) { _, new in
            switch new {
            case .success: .success
            case .failed: .error
            default: nil
            }
        }
    }

    private var isSuccess: Bool {
        if case .success = phase { true } else { false }
    }

    // MARK: Grid

    private var grid: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("review.summary \(marked.countLabel) \(marked.totalBytes.byteString)")
                if capped {
                    Text("review.leftToday \(usage.remainingToday()) \(UsageStore.dailyDeletionCap)")
                        .font(.subheadline)
                        .foregroundStyle(Palette.secondaryText)
                }
                if phase == .cancelled || phase == .failed {
                    Text(phase == .cancelled ? "review.cancelled" : "review.failed")
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Palette.fill, in: .rect(cornerRadius: Metrics.controlRadius))
                        .accessibilityAddTraits(.updatesFrequently)
                }
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                    ForEach(marked) { asset in
                        thumbnail(asset)
                    }
                }
                .animation(.smooth, value: marked.count)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .safeAreaInset(edge: .bottom) { footer }
    }

    private func thumbnail(_ asset: CleanupAsset) -> some View {
        Button {
            session.unmark(asset.id)
        } label: {
            PhotoView(id: asset.id)
                .aspectRatio(3 / 4, contentMode: .fit)
                .clipShape(.rect(cornerRadius: 10))
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "xmark")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(.black.opacity(0.65), in: .circle)
                        .padding(6)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("review.keepItem")
    }

    private var footer: some View {
        VStack(spacing: 8) {
            if overCap {
                Text("review.capNote \(UsageStore.dailyDeletionCap)")
                    .font(.footnote)
                    .foregroundStyle(Palette.secondaryText)
            }
            Button {
                if overCap { router.present(sheet: .paywall) } else { Task { await deleteMarked() } }
            } label: {
                HStack {
                    if phase == .deleting {
                        ProgressView()
                    } else if overCap {
                        Image(systemName: "lock.fill")
                    }
                    Text("review.delete \(marked.countLabel)")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(overCap ? .accentColor : Palette.destructive)
            .controlSize(.large)
            .disabled(phase == .deleting)
            .accessibilityIdentifier("review.delete")
            Button {
                if let kind = session.jumpToFirstMarked() { router.replacePath([.deck(kind)]) }
            } label: {
                WideLabel("review.each")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
    }

    // MARK: Delete

    private func deleteMarked() async {
        let items = marked
        phase = .deleting
        do {
            try await PhotoLibrary.delete(ids: items.map(\.id))
            usage.recordDeletion(count: items.count, bytes: items.totalBytes, isPro: isPro)
            session.removeDeleted(Set(items.map(\.id)))
            phase = .success(summary: String(localized: "review.movedTitle \(items.countLabel) \(items.totalBytes.byteString)"))
        } catch {
            // A cancelled system dialog keeps the selection; so does any other failure.
            phase = PhotoLibrary.wasCancelled(error) ? .cancelled : .failed
            Log.photos.error("delete failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func successView(_ summary: String) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                Image(systemName: "checkmark")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(.tint)
                    .frame(width: 72, height: 72)
                    .background(Palette.accentSoft, in: .circle)
                    .accessibilityHidden(true)
                Text(summary).font(.title2.bold())
                Text("review.movedBody").foregroundStyle(Palette.secondaryText)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.top, 32)
            Spacer()
            VStack(spacing: 8) {
                Button {
                    if let url = URL(string: "photos-redirect://") { openURL(url) }
                } label: {
                    WideLabel("review.finish")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                Button { router.popToRoot() } label: { WideLabel("review.done") }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .accessibilityIdentifier("review.done")
            }
            .padding(16)
        }
        .accessibilityElement(children: .contain)
    }
}
