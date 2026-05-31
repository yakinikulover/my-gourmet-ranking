import type { Store } from "../types";
import { StoreCard } from "./StoreCard";

type ArchiveListProps = {
  stores: Store[];
  onStoreClick: (store: Store) => void;
};

export function ArchiveList({ stores, onStoreClick }: ArchiveListProps) {
  return (
    <section className="space-y-3" aria-label="Archive">
      {stores.length === 0 ? (
        <div className="rounded-lg border border-neutral-200 bg-white p-5 text-sm text-neutral-500">
          Archiveの店舗はまだありません。
        </div>
      ) : (
        stores.map((store) => (
          <StoreCard
            key={store.id}
            store={store}
            variant="archive"
            onClick={() => onStoreClick(store)}
          />
        ))
      )}
    </section>
  );
}
