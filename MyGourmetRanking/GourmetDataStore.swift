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
    }

    init() {
        stores = Self.load([Store].self, key: StorageKey.stores) ?? []
        mainGenres = Self.load([MainGenre].self, key: StorageKey.mainGenres) ?? InitialGenres.mainGenres
        subGenres = Self.load([SubGenre].self, key: StorageKey.subGenres) ?? InitialGenres.subGenres
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
            mapUrl: normalizedOptional(formData.mapUrl),
            createdAt: existingStore?.createdAt ?? timestamp,
            updatedAt: timestamp
        )
        stores = RankingEngine.upsertStore(stores: stores, incomingStore: store)
    }

    func archiveStore(_ storeId: String) {
        stores = RankingEngine.moveStoreToArchive(stores: stores, storeId: storeId, updatedAt: Date())
    }

    func deleteStore(_ storeId: String) {
        stores = RankingEngine.deleteStore(stores: stores, storeId: storeId)
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
