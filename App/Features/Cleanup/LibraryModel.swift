import Observation
import Photos

/// Photo access, library headline numbers and analysis progress for Home.
@MainActor
@Observable
final class LibraryModel {
    enum Access {
        case notDetermined, denied, limited, granted

        init(_ status: PHAuthorizationStatus) {
            switch status {
            case .authorized: self = .granted
            case .limited: self = .limited
            case .notDetermined: self = .notDetermined
            default: self = .denied
            }
        }

        var canRead: Bool { self == .granted || self == .limited }
    }

    private(set) var access = Access(PhotoLibrary.authorizationStatus)
    private(set) var isLoading = true
    private(set) var itemCount = 0
    private(set) var totalBytes: Int64?
    /// 0...1 per deck; 1 means the deck is ready to open.
    private(set) var progress: [DeckKind: Double] = [:]

    @ObservationIgnored private let service = AnalysisService()
    @ObservationIgnored private var tasks: [Task<Void, Never>] = []
    @ObservationIgnored private var scanned: (access: Access, count: Int)?

    var isEmptyLibrary: Bool { access.canRead && !isLoading && itemCount == 0 }

    func isReady(_ kind: DeckKind) -> Bool { access.canRead && (progress[kind] ?? 0) >= 1 }

    /// Re-reads authorization and restarts the scan when access or the item count changed.
    func refresh(session: CleanupSession) {
        access = Access(PhotoLibrary.authorizationStatus)
        guard access.canRead else {
            cancel()
            session.clearDecks()
            itemCount = 0
            totalBytes = nil
            progress = [:]
            isLoading = false
            return
        }
        let count = PHAsset.fetchAssets(with: nil).count
        defer { isLoading = false }
        if let scanned, scanned.access == access, scanned.count == count { return }
        scanned = (access, count)
        itemCount = count
        cancel()
        progress = [:]
        totalBytes = nil
        guard count > 0 else { return }
        let service = service
        tasks = [
            Task { totalBytes = await PhotoLibrary.totalBytes() },
            Task {
                await service.run { [weak self] event in
                    switch event {
                    case let .progress(kind, fraction): self?.progress[kind] = fraction
                    case let .deck(kind, assets):
                        session.setDeck(kind, assets)
                        self?.progress[kind] = 1
                    }
                }
            }
        ]
    }

    func requestAccess(session: CleanupSession) async {
        _ = await PhotoLibrary.requestAccess()
        refresh(session: session)
    }

    private func cancel() {
        tasks.forEach { $0.cancel() }
        tasks = []
    }
}
