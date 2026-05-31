import { FormEvent, useEffect, useMemo, useState } from "react";
import { formatRank, isNumericRank } from "../lib/ranking";
import type { MainGenre, NumericRank, Store, StorePayload, StoreRank, SubGenre } from "../types";

const RANK_OPTIONS: StoreRank[] = [1, 2, 3, 4, 5, "archive"];

export type StoreModalMode = "create" | "detail" | "edit";

type StoreModalProps = {
  isOpen: boolean;
  mode: StoreModalMode;
  store?: Store | null;
  initialMainGenreId: string;
  initialSubGenreId: string;
  initialRank?: StoreRank;
  mainGenres: MainGenre[];
  subGenres: SubGenre[];
  onClose: () => void;
  onSave: (payload: StorePayload, storeId?: string) => void;
  onDelete: (storeId: string) => void;
  onMoveToArchive: (storeId: string) => void;
};

type FormState = {
  name: string;
  mainGenreId: string;
  subGenreId: string;
  rank: string;
  area: string;
  imageUrl: string;
  memo: string;
  mapUrl: string;
};

function rankToFormValue(rank: StoreRank) {
  return rank === "archive" ? "archive" : String(rank);
}

function parseRank(value: string): StoreRank | null {
  if (value === "archive") {
    return "archive";
  }

  const numericValue = Number(value);
  if ([1, 2, 3, 4, 5].includes(numericValue)) {
    return numericValue as NumericRank;
  }

  return null;
}

function labelForRank(rank: StoreRank) {
  return rank === "archive" ? "Archive" : `${rank}位`;
}

function FieldLabel({ children }: { children: React.ReactNode }) {
  return <span className="mb-1 block text-xs font-bold text-neutral-500">{children}</span>;
}

