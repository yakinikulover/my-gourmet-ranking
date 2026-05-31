export type NumericRank = 1 | 2 | 3 | 4 | 5;

export type StoreRank = NumericRank | "archive";

export type Store = {
  id: string;
  name: string;
  mainGenreId: string;
  subGenreId: string;
  rank: StoreRank;
  previousRank: NumericRank | null;
  area?: string;
  memo?: string;
  imageUrl?: string;
  mapUrl?: string;
  createdAt: string;
  updatedAt: string;
};

export type MainGenre = {
  id: string;
  name: string;
  sortOrder: number;
  createdAt: string;
  updatedAt: string;
};

export type SubGenre = {
  id: string;
  mainGenreId: string;
  name: string;
  sortOrder: number;
  createdAt: string;
  updatedAt: string;
};

export type StorePayload = {
  name: string;
  mainGenreId: string;
  subGenreId: string;
  rank: StoreRank;
  area?: string;
  memo?: string;
  imageUrl?: string;
  mapUrl?: string;
};

export type BestRankRow =
  | {
      type: "store";
      rank: NumericRank;
      store: Store;
    }
  | {
      type: "tbd";
      rank: NumericRank;
    };
