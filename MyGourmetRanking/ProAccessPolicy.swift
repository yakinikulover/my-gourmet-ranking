import Foundation

enum ProAccessPolicy {
    static let freeArchiveLimit = 3

    static func canAddArchive(
        stores: [Store],
        mainGenreId: String,
        subGenreId: String,
        isPro: Bool,
        editingStore: Store? = nil
    ) -> Bool {
        guard !isPro else { return true }
        guard editingStore?.rank != .archive else { return true }

        let archiveCount = stores.filter {
            $0.mainGenreId == mainGenreId
                && $0.subGenreId == subGenreId
                && $0.rank == .archive
        }.count
        return archiveCount < freeArchiveLimit
    }
}
