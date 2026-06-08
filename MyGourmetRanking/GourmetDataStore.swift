import Foundation
import SwiftUI

@MainActor
final class GourmetDataStore: ObservableObject {
    @Published private(set) var stores: [Store] {
        didSet { save(stores, key: StorageKey.stores) }
    }

    @Published private(set) var mainGenres: [MainGenre] {
        didSet { save(mainGenres, key: StorageKey.mainGenres) }
    }

    @Published private(set) var subGenres: [SubGenre] {
        didSet { save(subGenres, key: StorageKey.subGenres) }
    }

    private enum StorageKey {
        static let stores = "my-gourmet-ranking.stores"
        static let mainGenres = "my-gourmet-ranking.main-genres"
        static let subGenres = "my-gourmet-ranking.sub-genres"
        static let taxonomyVersion = "my-gourmet-ranking.taxonomy-version"
    }

    init() {
        stores = Self.load([Store].self, key: StorageKey.stores) ?? InitialGenres.sampleStores
        mainGenres = Self.load([MainGenre].self, key: StorageKey.mainGenres) ?? InitialGenres.mainGenres
        subGenres = Self.load([SubGenre].self, key: StorageKey.subGenres) ?? InitialGenres.subGenres
        migrateTaxonomyIfNeeded()
    }

    var sortedMainGenres: [MainGenre] {
        mainGenres.sorted { lhs, rhs in
            lhs.sortOrder == rhs.sortOrder ? lhs.name < rhs.name : lhs.sortOrder < rhs.sortOrder
        }
    }

    var sortedSubGenres: [SubGenre] {
        let mainOrder = Dictionary(uniqueKeysWithValues: sortedMainGenres.map { ($0.id, $0.sortOrder) })
        return subGenres.sorted { lhs, rhs in
            let mainDiff = (mainOrder[lhs.mainGenreId] ?? 999) - (mainOrder[rhs.mainGenreId] ?? 999)
            if mainDiff != 0 {
                return mainDiff < 0
            }
            return lhs.sortOrder == rhs.sortOrder ? lhs.name < rhs.name : lhs.sortOrder < rhs.sortOrder
        }
    }

    func subGenres(for mainGenreId: String) -> [SubGenre] {
        sortedSubGenres.filter { $0.mainGenreId == mainGenreId }
    }

    func mainGenreName(for id: String) -> String {
        mainGenres.first { $0.id == id }?.name ?? "未設定"
    }

    func subGenreName(for id: String) -> String {
        subGenres.first { $0.id == id }?.name ?? "未設定"
    }

    func saveStore(_ formData: StoreFormData, editingStoreId: String? = nil) {
        let timestamp = Date()
        let existingStore = editingStoreId.flatMap { id in stores.first { $0.id == id } }
        let store = Store(
            id: existingStore?.id ?? "store-\(UUID().uuidString)",
            name: formData.name.trimmingCharacters(in: .whitespacesAndNewlines),
            mainGenreId: formData.mainGenreId,
            subGenreId: formData.subGenreId,
            rank: formData.rank,
            previousRank: formData.rank == .archive ? existingStore?.previousRank : nil,
            area: normalizedOptional(formData.area),
            memo: normalizedOptional(formData.memo),
            imageUrl: normalizedOptional(formData.imageUrl),
            imageFileNames: formData.imageFileNames.isEmpty ? nil : formData.imageFileNames,
            mapUrl: normalizedOptional(formData.mapUrl),
            latitude: formData.latitude,
            longitude: formData.longitude,
            createdAt: existingStore?.createdAt ?? timestamp,
            updatedAt: timestamp
        )
        let removedImageFileNames = (existingStore?.imageFileNames ?? []).filter { fileName in
            !formData.imageFileNames.contains(fileName)
        }
        stores = RankingEngine.upsertStore(stores: stores, incomingStore: store)
        ImageStorage.deleteImages(removedImageFileNames)
    }

    func archiveStore(_ storeId: String) {
        stores = RankingEngine.moveStoreToArchive(stores: stores, storeId: storeId, updatedAt: Date())
    }

