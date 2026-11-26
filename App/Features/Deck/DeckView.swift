import BaseNavigationStack
import SwiftUI

/// Full-bleed swipe deck: left = delete, right = keep. Buttons and VoiceOver actions do the same.
struct DeckView: View {
    let kind: DeckKind

    @Environment(CleanupSession.self) private var session
    @Environment(UsageStore.self) private var usage
    @Environment(AppRouter.self) private var router
    @Environment(\.isPro) private var isPro
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var dragX: CGFloat = 0
    @State private var flyOut: Decision?
    @State private var showEnd = false
    @State private var keepCount = 0
    @State private var deleteCount = 0
    @State private var undoCount = 0

    private static let swipeThreshold: CGFloat = 90

    private var assets: [CleanupAsset] { session.assets(kind) }
    private var index: Int { session.position(kind) }
    private var current: CleanupAsset? { index < assets.count ? assets[index] : nil }
    private var currentLocked: Bool { isLocked(index) }

    var body: some View {
        ZStack {
            Color.black
            stage
        }
        .ignoresSafeArea()
        .overlay(alignment: .top) { topBar }
        .overlay(alignment: .bottom) { bottomBar }
        .overlay(alignment: .bottomLeading) { badges }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .sensoryFeedback(.success, trigger: keepCount)
        .sensoryFeedback(.impact(weight: .medium), trigger: deleteCount)
        .sensoryFeedback(.impact(weight: .light), trigger: undoCount)
        .sheet(isPresented: $showEnd) { endSheet }
    }

    // MARK: Stage

    @ViewBuilder
    private var stage: some View {
        if assets.isEmpty {
            messageCard(symbol: "photo", title: "deck.empty.title", body: "deck.empty.body") {
                Button("deck.backToCleanup") { router.popToRoot() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
        } else if let current {
            if currentLocked {
                messageCard(symbol: "lock", title: "deck.lock.title", body: "deck.lock.body") {
                    Button("deck.unlock") { router.present(sheet: .paywall) }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                }
            } else {
                ZStack {
                    if index + 1 < assets.count, !isLocked(index + 1) {
                        PhotoView(id: assets[index + 1].id, targetSize: Self.cardSize)
                            .scaleEffect(0.96)
                    }
                    topCard(current)
                }
            }
        } else {
            messageCard(symbol: "checkmark", title: "deck.end.title", body: nil) { EmptyView() }
        }
    }

    private static let cardSize = CGSize(width: 1080, height: 1920)

    /// Follows the finger; once a decision is made the card flies off (Reduce Motion: it only fades).
    private var cardOffset: CGFloat {
        guard let flyOut, !reduceMotion else { return dragX }
        return flyOut == .delete ? -500 : 500
    }

    private func topCard(_ asset: CleanupAsset) -> some View {
        PhotoView(id: asset.id, targetSize: Self.cardSize)
            .overlay(alignment: .topLeading) { stamp(
                "deck.keep",
                color: Color(red: 0.49, green: 0.94, blue: 0.63),
                angle: -10,
                show: dragX > 0
            ) }
            .overlay(alignment: .topTrailing) { stamp(
                "deck.delete",
                color: Color(red: 1, green: 0.54, blue: 0.54),
                angle: 10,
                show: dragX < 0
            ) }
            .offset(x: cardOffset)
            .rotationEffect(.degrees(reduceMotion ? 0 : Double(cardOffset) / 22))
            .opacity(flyOut == nil ? 1 : 0)
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { if flyOut == nil { dragX = $0.translation.width } }
                    .onEnded { value in
                        if abs(value.translation.width) > Self.swipeThreshold {
                            decide(value.translation.width < 0 ? .delete : .keep)
                        } else {
                            withAnimation(.snappy) { dragX = 0 }
                        }
                    }
            )
            .id(asset.id)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("deck.position \(index + 1) \(assets.count)"))
            .accessibilityAction(named: Text("deck.keep")) { decide(.keep) }
            .accessibilityAction(named: Text("deck.delete")) { decide(.delete) }
    }

    private func stamp(_ key: LocalizedStringKey, color: Color, angle: Double, show: Bool) -> some View {
        Text(key)
            .font(.title2.weight(.heavy))
            .textCase(.uppercase)
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(.black.opacity(0.35), in: .rect(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color, lineWidth: 3))
            .rotationEffect(.degrees(angle))
            .padding(.horizontal, 24)
            .padding(.top, 120)
            .opacity(show ? min(1, abs(dragX) / Self.swipeThreshold) : 0)
            .accessibilityHidden(true)
    }

