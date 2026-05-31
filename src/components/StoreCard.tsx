import { formatRank } from "../lib/ranking";
import type { NumericRank, Store } from "../types";

type StoreCardProps = {
  store?: Store;
  rank?: NumericRank;
  variant?: "best" | "archive" | "compact";
  onClick?: () => void;
};

function StoreImage({ store }: { store: Store }) {
  if (!store.imageUrl) {
    return (
      <div className="flex h-20 w-20 shrink-0 items-center justify-center rounded-lg bg-neutral-200 text-xs font-semibold text-neutral-500">
        No image
      </div>
    );
  }

  return (
    <img
      src={store.imageUrl}
      alt={store.name}
      className="h-20 w-20 shrink-0 rounded-lg object-cover"
      loading="lazy"
    />
  );
}

export function StoreCard({ store, rank, variant = "best", onClick }: StoreCardProps) {
  if (!store) {
    return (
      <button
        type="button"
        onClick={onClick}
        className="flex w-full items-center gap-4 rounded-lg border border-dashed border-neutral-300 bg-white p-4 text-left transition hover:border-emerald-400 hover:bg-emerald-50"
      >
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-lg bg-neutral-100 text-sm font-bold text-neutral-700">
          {rank}位
        </div>
        <div>
          <p className="text-lg font-bold text-neutral-700">TBD</p>
          <p className="text-sm text-neutral-500">この順位に店舗を登録</p>
        </div>
      </button>
    );
  }

  const isArchive = variant === "archive";
  const rankLabel = isArchive
    ? store.previousRank
      ? `元${store.previousRank}位`
      : "未ランクイン"
    : rank
      ? `${rank}位`
      : formatRank(store.rank);

  return (
    <button
      type="button"
      onClick={onClick}
      className={[
        "flex w-full items-center gap-4 rounded-lg border bg-white p-4 text-left transition hover:-translate-y-0.5 hover:shadow-soft",
        isArchive ? "border-neutral-200 opacity-90" : "border-neutral-200",
        variant === "compact" ? "py-3" : "",
      ].join(" ")}
    >
      <StoreImage store={store} />
      <div className="min-w-0 flex-1">
        <div className="mb-1 flex flex-wrap items-center gap-2">
          <span
            className={[
              "rounded-full px-2.5 py-1 text-xs font-bold",
              isArchive ? "bg-neutral-100 text-neutral-600" : "bg-emerald-100 text-emerald-700",
            ].join(" ")}
          >
            {rankLabel}
          </span>
          <span className="text-sm text-neutral-500">{store.area || "エリア未登録"}</span>
        </div>
        <p className="truncate text-base font-bold text-neutral-950">{store.name}</p>
        <p className="mt-1 line-clamp-2 text-sm text-neutral-600">
          {store.memo || "メモ未登録"}
        </p>
      </div>
    </button>
  );
}