    func deleteStore(_ storeId: String) {
        let imageFileNames = stores.first { $0.id == storeId }?.imageFileNames ?? []
        stores = RankingEngine.deleteStore(stores: stores, storeId: storeId)
        ImageStorage.deleteImages(imageFileNames)
    }

    func updateStoreLocation(_ storeId: String, candidate: LocationSearchCandidate, renameToCandidate: Bool = false) {
        guard let index = stores.firstIndex(where: { $0.id == storeId }) else { return }
        if renameToCandidate {
            stores[index].name = candidate.name
        }
        stores[index].latitude = candidate.coordinate.latitude
        stores[index].longitude = candidate.coordinate.longitude
        if stores[index].area?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            stores[index].area = candidate.area
        }
        stores[index].mapUrl = "https://maps.apple.com/?ll=\(candidate.coordinate.latitude),\(candidate.coordinate.longitude)&q=\(candidate.encodedName)"
        stores[index].updatedAt = Date()
    }

    @discardableResult
    func addMainGenre(name: String) -> String? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return "ジャンル名を入力してください。"
        }

        let timestamp = Date()
        let nextSortOrder = (mainGenres.map(\.sortOrder).max() ?? -1) + 1
        mainGenres.append(
            MainGenre(
                id: "main-\(UUID().uuidString)",
                name: trimmedName,
                sortOrder: nextSortOrder,
                createdAt: timestamp,
                updatedAt: timestamp
            )
        )
        return nil
    }

    @discardableResult
    func updateMainGenre(id: String, name: String) -> String? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return "ジャンル名を入力してください。"
        }

        updateMainGenres { genre in
            guard genre.id == id else {
                return genre
            }
            var updatedGenre = genre
            updatedGenre.name = trimmedName
            updatedGenre.updatedAt = Date()
            return updatedGenre
        }
        return nil
    }

    @discardableResult
    func deleteMainGenre(id: String) -> String? {
        let childSubGenreIds = subGenres.filter { $0.mainGenreId == id }.map(\.id)
        let hasStores = stores.contains { store in
            store.mainGenreId == id || childSubGenreIds.contains(store.subGenreId)
        }
        guard !hasStores else {
            return "このジャンルには登録済みの店舗があります。\n先に登録データを別ジャンルへ変更してください。"
        }

        mainGenres.removeAll { $0.id == id }
        subGenres.removeAll { $0.mainGenreId == id }
        return nil
    }

    func moveMainGenre(id: String, direction: MoveDirection) {
        mainGenres = swappedSortOrder(items: mainGenres, id: id, direction: direction)
    }

    @discardableResult
    func addSubGenre(mainGenreId: String, name: String) -> String? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return "種類名を入力してください。"
        }

        let timestamp = Date()
        let sameMainSubGenres = subGenres.filter { $0.mainGenreId == mainGenreId }
        let nextSortOrder = (sameMainSubGenres.map(\.sortOrder).max() ?? -1) + 1
        subGenres.append(
            SubGenre(
                id: "sub-\(UUID().uuidString)",
                mainGenreId: mainGenreId,
                name: trimmedName,
                sortOrder: nextSortOrder,
                createdAt: timestamp,
                updatedAt: timestamp
            )
        )
        return nil
    }

    @discardableResult
    func updateSubGenre(id: String, name: String, mainGenreId: String) -> String? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return "種類名を入力してください。"
        }

        guard let existingSubGenre = subGenres.first(where: { $0.id == id }) else {
            return "種類が見つかりません。"
        }

        let isMovingMainGenre = existingSubGenre.mainGenreId != mainGenreId
        let nextSortOrder = isMovingMainGenre
            ? (subGenres.filter { $0.mainGenreId == mainGenreId }.map(\.sortOrder).max() ?? -1) + 1
            : existingSubGenre.sortOrder
        let timestamp = Date()

        subGenres = subGenres.map { subGenre in
            guard subGenre.id == id else {
                return subGenre
            }
            var updatedSubGenre = subGenre
            updatedSubGenre.mainGenreId = mainGenreId
            updatedSubGenre.name = trimmedName
            updatedSubGenre.sortOrder = nextSortOrder
            updatedSubGenre.updatedAt = timestamp
            return updatedSubGenre
        }

        if isMovingMainGenre {
            stores = stores.map { store in
                guard store.subGenreId == id else {
                    return store
                }
                var updatedStore = store
                updatedStore.mainGenreId = mainGenreId
                updatedStore.updatedAt = timestamp
                return updatedStore
            }
        }
        return nil
    }

    @discardableResult
    func deleteSubGenre(id: String) -> String? {
        let hasStores = stores.contains { $0.subGenreId == id }
        guard !hasStores else {
            return "この種類には登録済みの店舗があります。\n先に登録データを別の種類へ変更してください。"
        }

        subGenres.removeAll { $0.id == id }
        return nil
    }

    func moveSubGenre(id: String, direction: MoveDirection) {
        guard let targetSubGenre = subGenres.first(where: { $0.id == id }) else {
            return
        }

        let sameMainSubGenres = subGenres.filter { $0.mainGenreId == targetSubGenre.mainGenreId }
        let swappedSubGenres = swappedSortOrder(items: sameMainSubGenres, id: id, direction: direction)
        let swappedById = Dictionary(uniqueKeysWithValues: swappedSubGenres.map { ($0.id, $0) })
        subGenres = subGenres.map { swappedById[$0.id] ?? $0 }
    }

    private func migrateTaxonomyIfNeeded() {
        let currentVersion = UserDefaults.standard.integer(forKey: StorageKey.taxonomyVersion)
        guard currentVersion < 2 else {
            return
        }

        let timestamp = Date()
        let legacySubGenreMoves: [String: (mainGenreId: String, subGenreId: String)] = [
            "japanese-2": ("sushi-seafood", "sushi-seafood-2"),
            "japanese-3": ("sushi-seafood", "sushi-seafood-4"),
            "japanese-4": ("japanese", "japanese-5"),
            "japanese-5": ("japanese", "japanese-4"),
            "japanese-6": ("setmeal-don", "setmeal-don-8"),
            "japanese-7": ("setmeal-don", "setmeal-don-10"),
            "japanese-9": ("ramen", "ramen-10"),
            "japanese-10": ("ramen", "ramen-11"),
            "japanese-11": ("japanese", "japanese-3"),
            "japanese-12": ("japanese", "japanese-7"),
            "japanese-13": ("japanese", "japanese-6"),
            "western-5": ("curry-ethnic", "curry-ethnic-2"),
            "western-6": ("meat", "meat-6"),
            "western-7": ("western", "western-6"),
            "western-8": ("western", "western-7"),
            "western-9": ("western", "western-8"),
            "western-10": ("western", "western-9"),
            "western-11": ("western", "western-10"),
            "meat-6": ("yakitori-kushi", "yakitori-kushi-2"),
            "meat-7": ("yakitori-kushi", "yakitori-kushi-3"),
            "meat-8": ("meat", "meat-7"),
            "ramen-2": ("ramen", "ramen-3"),
            "ramen-3": ("ramen", "ramen-4"),
            "ramen-4": ("ramen", "ramen-5"),
            "ramen-5": ("ramen", "ramen-6"),
            "ramen-6": ("ramen", "ramen-7"),
            "ramen-7": ("ramen", "ramen-13"),
            "fast-light-5": ("fast-light", "fast-light-7"),
            "fast-light-6": ("fast-light", "fast-light-13"),
            "fast-light-7": ("setmeal-don", "setmeal-don-12"),
            "fast-light-8": ("setmeal-don", "setmeal-don-13"),
            "fast-light-9": ("fast-light", "fast-light-5"),
            "fast-light-10": ("fast-light", "fast-light-6"),
            "konamono-2": ("fast-light", "fast-light-8"),
            "konamono-3": ("fast-light", "fast-light-9"),
            "konamono-4": ("fast-light", "fast-light-10"),
            "konamono-5": ("ramen", "ramen-12"),
            "konamono-6": ("fast-light", "fast-light-9"),
            "curry-ethnic-5": ("curry-ethnic", "curry-ethnic-6"),
            "curry-ethnic-6": ("curry-ethnic", "curry-ethnic-7"),
            "curry-ethnic-7": ("curry-ethnic", "curry-ethnic-8")
        ]

        stores = stores.map { store in
            guard let move = legacySubGenreMoves[store.subGenreId] else {
                return store
            }
            var updatedStore = store
            updatedStore.mainGenreId = move.mainGenreId
            updatedStore.subGenreId = move.subGenreId
            updatedStore.updatedAt = timestamp
            return updatedStore
        }

        let storeMainGenreIds = Set(stores.map(\.mainGenreId))
        let storeSubGenreIds = Set(stores.map(\.subGenreId))
        var mergedMainGenres = mainGenres.filter { genre in
            if genre.id == "occasion" || genre.id == "konamono" {
                return storeMainGenreIds.contains(genre.id)
            }
            return true
        }

        for recommendedGenre in InitialGenres.mainGenres {
            if let index = mergedMainGenres.firstIndex(where: { $0.id == recommendedGenre.id }) {
                mergedMainGenres[index].name = recommendedGenre.name
                mergedMainGenres[index].sortOrder = recommendedGenre.sortOrder
                mergedMainGenres[index].updatedAt = timestamp
            } else {
                mergedMainGenres.append(recommendedGenre)
            }
        }
        mainGenres = mergedMainGenres

        var mergedSubGenres = subGenres.filter { subGenre in
            if subGenre.mainGenreId == "occasion" || subGenre.mainGenreId == "konamono" {
                return storeSubGenreIds.contains(subGenre.id)
            }
            return true
        }

        for recommendedSubGenre in InitialGenres.subGenres {
            if let index = mergedSubGenres.firstIndex(where: { $0.id == recommendedSubGenre.id }) {
                mergedSubGenres[index].mainGenreId = recommendedSubGenre.mainGenreId
                mergedSubGenres[index].name = recommendedSubGenre.name
                mergedSubGenres[index].sortOrder = recommendedSubGenre.sortOrder
                mergedSubGenres[index].updatedAt = timestamp
            } else {
                mergedSubGenres.append(recommendedSubGenre)
            }
        }
        subGenres = mergedSubGenres

        let subGenreMainById = Dictionary(uniqueKeysWithValues: subGenres.map { ($0.id, $0.mainGenreId) })
        stores = stores.map { store in
            guard let mainGenreId = subGenreMainById[store.subGenreId], mainGenreId != store.mainGenreId else {
                return store
            }
            var updatedStore = store
            updatedStore.mainGenreId = mainGenreId
            updatedStore.updatedAt = timestamp
            return updatedStore
        }

        UserDefaults.standard.set(2, forKey: StorageKey.taxonomyVersion)
    }

    private func normalizedOptional(_ value: String) -> String? {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }

    private func updateMainGenres(_ transform: (MainGenre) -> MainGenre) {
        mainGenres = mainGenres.map(transform)
    }

    private func swappedSortOrder<T: Identifiable & SortableGenre>(
        items: [T],
        id: String,
        direction: MoveDirection
    ) -> [T] where T.ID == String {
        let sortedItems = items.sorted { $0.sortOrder < $1.sortOrder }
        guard let currentIndex = sortedItems.firstIndex(where: { $0.id == id }) else {
            return items
        }

        let targetIndex = direction == .up ? currentIndex - 1 : currentIndex + 1
        guard sortedItems.indices.contains(targetIndex) else {
            return items
        }

        let currentItem = sortedItems[currentIndex]
        let targetItem = sortedItems[targetIndex]
        let timestamp = Date()

        return items.map { item in
            var updatedItem = item
            if item.id == currentItem.id {
                updatedItem.sortOrder = targetItem.sortOrder
                updatedItem.updatedAt = timestamp
            } else if item.id == targetItem.id {
                updatedItem.sortOrder = currentItem.sortOrder
                updatedItem.updatedAt = timestamp
            }
            return updatedItem
        }
    }

    private static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else {
            return
        }
        UserDefaults.standard.set(data, forKey: key)
    }
}

enum MoveDirection {
    case up
    case down
}

protocol SortableGenre {
    var sortOrder: Int { get set }
    var updatedAt: Date { get set }
}

extension MainGenre: SortableGenre {}
extension SubGenre: SortableGenre {}
