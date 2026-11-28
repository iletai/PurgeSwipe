import BaseNavigationStack
import SwiftUI

/// Full-bleed swipe deck: left = purge, right = keep. Buttons and VoiceOver actions do the same.
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

    private var progress: Double {
        assets.isEmpty ? 0 : Double(min(index, assets.count)) / Double(assets.count)
    }

    var body: some View {
        ZStack {
            Brand.deck
            stage
        }
        .ignoresSafeArea()
        .overlay(alignment: .top) { topBar }
        .overlay(alignment: .bottom) { bottomBar }
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
                    .buttonStyle(.brand)
                    .padding(.horizontal, 32)
            }
        } else if let current {
            if currentLocked {
                messageCard(symbol: "lock", title: "deck.lock.title", body: "deck.lock.body") {
                    Button("deck.unlock") { router.present(sheet: .paywall) }
                        .buttonStyle(.brand)
                        .padding(.horizontal, 32)
                }
            } else {
                ZStack {
                    if index + 1 < assets.count, !isLocked(index + 1) {
                        PhotoView(id: assets[index + 1].id, targetSize: Self.cardSize)
                            .clipShape(.rect(cornerRadius: 24))
                            .scaleEffect(0.94)
                            .opacity(0.55)
                            .offset(y: 14)
                    }
                    topCard(current)
                }
                .padding(.horizontal, 20)
                .padding(.top, 96)
                .padding(.bottom, 168)
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
            .overlay(alignment: .bottom) { cardFooter(asset) }
            .overlay(alignment: .topTrailing) { ageStamp(asset) }
            .overlay(alignment: .topLeading) { stamp(
                "deck.keep",
                color: Palette.deckKeep,
                angle: -10,
                show: dragX > 0
            ) }
            .overlay(alignment: .topTrailing) { stamp(
                "deck.delete",
                color: Palette.deckDelete,
                angle: 10,
                show: dragX < 0
            ) }
            .clipShape(.rect(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(.white.opacity(0.12), lineWidth: 1))
            .shadow(color: .black.opacity(0.5), radius: 28, y: 18)
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

    private func cardFooter(_ asset: CleanupAsset) -> some View {
        HStack(spacing: 8) {
            if let date = asset.creationDate {
                Text(date, format: .dateTime.day().month(.abbreviated).year())
            }
            Spacer(minLength: 0)
            Text(asset.byteCount.byteString).monospacedDigit()
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            LinearGradient(colors: [.clear, .black.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        )
    }

    @ViewBuilder
    private func ageStamp(_ asset: CleanupAsset) -> some View {
        if let days = asset.ageDays {
            Text("deck.ageDays \(days)")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Palette.deckInk)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Brand.gold, in: .capsule)
                .rotationEffect(.degrees(-6))
                .padding(12)
                .accessibilityHidden(true)
        }
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
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .opacity(show ? min(1, abs(dragX) / Self.swipeThreshold) : 0)
            .accessibilityHidden(true)
    }

    private func messageCard(
        symbol: String, title: LocalizedStringKey, body: LocalizedStringKey?, @ViewBuilder actions: () -> some View
    ) -> some View {
        VStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(Palette.teal)
                .accessibilityHidden(true)
            Text(title).font(.title2.bold())
            if let body {
                Text(body)
                    .foregroundStyle(.white.opacity(0.72))
                    .multilineTextAlignment(.center)
            }
            actions()
        }
        .foregroundStyle(.white)
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Brand.deck)
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
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button { router.pop() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.12), in: .circle)
                        .overlay(Circle().strokeBorder(.white.opacity(0.14), lineWidth: 1))
                }
                .accessibilityLabel("common.back")
                .accessibilityIdentifier("deck.back")

                HStack(spacing: 8) {
                    DeckTile(kind: kind, size: 24)
                    Text(kind.titleKey).font(.subheadline.weight(.semibold))
                    Text("deck.position \(min(index + 1, assets.count)) \(assets.count)")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .frame(minHeight: 40)
                .background(.white.opacity(0.10), in: .capsule)
                .overlay(Capsule().strokeBorder(.white.opacity(0.12), lineWidth: 1))

                Spacer(minLength: 0)
                Color.clear.frame(width: 44, height: 44)
            }
            BrandProgressBar(fraction: progress, height: 3)
                .opacity(assets.isEmpty ? 0 : 1)
            if kind == .similar { pill(Text("deck.similarHeader")) }
        }
        .foregroundStyle(.white)
        .padding(.bottom, 20)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: [Palette.deckInk.opacity(0.92), .clear], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
    }

    private var bottomBar: some View {
        VStack(spacing: 12) {
            Text("deck.hint")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.62))

            Button { router.push(.review) } label: {
                pill(Text("deck.toDelete \(session.marked.count)").contentTransition(.numericText()), minHeight: 40)
            }
            .accessibilityIdentifier("deck.review")
            .animation(.smooth, value: session.marked.count)

            HStack(spacing: 12) {
                Button(action: undo) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.title3.weight(.semibold))
                        .frame(width: 52, height: 52)
                        .background(.white.opacity(0.12), in: .circle)
                        .overlay(Circle().strokeBorder(.white.opacity(0.16), lineWidth: 1))
                }
                .accessibilityLabel("deck.undo")
                .accessibilityIdentifier("deck.undo")
                .disabled(!session.canUndo(kind))
                .opacity(session.canUndo(kind) ? 1 : 0.4)

                decisionButton(
                    "checkmark", key: "deck.keep", fill: Palette.deckKeep,
                    foreground: Palette.deckInk, disabled: current == nil || currentLocked
                ) { decide(.keep) }

                decisionButton(
                    "trash.fill", key: "deck.delete", fill: Palette.deckDelete,
                    foreground: .white, disabled: current == nil || currentLocked
                ) { decide(.delete) }
            }
        }
        .foregroundStyle(.white)
        .padding(.top, 28)
        .padding(.bottom, 10)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: [.clear, Palette.deckInk.opacity(0.94)], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
    }

    /// `key` is both the localized label and the UI-test identifier.
    private func decisionButton(
        _ symbol: String, key: String, fill: Color, foreground: Color, disabled: Bool, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: symbol).font(.headline)
                Text(LocalizedStringKey(key)).font(.headline)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(fill, in: .rect(cornerRadius: Metrics.cardRadius))
        }
        .disabled(disabled)
        .opacity(disabled ? 0.4 : 1)
        .accessibilityLabel(LocalizedStringKey(key))
        .accessibilityIdentifier(key)
    }

    private func pill(_ text: some View, minHeight: CGFloat = 32) -> some View {
        text.font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .frame(minHeight: minHeight)
            .background(.white.opacity(0.12), in: .capsule)
            .overlay(Capsule().strokeBorder(.white.opacity(0.14), lineWidth: 1))
            .foregroundStyle(.white)
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
                .buttonStyle(.brand)
                .padding(.horizontal, 24)
                Button("common.notNow") { showEnd = false }
            } else {
                Button("deck.backToCleanup") {
                    showEnd = false
                    router.popToRoot()
                }
                .buttonStyle(.brand)
                .padding(.horizontal, 24)
            }
        }
        .multilineTextAlignment(.center)
        .padding(24)
        .presentationDetents([.height(300)])
    }
}