    private func messageCard(
        symbol: String, title: LocalizedStringKey, body: LocalizedStringKey?, @ViewBuilder actions: () -> some View
    ) -> some View {
        VStack(spacing: 12) {
            Image(systemName: symbol).font(.largeTitle).accessibilityHidden(true)
            Text(title).font(.title2.bold())
            if let body { Text(body) }
            actions()
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.white)
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.08, green: 0.09, blue: 0.11))
    }

    // MARK: Decisions

    private func groupKey(_ asset: CleanupAsset) -> String { "\(kind.rawValue)#\(asset.group)" }

    private func isLocked(_ position: Int) -> Bool {
        guard kind.isGrouped, position < assets.count else { return false }
        return !usage.canOpen(groupKey: groupKey(assets[position]), isPro: isPro)
    }

    private func decide(_ decision: Decision) {
        guard let current, !currentLocked, flyOut == nil else { return }
        withAnimation(reduceMotion ? .smooth(duration: 0.15) : .snappy(duration: 0.28)) {
            flyOut = decision
        } completion: {
            session.decide(decision, in: kind)
            if kind.isGrouped, !isPro { usage.markOpened(groupKey: groupKey(current)) }
            if decision == .keep { keepCount += 1 } else { deleteCount += 1 }
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                flyOut = nil
                dragX = 0
            }
            if session.position(kind) >= assets.count { showEnd = true }
        }
    }

    private func undo() {
        session.undo(in: kind)
        undoCount += 1
    }

    // MARK: Chrome

    private var topBar: some View {
        VStack(spacing: 8) {
            HStack {
                Button { router.pop() } label: {
                    Image(systemName: "chevron.left").font(.title3.weight(.semibold)).frame(width: 44, height: 44)
                        .background(.black.opacity(0.45), in: .circle)
                }
                .accessibilityLabel("common.back")
                .accessibilityIdentifier("deck.back")
                Spacer()
                VStack {
                    Text(kind.titleKey).font(.headline)
                    if !assets.isEmpty {
                        Text("deck.position \(min(index + 1, assets.count)) \(assets.count)")
                            .font(.subheadline)
                            .contentTransition(.numericText())
                    }
                }
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            if kind == .similar { pill(Text("deck.similarHeader")) }
        }
        .foregroundStyle(.white)
        .padding(.bottom, 24)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: [.black.opacity(0.55), .clear], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
    }

    private var bottomBar: some View {
        VStack(spacing: 12) {
            Button { router.push(.review) } label: {
                pill(Text("deck.toDelete \(session.marked.count)").contentTransition(.numericText()), minHeight: 44)
            }
            .accessibilityIdentifier("deck.review")
            .animation(.smooth, value: session.marked.count)
            HStack(spacing: 24) {
                control("arrow.uturn.backward", key: "deck.undo", size: 52, fill: .black.opacity(0.62), action: undo)
                    .disabled(!session.canUndo(kind))
                    .opacity(session.canUndo(kind) ? 1 : 0.4)
                control("trash", key: "deck.delete", size: 64, fill: Palette.deckDelete) { decide(.delete) }
                    .disabled(current == nil || currentLocked)
                    .opacity(current == nil || currentLocked ? 0.4 : 1)
                control("checkmark", key: "deck.keep", size: 64, fill: Palette.deckKeep) { decide(.keep) }
                    .disabled(current == nil || currentLocked)
                    .opacity(current == nil || currentLocked ? 0.4 : 1)
            }
        }
        .foregroundStyle(.white)
        .padding(.top, 32)
        .padding(.bottom, 10)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
    }

    /// `key` is both the localized accessibility label and the UI-test identifier.
    private func control(_ symbol: String, key: String, size: CGFloat, fill: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(size > 60 ? .title2.weight(.semibold) : .title3.weight(.semibold))
                .frame(width: size, height: size)
                .background(fill, in: .circle)
                .overlay(Circle().stroke(.white.opacity(0.35), lineWidth: 2))
        }
        .accessibilityLabel(LocalizedStringKey(key))
        .accessibilityIdentifier(key)
    }

    private func pill(_ text: some View, minHeight: CGFloat = 32) -> some View {
        text.font(.subheadline.weight(.semibold))
            .padding(.horizontal, 12)
            .frame(minHeight: minHeight)
            .background(.black.opacity(0.62), in: .capsule)
            .foregroundStyle(.white)
    }

    @ViewBuilder
    private var badges: some View {
        if let current, !currentLocked {
            VStack(alignment: .leading, spacing: 8) {
                if current.isVideo {
                    pill(Text("deck.videoBadge \(Duration.seconds(current.duration).formatted(.time(pattern: .minuteSecond))) \(current.byteCount.byteString)"))
                }
                if let decision = session.decisions[current.id] {
                    pill(Text(decision == .delete ? LocalizedStringKey("deck.markedDelete") : "deck.kept"))
                }
            }
            .padding(.leading, 16)
            .padding(.bottom, 170)
        }
    }

    private var endSheet: some View {
        let count = session.marked.count
        return VStack(spacing: 16) {
            Text("deck.end.title").font(.title2.bold())
            Group {
                if count > 0 { Text("deck.end.body \(count)") } else { Text("deck.end.none") }
            }
            .foregroundStyle(Palette.secondaryText)
            if count > 0 {
                Button("deck.reviewCount \(count)") {
                    showEnd = false
                    router.push(.review)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                Button("common.notNow") { showEnd = false }
            } else {
                Button("deck.backToCleanup") {
                    showEnd = false
                    router.popToRoot()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .multilineTextAlignment(.center)
        .padding(24)
        .presentationDetents([.height(280)])
    }
}
