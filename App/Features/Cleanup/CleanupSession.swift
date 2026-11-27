import Observation

/// Swipe decisions, per-deck position and undo history for the running session. In memory only.
@MainActor
@Observable
final class CleanupSession {
    private(set) var decks: [DeckKind: [CleanupAsset]] = [:]
    private(set) var decisions: [String: Decision] = [:]
    private var positions: [DeckKind: Int] = [:]
    private var history: [DeckKind: [(id: String, previous: Decision?)]] = [:]

    func assets(_ kind: DeckKind) -> [CleanupAsset] { decks[kind] ?? [] }
    func position(_ kind: DeckKind) -> Int { positions[kind] ?? 0 }
    func canUndo(_ kind: DeckKind) -> Bool { !(history[kind] ?? []).isEmpty }

    /// Assets marked for deletion, once each, in deck order.
    var marked: [CleanupAsset] {
        var seen = Set<String>()
        return DeckKind.allCases
            .flatMap { assets($0) }
            .filter { decisions[$0.id] == .delete && seen.insert($0.id).inserted }
    }

    /// Analysis finished (or refreshed) a deck. Decisions for assets that still exist survive.
    func setDeck(_ kind: DeckKind, _ assets: [CleanupAsset]) {
        decks[kind] = assets
        positions[kind] = min(position(kind), assets.count)
        history[kind] = nil
    }

    func clearDecks() {
        decks = [:]
        positions = [:]
        history = [:]
    }

    /// Records a decision for the card on top and advances.
    func decide(_ decision: Decision, in kind: DeckKind) {
        let list = assets(kind)
        let index = position(kind)
        guard index < list.count else { return }
        let id = list[index].id
        history[kind, default: []].append((id, decisions[id]))
        decisions[id] = decision
        positions[kind] = index + 1
    }

    func undo(in kind: DeckKind) {
        guard let last = history[kind]?.popLast() else { return }
        decisions[last.id] = last.previous
        positions[kind] = max(0, position(kind) - 1)
    }

    /// Review grid "x": the item stays in the library.
    func unmark(_ id: String) {
        decisions[id] = .keep
    }

    /// "Review each": puts the first marked item on top of its deck. Returns that deck.
    func jumpToFirstMarked() -> DeckKind? {
        guard let first = marked.first else { return nil }
        for kind in DeckKind.allCases {
            if let index = assets(kind).firstIndex(where: { $0.id == first.id }) {
                positions[kind] = index
                return kind
            }
        }
        return nil
    }

    /// After the system deletion succeeded.
    func removeDeleted(_ ids: Set<String>) {
        for kind in DeckKind.allCases {
            decks[kind]?.removeAll { ids.contains($0.id) }
        }
        ids.forEach { decisions[$0] = nil }
        positions = [:]
        history = [:]
    }
}
