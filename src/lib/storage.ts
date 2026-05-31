export const STORAGE_KEYS = {
  stores: "my-gourmet-ranking:stores",
  mainGenres: "my-gourmet-ranking:mainGenres",
  subGenres: "my-gourmet-ranking:subGenres",
} as const;

export function readStorage<T>(key: string): T | null {
  if (typeof window === "undefined") {
    return null;
  }

  const raw = window.localStorage.getItem(key);
  if (!raw) {
    return null;
  }

  try {
    return JSON.parse(raw) as T;
  } catch {
    return null;
  }
}

export function writeStorage<T>(key: string, value: T) {
  if (typeof window === "undefined") {
    return;
  }

  window.localStorage.setItem(key, JSON.stringify(value));
}
