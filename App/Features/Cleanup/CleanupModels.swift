import SwiftUI

/// The four decks on Home. Raw values double as accessibility-id suffixes and group keys.
enum DeckKind: String, CaseIterable, Identifiable, Hashable, Sendable {
    case screenshots, similar, blurry, videos

    var id: String { rawValue }

    var titleKey: LocalizedStringKey {
        switch self {
        case .screenshots: "deck.screenshots"
        case .similar: "deck.similar"
        case .blurry: "deck.blurry"
        case .videos: "deck.videos"
        }
    }

    var symbol: String {
        switch self {
        case .screenshots: "rectangle.on.rectangle"
        case .similar: "square.on.square"
        case .blurry: "camera.filters"
        case .videos: "film"
        }
    }

    /// Similar and blurry decks are split into groups; free users open two groups a day.
    var isGrouped: Bool { self == .similar || self == .blurry }
}

/// One library item as the decks see it. `group` is the similar-set / blurry-chunk index (0 elsewhere).
struct CleanupAsset: Identifiable, Hashable, Sendable {
    let id: String
    let byteCount: Int64
    var isVideo = false
    var duration: TimeInterval = 0
    var group = 0
}

enum Decision: Sendable {
    case keep, delete
}

extension [CleanupAsset] {
    var totalBytes: Int64 { reduce(0) { $0 + $1.byteCount } }

    /// "18 photos", "3 videos" or "21 items" for a mixed selection.
    var countLabel: String {
        if !isEmpty, allSatisfy(\.isVideo) { return String(localized: "noun.videos \(count)") }
        if contains(where: \.isVideo) { return String(localized: "noun.items \(count)") }
        return String(localized: "noun.photos \(count)")
    }
}

extension Int64 {
    /// Localized "486 MB" style size.
    var byteString: String { formatted(.byteCount(style: .file, spellsOutZero: false)) }
}
