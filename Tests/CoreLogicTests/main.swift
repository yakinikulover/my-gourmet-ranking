import Foundation

private func makeStore(
    id: String,
    rank: StoreRank,
    mainGenreId: String = "main-a",
    subGenreId: String = "sub-a"
) -> Store {
    Store(
        id: id,
        name: id,
        mainGenreId: mainGenreId,
        subGenreId: subGenreId,
        rank: rank,
        previousRank: nil,
        createdAt: Date(timeIntervalSince1970: 0),
        updatedAt: Date(timeIntervalSince1970: 0)
    )
}

private func require(_ condition: @autoclosure () -> Bool, _ message: String) {
    guard condition() else {
        fputs("FAIL: \(message)\n", stderr)
        exit(1)
    }
}

let fullRanking = [
    makeStore(id: "a", rank: .rank1),
    makeStore(id: "b", rank: .rank2),
    makeStore(id: "c", rank: .rank3),
    makeStore(id: "d", rank: .rank4),
    makeStore(id: "e", rank: .rank5)
]

let inserted = makeStore(id: "x", rank: .rank3)
let insertedResult = RankingEngine.upsertStore(stores: fullRanking, incomingStore: inserted)
require(insertedResult.first { $0.id == "x" }?.rank == .rank3, "inserted store must occupy rank 3")
require(insertedResult.first { $0.id == "c" }?.rank == .rank4, "old rank 3 must move to rank 4")
require(insertedResult.first { $0.id == "d" }?.rank == .rank5, "old rank 4 must move to rank 5")
require(insertedResult.first { $0.id == "e" }?.rank == .archive, "old rank 5 must move to archive")
require(insertedResult.first { $0.id == "e" }?.previousRank == 5, "archived old rank 5 must remember previous rank")

let deletedResult = RankingEngine.deleteStore(stores: fullRanking, storeId: "c")
require(deletedResult.first { $0.rank == .rank3 } == nil, "deleting rank 3 must leave it empty")
require(deletedResult.first { $0.id == "d" }?.rank == .rank4, "deleting must not compact later ranks")

let archivedResult = RankingEngine.moveStoreToArchive(
    stores: fullRanking,
    storeId: "b",
    updatedAt: Date()
)
require(archivedResult.first { $0.id == "b" }?.rank == .archive, "archive action must move store")
require(archivedResult.first { $0.id == "b" }?.previousRank == 2, "archive action must remember rank")
require(archivedResult.first { $0.id == "c" }?.rank == .rank3, "archive action must not compact ranks")

let threeArchives = (1...3).map { makeStore(id: "archive-\($0)", rank: .archive) }
require(
    !ProAccessPolicy.canAddArchive(
        stores: threeArchives,
        mainGenreId: "main-a",
        subGenreId: "sub-a",
        isPro: false
    ),
    "free users must be blocked at three archives in the same category"
)
require(
    ProAccessPolicy.canAddArchive(
        stores: threeArchives,
        mainGenreId: "main-a",
        subGenreId: "sub-b",
        isPro: false
    ),
    "archive limit must be scoped per category"
)
require(
    ProAccessPolicy.canAddArchive(
        stores: threeArchives,
        mainGenreId: "main-a",
        subGenreId: "sub-a",
        isPro: true
    ),
    "Pro users must have unlimited archives"
)

print("Core logic tests passed")
