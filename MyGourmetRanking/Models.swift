import Foundation

enum StoreRank: String, CaseIterable, Codable, Identifiable, Hashable {
    case rank1 = "1"
    case rank2 = "2"
    case rank3 = "3"
    case rank4 = "4"
    case rank5 = "5"
    case archive

    var id: String { rawValue }

    var numericValue: Int? {
        switch self {
        case .rank1: 1
        case .rank2: 2
        case .rank3: 3
        case .rank4: 4
        case .rank5: 5
        case .archive: nil
        }
    }

    var label: String {
        numericValue.map { "\($0)位" } ?? "Archive"
    }

    static func ranked(_ value: Int) -> StoreRank {
        switch value {
        case 1: .rank1
        case 2: .rank2
        case 3: .rank3
        case 4: .rank4
        case 5: .rank5
        default: .archive
        }
    }
}

struct Store: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var mainGenreId: String
    var subGenreId: String
    var rank: StoreRank
    var previousRank: Int?
    var area: String?
    var memo: String?
    var imageUrl: String?
    var imageFileNames: [String]? = nil
    var mapUrl: String?
    var tagIds: [String]? = nil
    var createdAt: Date
    var updatedAt: Date
}

struct MainGenre: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var sortOrder: Int
    var createdAt: Date
    var updatedAt: Date
}

struct SubGenre: Identifiable, Codable, Equatable {
    var id: String
    var mainGenreId: String
    var name: String
    var sortOrder: Int
    var createdAt: Date
    var updatedAt: Date
}

struct OccasionTag: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var sortOrder: Int
    var createdAt: Date
    var updatedAt: Date
}

struct StoreFormData {
    var name: String
    var mainGenreId: String
    var subGenreId: String
    var rank: StoreRank
    var area: String
    var memo: String
    var imageUrl: String
    var imageFileNames: [String]
    var mapUrl: String
    var tagIds: [String]
}

enum BestRankRow: Identifiable {
    case store(rank: Int, store: Store)
    case tbd(rank: Int)

    var id: String {
        switch self {
        case .store(let rank, let store): "store-\(rank)-\(store.id)"
        case .tbd(let rank): "tbd-\(rank)"
        }
    }

    var rank: Int {
        switch self {
        case .store(let rank, _), .tbd(let rank): rank
        }
    }
}
