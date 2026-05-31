import { useMemo } from "react";
import { initialMainGenres, initialSubGenres } from "../data/initialGenres";
import { deleteStoreById, moveStoreToArchive, upsertStoreWithRanking } from "../lib/ranking";
import { STORAGE_KEYS } from "../lib/storage";
import type { MainGenre, Store, StorePayload, SubGenre } from "../types";
import { useLocalStorage } from "./useLocalStorage";

const MAIN_GENRE_DELETE_MESSAGE =
  "このジャンルには登録済みの店舗があります。\n先に登録データを別ジャンルへ変更してください。";

const SUB_GENRE_DELETE_MESSAGE =
  "この種類には登録済みの店舗があります。\n先に登録データを別の種類へ変更してください。";

type MutationResult = {
  ok: boolean;
  message?: string;
};

function now() {
  return new Date().toISOString();
}

function createId(prefix: string) {
  if (globalThis.crypto?.randomUUID) {
    return `${prefix}-${globalThis.crypto.randomUUID()}`;
  }

  return `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2)}`;
}

function cleanOptional(value?: string) {
  const trimmed = value?.trim() ?? "";
  return trimmed.length > 0 ? trimmed : undefined;
}

function sortByOrder<T extends { sortOrder: number; name: string }>(items: T[]) {
  return [...items].sort((a, b) => a.sortOrder - b.sortOrder || a.name.localeCompare(b.name));
}

function swapSortOrder<T extends { id: string; sortOrder: number; updatedAt: string }>(
  items: T[],
  itemId: string,
  direction: "up" | "down",
  timestamp: string,
) {
  const sortedItems = [...items].sort((a, b) => a.sortOrder - b.sortOrder);
  const currentIndex = sortedItems.findIndex((item) => item.id === itemId);
  const targetIndex = direction === "up" ? currentIndex - 1 : currentIndex + 1;

  if (currentIndex < 0 || targetIndex < 0 || targetIndex >= sortedItems.length) {
    return items;
  }

  const currentItem = sortedItems[currentIndex];
  const targetItem = sortedItems[targetIndex];

  return items.map((item) => {
    if (item.id === currentItem.id) {
      return { ...item, sortOrder: targetItem.sortOrder, updatedAt: timestamp };
    }

    if (item.id === targetItem.id) {
      return { ...item, sortOrder: currentItem.sortOrder, updatedAt: timestamp };
    }

    return item;
  });
}

