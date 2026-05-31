import type { BestRankRow, NumericRank, Store } from "../types";
import { StoreCard } from "./StoreCard";

type RankingListProps = {
  rows: BestRankRow[];
  onStoreClick: (store: Store) => void;
  onTbdClick: (rank: NumericRank) => void;
};

export function RankingList({ rows, onStoreClick, onTbdClick }: RankingListProps) {
  return (
    <section className="space-y-3" aria-label="Best5">
      {rows.map((row) =>
        row.type === "store" ? (
          <StoreCard
            key={row.rank}
            store={row.store}
            rank={row.rank}
            onClick={() => onStoreClick(row.store)}
          />
        ) : (
          <StoreCard key={row.rank} rank={row.rank} onClick={() => onTbdClick(row.rank)} />
        ),
      )}
    </section>
  );
}