export function StoreModal({
  isOpen,
  mode,
  store,
  initialMainGenreId,
  initialSubGenreId,
  initialRank = "archive",
  mainGenres,
  subGenres,
  onClose,
  onSave,
  onDelete,
  onMoveToArchive,
}: StoreModalProps) {
  const [isEditing, setIsEditing] = useState(mode !== "detail");
  const [form, setForm] = useState<FormState>(() =>
    buildFormState(store, initialMainGenreId, initialSubGenreId, initialRank, mainGenres, subGenres),
  );
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    setIsEditing(mode !== "detail");
    setForm(
      buildFormState(
        store,
        initialMainGenreId,
        initialSubGenreId,
        initialRank,
        mainGenres,
        subGenres,
      ),
    );
    setErrorMessage("");
  }, [store, mode, initialMainGenreId, initialSubGenreId, initialRank, mainGenres, subGenres]);

  const availableSubGenres = useMemo(
    () => subGenres.filter((subGenre) => subGenre.mainGenreId === form.mainGenreId),
    [form.mainGenreId, subGenres],
  );

  useEffect(() => {
    if (!isEditing) {
      return;
    }

    const hasSelectedSubGenre = availableSubGenres.some(
      (subGenre) => subGenre.id === form.subGenreId,
    );

    if (availableSubGenres.length > 0 && !hasSelectedSubGenre) {
      setForm((currentForm) => ({ ...currentForm, subGenreId: availableSubGenres[0].id }));
    }

    if (availableSubGenres.length === 0 && form.subGenreId) {
      setForm((currentForm) => ({ ...currentForm, subGenreId: "" }));
    }
  }, [availableSubGenres, form.subGenreId, isEditing]);

  if (!isOpen) {
    return null;
  }

  const mainGenreName =
    mainGenres.find((genre) => genre.id === store?.mainGenreId)?.name ?? "未設定";
  const subGenreName =
    subGenres.find((subGenre) => subGenre.id === store?.subGenreId)?.name ?? "未設定";

  const handleMainGenreChange = (mainGenreId: string) => {
    const firstSubGenre = subGenres.find((subGenre) => subGenre.mainGenreId === mainGenreId);
    setForm((currentForm) => ({
      ...currentForm,
      mainGenreId,
      subGenreId: firstSubGenre?.id ?? "",
    }));
  };

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    const rank = parseRank(form.rank);
    if (!form.name.trim()) {
      setErrorMessage("店名を入力してください。");
      return;
    }

    if (!form.mainGenreId || !form.subGenreId) {
      setErrorMessage("大ジャンルと小ジャンルを選択してください。");
      return;
    }

    if (!rank) {
      setErrorMessage("順位を選択してください。");
      return;
    }

    onSave(
      {
        name: form.name,
        mainGenreId: form.mainGenreId,
        subGenreId: form.subGenreId,
        rank,
        area: form.area,
        memo: form.memo,
        imageUrl: form.imageUrl,
        mapUrl: form.mapUrl,
      },
      store?.id,
    );
    onClose();
  };

  const handleDelete = () => {
    if (!store) {
      return;
    }

    if (window.confirm(`${store.name}を削除しますか？`)) {
      onDelete(store.id);
      onClose();
    }
  };

  const handleArchive = () => {
    if (!store) {
      return;
    }

    if (window.confirm(`${store.name}をArchiveへ移動しますか？`)) {
      onMoveToArchive(store.id);
      onClose();
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-end justify-center bg-neutral-950/45 px-3 py-4 sm:items-center"
      role="dialog"
      aria-modal="true"
      onMouseDown={onClose}
    >
      <div
        className="max-h-[92vh] w-full max-w-2xl overflow-y-auto rounded-lg bg-white shadow-soft"
        onMouseDown={(event) => event.stopPropagation()}
      >
        <div className="sticky top-0 z-10 flex items-center justify-between border-b border-neutral-200 bg-white px-5 py-4">
          <div>
            <p className="text-xs font-bold uppercase tracking-wide text-emerald-700">
              {isEditing ? "Store Form" : "Store Detail"}
            </p>
            <h2 className="text-xl font-bold text-neutral-950">
              {isEditing ? (store ? "店舗を編集" : "店舗を登録") : store?.name}
            </h2>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="rounded-lg border border-neutral-200 px-3 py-2 text-sm font-bold text-neutral-600 hover:bg-neutral-100"
          >
            閉じる
          </button>
        </div>

        <div className="p-5">
          {isEditing ? (
            <form className="space-y-4" onSubmit={handleSubmit}>
              {errorMessage ? (
                <div className="rounded-lg border border-red-200 bg-red-50 p-3 text-sm font-semibold text-red-700">
                  {errorMessage}
                </div>
              ) : null}

              <label className="block">
                <FieldLabel>店名 必須</FieldLabel>
                <input
                  value={form.name}
                  onChange={(event) =>
                    setForm((currentForm) => ({ ...currentForm, name: event.target.value }))
                  }
                  className="w-full rounded-lg border border-neutral-300 px-3 py-2.5 text-sm"
                  placeholder="例：銀座 すき焼き店"
                />
              </label>

              <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
                <label className="block">
                  <FieldLabel>大ジャンル 必須</FieldLabel>
                  <select
                    value={form.mainGenreId}
                    onChange={(event) => handleMainGenreChange(event.target.value)}
                    className="w-full rounded-lg border border-neutral-300 bg-white px-3 py-2.5 text-sm"
                  >
                    {mainGenres.map((genre) => (
                      <option key={genre.id} value={genre.id}>
                        {genre.name}
                      </option>
                    ))}
                  </select>
                </label>

                <label className="block">
                  <FieldLabel>小ジャンル 必須</FieldLabel>
                  <select
                    value={form.subGenreId}
                    onChange={(event) =>
                      setForm((currentForm) => ({
                        ...currentForm,
                        subGenreId: event.target.value,
                      }))
                    }
                    disabled={availableSubGenres.length === 0}
                    className="w-full rounded-lg border border-neutral-300 bg-white px-3 py-2.5 text-sm disabled:bg-neutral-100"
                  >
                    {availableSubGenres.map((subGenre) => (
                      <option key={subGenre.id} value={subGenre.id}>
                        {subGenre.name}
                      </option>
                    ))}
                  </select>
                </label>
              </div>

              <label className="block">
                <FieldLabel>順位 必須</FieldLabel>
                <select
                  value={form.rank}
                  onChange={(event) =>
                    setForm((currentForm) => ({ ...currentForm, rank: event.target.value }))
                  }
                  className="w-full rounded-lg border border-neutral-300 bg-white px-3 py-2.5 text-sm"
                >
                  {RANK_OPTIONS.map((rank) => (
                    <option key={rank} value={rankToFormValue(rank)}>
                      {labelForRank(rank)}
                    </option>
                  ))}
                </select>
              </label>

              <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
                <label className="block">
                  <FieldLabel>エリア</FieldLabel>
                  <input
                    value={form.area}
                    onChange={(event) =>
                      setForm((currentForm) => ({ ...currentForm, area: event.target.value }))
                    }
                    className="w-full rounded-lg border border-neutral-300 px-3 py-2.5 text-sm"
                    placeholder="銀座、新宿など"
                  />
                </label>

                <label className="block">
                  <FieldLabel>サムネイル画像URL</FieldLabel>
                  <input
                    value={form.imageUrl}
                    onChange={(event) =>
                      setForm((currentForm) => ({ ...currentForm, imageUrl: event.target.value }))
                    }
                    className="w-full rounded-lg border border-neutral-300 px-3 py-2.5 text-sm"
                    placeholder="https://..."
                  />
                </label>
              </div>

              <label className="block">
                <FieldLabel>メモ</FieldLabel>
                <textarea
                  value={form.memo}
                  onChange={(event) =>
                    setForm((currentForm) => ({ ...currentForm, memo: event.target.value }))
                  }
                  rows={3}
                  className="w-full rounded-lg border border-neutral-300 px-3 py-2.5 text-sm"
                  placeholder="一言メモ"
                />
              </label>

              <label className="block">
                <FieldLabel>Google Map URL</FieldLabel>
                <input
                  value={form.mapUrl}
                  onChange={(event) =>
                    setForm((currentForm) => ({ ...currentForm, mapUrl: event.target.value }))
                  }
                  className="w-full rounded-lg border border-neutral-300 px-3 py-2.5 text-sm"
                  placeholder="https://maps.google.com/..."
                />
              </label>

              <div className="flex flex-col-reverse gap-3 border-t border-neutral-200 pt-4 sm:flex-row sm:justify-end">
                {store ? (
                  <button
                    type="button"
                    onClick={() => setIsEditing(false)}
                    className="rounded-lg border border-neutral-300 px-4 py-2.5 text-sm font-bold text-neutral-700 hover:bg-neutral-100"
                  >
                    詳細に戻る
                  </button>
                ) : null}
                <button
                  type="submit"
                  className="rounded-lg bg-emerald-600 px-5 py-2.5 text-sm font-bold text-white hover:bg-emerald-700"
                >
                  保存
                </button>
              </div>
            </form>
          ) : store ? (
            <div className="space-y-5">
              {store.imageUrl ? (
                <img
                  src={store.imageUrl}
                  alt={store.name}
                  className="h-56 w-full rounded-lg object-cover"
                />
              ) : (
                <div className="flex h-40 w-full items-center justify-center rounded-lg bg-neutral-200 text-sm font-bold text-neutral-500">
                  No image
                </div>
              )}

              <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
                <DetailItem label="大ジャンル" value={mainGenreName} />
                <DetailItem label="小ジャンル" value={subGenreName} />
                <DetailItem label="現在順位" value={formatRank(store.rank)} />
                <DetailItem
                  label="元順位"
                  value={store.previousRank ? `${store.previousRank}位` : "未ランクイン"}
                />
                <DetailItem label="エリア" value={store.area || "未登録"} />
                <DetailItem label="Google Map URL" value={store.mapUrl || "未登録"} isLink />
              </div>

              <div>
                <p className="mb-1 text-xs font-bold text-neutral-500">メモ</p>
                <p className="rounded-lg bg-neutral-50 p-3 text-sm leading-6 text-neutral-700">
                  {store.memo || "未登録"}
                </p>
              </div>

              <div className="grid grid-cols-1 gap-3 border-t border-neutral-200 pt-4 sm:grid-cols-3">
                <button
                  type="button"
                  onClick={() => setIsEditing(true)}
                  className="rounded-lg bg-neutral-900 px-4 py-2.5 text-sm font-bold text-white hover:bg-neutral-700"
                >
                  編集
                </button>
                <button
                  type="button"
                  onClick={handleArchive}
                  disabled={!isNumericRank(store.rank)}
                  className="rounded-lg border border-neutral-300 px-4 py-2.5 text-sm font-bold text-neutral-700 hover:bg-neutral-100 disabled:cursor-not-allowed disabled:opacity-45"
                >
                  Archiveへ移動
                </button>
                <button
                  type="button"
                  onClick={handleDelete}
                  className="rounded-lg border border-red-200 px-4 py-2.5 text-sm font-bold text-red-700 hover:bg-red-50"
                >
                  削除
                </button>
              </div>
            </div>
          ) : null}
        </div>
      </div>
    </div>
  );
}