export function useRankingStore() {
  const [stores, setStores] = useLocalStorage<Store[]>(STORAGE_KEYS.stores, []);
  const [mainGenres, setMainGenres] = useLocalStorage<MainGenre[]>(
    STORAGE_KEYS.mainGenres,
    initialMainGenres,
  );
  const [subGenres, setSubGenres] = useLocalStorage<SubGenre[]>(
    STORAGE_KEYS.subGenres,
    initialSubGenres,
  );

  const sortedMainGenres = useMemo(() => sortByOrder(mainGenres), [mainGenres]);

  const sortedSubGenres = useMemo(() => {
    const mainOrder = new Map(sortedMainGenres.map((genre) => [genre.id, genre.sortOrder]));
    return [...subGenres].sort((a, b) => {
      const mainDiff = (mainOrder.get(a.mainGenreId) ?? 999) - (mainOrder.get(b.mainGenreId) ?? 999);
      return mainDiff || a.sortOrder - b.sortOrder || a.name.localeCompare(b.name);
    });
  }, [sortedMainGenres, subGenres]);

  const getSubGenresForMain = (mainGenreId: string) =>
    sortedSubGenres.filter((subGenre) => subGenre.mainGenreId === mainGenreId);

  const saveStore = (payload: StorePayload, storeId?: string) => {
    const timestamp = now();

    setStores((currentStores) => {
      const existingStore = storeId
        ? currentStores.find((store) => store.id === storeId)
        : undefined;

      const store: Store = {
        id: existingStore?.id ?? createId("store"),
        name: payload.name.trim(),
        mainGenreId: payload.mainGenreId,
        subGenreId: payload.subGenreId,
        rank: payload.rank,
        previousRank: payload.rank === "archive" ? (existingStore?.previousRank ?? null) : null,
        area: cleanOptional(payload.area),
        memo: cleanOptional(payload.memo),
        imageUrl: cleanOptional(payload.imageUrl),
        mapUrl: cleanOptional(payload.mapUrl),
        createdAt: existingStore?.createdAt ?? timestamp,
        updatedAt: timestamp,
      };

      return upsertStoreWithRanking(currentStores, store);
    });
  };

  const archiveStore = (storeId: string) => {
    setStores((currentStores) => moveStoreToArchive(currentStores, storeId, now()));
  };

  const deleteStore = (storeId: string) => {
    setStores((currentStores) => deleteStoreById(currentStores, storeId));
  };

  const addMainGenre = (name: string): MutationResult => {
    const trimmedName = name.trim();
    if (!trimmedName) {
      return { ok: false, message: "ジャンル名を入力してください。" };
    }

    const timestamp = now();
    setMainGenres((currentGenres) => [
      ...currentGenres,
      {
        id: createId("main"),
        name: trimmedName,
        sortOrder: Math.max(-1, ...currentGenres.map((genre) => genre.sortOrder)) + 1,
        createdAt: timestamp,
        updatedAt: timestamp,
      },
    ]);

    return { ok: true };
  };

  const updateMainGenre = (genreId: string, name: string): MutationResult => {
    const trimmedName = name.trim();
    if (!trimmedName) {
      return { ok: false, message: "ジャンル名を入力してください。" };
    }

    const timestamp = now();
    setMainGenres((currentGenres) =>
      currentGenres.map((genre) =>
        genre.id === genreId ? { ...genre, name: trimmedName, updatedAt: timestamp } : genre,
      ),
    );

    return { ok: true };
  };

  const deleteMainGenre = (genreId: string): MutationResult => {
    const subGenreIds = subGenres
      .filter((subGenre) => subGenre.mainGenreId === genreId)
      .map((subGenre) => subGenre.id);
    const hasStores = stores.some(
      (store) => store.mainGenreId === genreId || subGenreIds.includes(store.subGenreId),
    );

    if (hasStores) {
      return { ok: false, message: MAIN_GENRE_DELETE_MESSAGE };
    }

    setMainGenres((currentGenres) => currentGenres.filter((genre) => genre.id !== genreId));
    setSubGenres((currentSubGenres) =>
      currentSubGenres.filter((subGenre) => subGenre.mainGenreId !== genreId),
    );

    return { ok: true };
  };

  const moveMainGenre = (genreId: string, direction: "up" | "down") => {
    setMainGenres((currentGenres) => swapSortOrder(currentGenres, genreId, direction, now()));
  };

  const addSubGenre = (mainGenreId: string, name: string): MutationResult => {
    const trimmedName = name.trim();
    if (!trimmedName) {
      return { ok: false, message: "種類名を入力してください。" };
    }

    const timestamp = now();
    setSubGenres((currentSubGenres) => {
      const sameMainSubGenres = currentSubGenres.filter(
        (subGenre) => subGenre.mainGenreId === mainGenreId,
      );

      return [
        ...currentSubGenres,
        {
          id: createId("sub"),
          mainGenreId,
          name: trimmedName,
          sortOrder: Math.max(-1, ...sameMainSubGenres.map((subGenre) => subGenre.sortOrder)) + 1,
          createdAt: timestamp,
          updatedAt: timestamp,
        },
      ];
    });

    return { ok: true };
  };

  const updateSubGenre = (
    subGenreId: string,
    values: { name: string; mainGenreId: string },
  ): MutationResult => {
    const trimmedName = values.name.trim();
    if (!trimmedName) {
      return { ok: false, message: "種類名を入力してください。" };
    }

    const existingSubGenre = subGenres.find((subGenre) => subGenre.id === subGenreId);
    if (!existingSubGenre) {
      return { ok: false, message: "種類が見つかりません。" };
    }

    const timestamp = now();
    const isMovingMainGenre = existingSubGenre.mainGenreId !== values.mainGenreId;
    const nextSortOrder = isMovingMainGenre
      ? Math.max(
          -1,
          ...subGenres
            .filter((subGenre) => subGenre.mainGenreId === values.mainGenreId)
            .map((subGenre) => subGenre.sortOrder),
        ) + 1
      : existingSubGenre.sortOrder;

    setSubGenres((currentSubGenres) =>
      currentSubGenres.map((subGenre) =>
        subGenre.id === subGenreId
          ? {
              ...subGenre,
              mainGenreId: values.mainGenreId,
              name: trimmedName,
              sortOrder: nextSortOrder,
              updatedAt: timestamp,
            }
          : subGenre,
      ),
    );

    if (isMovingMainGenre) {
      setStores((currentStores) =>
        currentStores.map((store) =>
          store.subGenreId === subGenreId
            ? { ...store, mainGenreId: values.mainGenreId, updatedAt: timestamp }
            : store,
        ),
      );
    }

    return { ok: true };
  };

  const deleteSubGenre = (subGenreId: string): MutationResult => {
    const hasStores = stores.some((store) => store.subGenreId === subGenreId);

    if (hasStores) {
      return { ok: false, message: SUB_GENRE_DELETE_MESSAGE };
    }

    setSubGenres((currentSubGenres) =>
      currentSubGenres.filter((subGenre) => subGenre.id !== subGenreId),
    );

    return { ok: true };
  };

  const moveSubGenre = (subGenreId: string, direction: "up" | "down") => {
    const targetSubGenre = subGenres.find((subGenre) => subGenre.id === subGenreId);
    if (!targetSubGenre) {
      return;
    }

    setSubGenres((currentSubGenres) => {
      const sameMainSubGenres = currentSubGenres.filter(
        (subGenre) => subGenre.mainGenreId === targetSubGenre.mainGenreId,
      );
      const swappedSubGenres = swapSortOrder(sameMainSubGenres, subGenreId, direction, now());
      const swappedById = new Map(swappedSubGenres.map((subGenre) => [subGenre.id, subGenre]));

      return currentSubGenres.map((subGenre) => swappedById.get(subGenre.id) ?? subGenre);
    });
  };

  return {
    stores,
    mainGenres: sortedMainGenres,
    subGenres: sortedSubGenres,
    getSubGenresForMain,
    saveStore,
    archiveStore,
    deleteStore,
    addMainGenre,
    updateMainGenre,
    deleteMainGenre,
    moveMainGenre,
    addSubGenre,
    updateSubGenre,
    deleteSubGenre,
    moveSubGenre,
  };
}
