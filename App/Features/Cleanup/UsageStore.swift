import Foundation
import Observation

/// Free-tier counters and the last cleanup result, kept in UserDefaults (on device, privacy reason CA92.1).
/// Rules: the first cleanup is uncapped; after it free users delete 25 items per local day and open
/// two similar/blurry groups per local day. Pro ignores all of it.
@MainActor
@Observable
final class UsageStore {
    static let dailyDeletionCap = 25
    static let freeGroupsPerDay = 2

    struct LastCleanup: Codable, Equatable {
        var count: Int
        var bytes: Int64
        var date: Date? = nil
    }

    struct State: Codable, Equatable {
        var firstCleanupDone = false
        /// Local day the two daily counters below belong to.
        var day = ""
        var deletedToday = 0
        var openedGroups: [String] = []
        var last: LastCleanup?
    }

    private(set) var state: State
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private static let key = "usageState"

    init(defaults: UserDefaults = .standard, now: @escaping () -> Date = Date.init) {
        self.defaults = defaults
        self.now = now
        state = defaults.data(forKey: Self.key).flatMap { try? JSONDecoder().decode(State.self, from: $0) } ?? State()
    }

    var lastCleanup: LastCleanup? { state.last }
    var lastCleanupDate: Date? { state.last?.date }

    func isCapped(isPro: Bool) -> Bool { state.firstCleanupDone && !isPro }

    func remainingToday() -> Int {
        max(0, Self.dailyDeletionCap - (state.day == today ? state.deletedToday : 0))
    }

    func canOpen(groupKey: String, isPro: Bool) -> Bool {
        guard !isPro else { return true }
        let opened = state.day == today ? state.openedGroups : []
        return opened.contains(groupKey) || opened.count < Self.freeGroupsPerDay
    }

    func markOpened(groupKey: String) {
        mutate { state in
            if !state.openedGroups.contains(groupKey) { state.openedGroups.append(groupKey) }
        }
    }

    /// Call after PhotoKit confirmed the deletion.
    func recordDeletion(count: Int, bytes: Int64, isPro: Bool) {
        let counts = isCapped(isPro: isPro)
        mutate { state in
            if counts { state.deletedToday += count }
            state.firstCleanupDone = true
            state.last = LastCleanup(count: count, bytes: bytes, date: now())
        }
    }

    private var today: String {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: now())
        return "\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)"
    }

    /// Rolls the daily counters over before applying a change, then persists.
    private func mutate(_ change: (inout State) -> Void) {
        var next = state
        if next.day != today {
            next.day = today
            next.deletedToday = 0
            next.openedGroups = []
        }
        change(&next)
        state = next
        if let data = try? JSONEncoder().encode(next) { defaults.set(data, forKey: Self.key) }
    }
}
