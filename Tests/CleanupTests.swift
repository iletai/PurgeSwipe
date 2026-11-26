import Foundation
import Testing
@testable import PurgeSwipe

@MainActor
struct UsageStoreTests {
    private func makeStore(now: @escaping () -> Date = Date.init) -> UsageStore {
        let suite = "usage-\(UUID().uuidString)"
        return UsageStore(defaults: UserDefaults(suiteName: suite) ?? .standard, now: now)
    }

    @Test func firstCleanupIsUncappedThenFreeIsCapped() {
        let store = makeStore()
        #expect(!store.isCapped(isPro: false))
        store.recordDeletion(count: 100, bytes: 1, isPro: false)
        #expect(store.isCapped(isPro: false))
        #expect(!store.isCapped(isPro: true))
        // The uncapped first cleanup does not eat the daily allowance.
        #expect(store.remainingToday() == UsageStore.dailyDeletionCap)
        store.recordDeletion(count: 10, bytes: 1, isPro: false)
        #expect(store.remainingToday() == UsageStore.dailyDeletionCap - 10)
        #expect(store.lastCleanup == .init(count: 10, bytes: 1))
    }

    @Test func dailyCountersResetAtMidnight() {
        var date = Date(timeIntervalSince1970: 1_800_000_000)
        let store = makeStore { date }
        store.recordDeletion(count: 5, bytes: 1, isPro: false)
        store.recordDeletion(count: 20, bytes: 1, isPro: false)
        store.markOpened(groupKey: "similar#0")
        #expect(store.remainingToday() == 5)
        date.addTimeInterval(24 * 3600)
        #expect(store.remainingToday() == UsageStore.dailyDeletionCap)
        #expect(store.canOpen(groupKey: "similar#1", isPro: false))
    }

    @Test func freeUsersOpenTwoGroupsPerDay() {
        let store = makeStore()
        store.markOpened(groupKey: "similar#0")
        store.markOpened(groupKey: "similar#1")
        store.markOpened(groupKey: "similar#1")
        #expect(store.canOpen(groupKey: "similar#0", isPro: false))
        #expect(!store.canOpen(groupKey: "similar#2", isPro: false))
        #expect(store.canOpen(groupKey: "similar#2", isPro: true))
    }
}

@MainActor
struct CleanupSessionTests {
    private func session(_ ids: [String]) -> CleanupSession {
        let session = CleanupSession()
        session.setDeck(.screenshots, ids.map { CleanupAsset(id: $0, byteCount: 10) })
        return session
    }

    @Test func swipeMarksAndUndoRestores() {
        let session = session(["a", "b", "c"])
        session.decide(.delete, in: .screenshots)
        session.decide(.keep, in: .screenshots)
        #expect(session.marked.map(\.id) == ["a"])
        #expect(session.position(.screenshots) == 2)
        session.undo(in: .screenshots)
        session.undo(in: .screenshots)
        #expect(session.marked.isEmpty)
        #expect(session.position(.screenshots) == 0)
        #expect(!session.canUndo(.screenshots))
    }

    @Test func unmarkAndReviewEach() {
        let session = session(["a", "b", "c"])
        for _ in 0 ..< 3 {
            session.decide(.delete, in: .screenshots)
        }
        session.unmark("a")
        #expect(session.marked.map(\.id) == ["b", "c"])
        #expect(session.jumpToFirstMarked() == .screenshots)
        #expect(session.position(.screenshots) == 1)
    }

    @Test func removeDeletedClearsDecksAndDecisions() {
        let session = session(["a", "b"])
        session.decide(.delete, in: .screenshots)
        session.removeDeleted(["a"])
        #expect(session.assets(.screenshots).map(\.id) == ["b"])
        #expect(session.marked.isEmpty)
        #expect(session.position(.screenshots) == 0)
    }

    @Test func countLabelPicksNoun() {
        let photo = CleanupAsset(id: "p", byteCount: 1)
        let video = CleanupAsset(id: "v", byteCount: 1, isVideo: true)
        #expect([photo].countLabel.contains("1"))
        #expect([video, video].countLabel != [photo, photo].countLabel)
        #expect([photo, video].countLabel != [video, video].countLabel)
    }
}

struct AnalysisMathTests {
    @Test func flatImageHasNoSharpness() {
        let flat = [UInt8](repeating: 128, count: 16 * 16)
        #expect(Sharpness.laplacianVariance(gray: flat, width: 16, height: 16) == 0)
    }

    @Test func checkerboardIsSharperThanSmoothGradient() {
        let size = 32
        let checker = (0 ..< size * size).map { UInt8(($0 % size + $0 / size) % 2 == 0 ? 0 : 255) }
        let gradient = (0 ..< size * size).map { UInt8($0 % size * 8) }
        let sharp = Sharpness.laplacianVariance(gray: checker, width: size, height: size)
        let smooth = Sharpness.laplacianVariance(gray: gradient, width: size, height: size)
        #expect(sharp > AnalysisService.blurThreshold)
        #expect(smooth < AnalysisService.blurThreshold)
    }

    @Test func groupingKeepsOnlyRunsOfTwoOrMore() {
        // 0~1~2, 3 alone, 4~5
        let similarPairs: Set<[Int]> = [[0, 1], [1, 2], [4, 5]]
        let runs = SimilarGrouping.runs(count: 6) { similarPairs.contains([$0, $1]) }
        #expect(runs == [[0, 1, 2], [4, 5]])
        #expect(SimilarGrouping.runs(count: 0) { _, _ in true }.isEmpty)
    }
}