function buildFormState(
  store: Store | null | undefined,
  initialMainGenreId: string,
  initialSubGenreId: string,
  initialRank: StoreRank,
  mainGenres: MainGenre[],
  subGenres: SubGenre[],
): FormState {
  const mainGenreId = store?.mainGenreId || initialMainGenreId || mainGenres[0]?.id || "";
  const subGenreId =
    store?.subGenreId ||
    initialSubGenreId ||
    subGenres.find((subGenre) => subGenre.mainGenreId === mainGenreId)?.id ||
    "";

  return {
    name: store?.name ?? "",
    mainGenreId,
    subGenreId,
    rank: rankToFormValue(store?.rank ?? initialRank),
    area: store?.area ?? "",
    imageUrl: store?.imageUrl ?? "",
    memo: store?.memo ?? "",
    mapUrl: store?.mapUrl ?? "",
  };
}

function DetailItem({
  label,
  value,
  isLink = false,
}: {
  label: string;
  value: string;
  isLink?: boolean;
}) {
  return (
    <div className="rounded-lg bg-neutral-50 p-3">
      <p className="mb-1 text-xs font-bold text-neutral-500">{label}</p>
      {isLink && value.startsWith("http") ? (
        <a
          href={value}
          target="_blank"
          rel="noreferrer"
          className="break-all text-sm font-semibold text-emerald-700 underline"
        >
          {value}
        </a>
      ) : (
        <p className="break-words text-sm font-semibold text-neutral-800">{value}</p>
      )}
    </div>
  );
}
