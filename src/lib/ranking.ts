import type { BestRankRow, NumericRank, Store } from "../types";

export const BEST_RANKS: NumericRank[] = [1, 2, 3, 4, 5];

export function isNumericRank(rank: Store["rank"]): rank is NumericRank {
  return rank !== "archive";
}

export function formatRank(rank: Store["rank"]) {
  return isNumericRank(rank) ? `${rank}位` : "Archive";
}

export function isSameCategory(store: Store, mainGenreId: string, subGenreId: string) {
  return store.mainGenreId === mainGenreId && store.subGenreId === subGenreId;
}

export function buildBestRows(
  stores: Store[],
  mainGenreId: string,
  subGenreId: string,
): BestRankRow[] {
  const rankedStores = new Map<NumericRank, Store>();

  stores.forEach((store) => {
    if (isSameCategory(store, mainGenreId, subGenreId) && isNumericRank(store.rank)) {
      rankedStores.set(store.rank, store);
    }
  });

  return BEST_RANKS.map((rank) => {
    const store = rankedStores.get(rank);
    return store ? { type: "store", rank, store } : { type: "tbd", rank };
  });
}

export function getArchiveStores(stores: Store[], mainGenreId: string, subGenreId: string) {
  return stores
    .filter((store) => isSameCategory(store, mainGenreId, subGenreId) && store.rank === "archive")
    .sort((a, b) => {
      const rankA = a.previousRank ?? 99;
      const rankB = b.previousRank ?? 99;
      if (rankA !== rankB) {
        return rankA - rankB;
      }
      return b.updatedAt.localeCompare(a.updatedAt);
    });
}

export function upsertStoreWithRanking(stores: Store[], incomingStore: Store): Store[] {
  const existingStore = stores.find((store) => store.id === incomingStore.id);
  const baseStores = stores.filter((store) => store.id !== incomingStore.id);

  if (incomingStore.rank === "archive") {
    const previousRank: NumericRank | null =
      existingStore && isNumericRank(existingStore.rank)
        ? existingStore.rank
        : (incomingStore.previousRank ?? null);

    return [
      ...baseStores,
      {
        ...incomingStore,
        rank: "archive",
        previousRank,
      },
    ];
  }

  const categoryRanks = new Map<NumericRank, Store>();
  const unaffectedStores: Store[] = [];

  baseStores.forEach((store) => {
    if (
      isSameCategory(store, incomingStore.mainGenreId, incomingStore.subGenreId) &&
      isNumericRank(store.rank)
    ) {
      categoryRanks.set(store.rank, store);
      return;
    }

    unaffectedStores.push(store);
  });

  const archivedStores: Store[] = [];
  let displacedStore = categoryRanks.get(incomingStore.rank);

  categoryRanks.set(incomingStore.rank, {
    ...incomingStore,
    previousRank: null,
  });

  for (let nextRank = (incomingStore.rank + 1) as NumericRank; nextRank <= 5; nextRank += 1) {
    if (!displacedStore) {
      break;
    }

    const nextDisplacedStore = categoryRanks.get(nextRank);
    categoryRanks.set(nextRank, {
      ...displacedStore,
      rank: nextRank,
      updatedAt: incomingStore.updatedAt,
    });
    displacedStore = nextDisplacedStore;
  }

  if (displacedStore) {
    archivedStores.push({
      ...displacedStore,
      rank: "archive",
      previousRank: 5,
      updatedAt: incomingStore.updatedAt,
    });
  }

  return [...unaffectedStores, ...Array.from(categoryRanks.values()), ...archivedStores];
}

export function moveStoreToArchive(stores: Store[], storeId: string, updatedAt: string): Store[] {
  return stores.map((store) => {
    if (store.id !== storeId) {
      return store;
    }

    return {
      ...store,
      rank: "archive",
      previousRank: isNumericRank(store.rank) ? store.rank : store.previousRank,
      updatedAt,
    };
  });
}

export function deleteStoreById(stores: Store[], storeId: string): Store[] {
  return stores.filter((store) => store.id !== storeId);
}
