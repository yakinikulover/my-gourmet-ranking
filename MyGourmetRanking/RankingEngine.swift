import Foundation

enum RankingEngine {
    static let bestRanks = [1, 2, 3, 4, 5]

    static func isSameCategory(_ store: Store, mainGenreId: String, subGenreId: String) -> Bool {
        store.mainGenreId == mainGenreId && store.subGenreId == subGenreId
    }

    static func buildBestRows(
        stores: [Store],
        mainGenreId: String,
        subGenreId: String
    ) -> [BestRankRow] {
        let rankedStores = Dictionary(
            uniqueKeysWithValues: stores.compactMap { store -> (Int, Store)? in
                guard isSameCategory(store, mainGenreId: mainGenreId, subGenreId: subGenreId),
                      let rank = store.rank.numericValue else {
                    return nil
                }
                return (rank, store)
            }
        )

        return bestRanks.map { rank in
            if let store = rankedStores[rank] {
                return .store(rank: rank, store: store)
            }
            return .tbd(rank: rank)
        }
    }

    static func archiveStores(
        stores: [Store],
        mainGenreId: String,
        subGenreId: String
    ) -> [Store] {
        stores
            .filter { store in
                isSameCategory(store, mainGenreId: mainGenreId, subGenreId: subGenreId)
                    && store.rank == .archive
            }
            .sorted { lhs, rhs in
                let lhsRank = lhs.previousRank ?? 99
                let rhsRank = rhs.previousRank ?? 99
                if lhsRank != rhsRank {
                    return lhsRank < rhsRank
                }
                return lhs.updatedAt > rhs.updatedAt
            }
    }

    static func upsertStore(stores: [Store], incomingStore: Store) -> [Store] {
        let existingStore = stores.first { $0.id == incomingStore.id }
        let baseStores = stores.filter { $0.id != incomingStore.id }

        guard let incomingRank = incomingStore.rank.numericValue else {
            var archivedStore = incomingStore
            archivedStore.rank = .archive
            archivedStore.previousRank = existingStore?.rank.numericValue ?? incomingStore.previousRank
            return baseStores + [archivedStore]
        }

        var categoryRanks: [Int: Store] = [:]
        var unaffectedStores: [Store] = []

        for store in baseStores {
            if isSameCategory(store, mainGenreId: incomingStore.mainGenreId, subGenreId: incomingStore.subGenreId),
               let rank = store.rank.numericValue {
                categoryRanks[rank] = store
            } else {
                unaffectedStores.append(store)
            }
        }

        var insertedStore = incomingStore
        insertedStore.previousRank = nil
        categoryRanks[incomingRank] = insertedStore

        var displacedStore = categoryRanks[incomingRank]
        if displacedStore?.id == insertedStore.id {
            displacedStore = stores.first {
                $0.id != incomingStore.id
                    && $0.mainGenreId == incomingStore.mainGenreId
                    && $0.subGenreId == incomingStore.subGenreId
                    && $0.rank.numericValue == incomingRank
            }
        }

        var archivedStores: [Store] = []
        if incomingRank < 5 {
            for nextRank in (incomingRank + 1)...5 {
                guard let storeToMove = displacedStore else {
                    break
                }

                let nextDisplacedStore = categoryRanks[nextRank]
                var movedStore = storeToMove
                movedStore.rank = .ranked(nextRank)
                movedStore.updatedAt = incomingStore.updatedAt
                categoryRanks[nextRank] = movedStore
                displacedStore = nextDisplacedStore
            }
        }

        if let storeToArchive = displacedStore {
            var archivedStore = storeToArchive
            archivedStore.rank = .archive
            archivedStore.previousRank = 5
            archivedStore.updatedAt = incomingStore.updatedAt
            archivedStores.append(archivedStore)
        }

        let rankedStores = categoryRanks.values.sorted {
            ($0.rank.numericValue ?? 99) < ($1.rank.numericValue ?? 99)
        }
        return unaffectedStores + rankedStores + archivedStores
    }

    static func moveStoreToArchive(stores: [Store], storeId: String, updatedAt: Date) -> [Store] {
        stores.map { store in
            guard store.id == storeId else {
                return store
            }

            var archivedStore = store
            archivedStore.previousRank = store.rank.numericValue ?? store.previousRank
            archivedStore.rank = .archive
            archivedStore.updatedAt = updatedAt
            return archivedStore
        }
    }

    static func deleteStore(stores: [Store], storeId: String) -> [Store] {
        stores.filter { $0.id != storeId }
    }
}
