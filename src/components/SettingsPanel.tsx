import { useEffect, useMemo, useState } from "react";
import { formatRank, isNumericRank } from "../lib/ranking";
import type { MainGenre, Store, SubGenre } from "../types";

type MutationResult = {
  ok: boolean;
  message?: string;
};

type SettingsTab = "stores" | "mainGenres" | "subGenres";

type SettingsPanelProps = {
  stores: Store[];
  mainGenres: MainGenre[];
  subGenres: SubGenre[];
  onBack: () => void;
  onEditStore: (store: Store) => void;
  onDeleteStore: (storeId: string) => void;
  onArchiveStore: (storeId: string) => void;
  addMainGenre: (name: string) => MutationResult;
  updateMainGenre: (genreId: string, name: string) => MutationResult;
  deleteMainGenre: (genreId: string) => MutationResult;
  moveMainGenre: (genreId: string, direction: "up" | "down") => void;
  addSubGenre: (mainGenreId: string, name: string) => MutationResult;
  updateSubGenre: (
    subGenreId: string,
    values: { name: string; mainGenreId: string },
  ) => MutationResult;
  deleteSubGenre: (subGenreId: string) => MutationResult;
  moveSubGenre: (subGenreId: string, direction: "up" | "down") => void;
};

type SubGenreDraft = {
  name: string;
  mainGenreId: string;
};

export function SettingsPanel({
  stores,
  mainGenres,
  subGenres,
  onBack,
  onEditStore,
  onDeleteStore,
  onArchiveStore,
  addMainGenre,
  updateMainGenre,
  deleteMainGenre,
  moveMainGenre,
  addSubGenre,
  updateSubGenre,
  deleteSubGenre,
  moveSubGenre,
}: SettingsPanelProps) {
  const [activeTab, setActiveTab] = useState<SettingsTab>("stores");
  const [feedbackMessage, setFeedbackMessage] = useState("");

  const [searchText, setSearchText] = useState("");
  const [mainGenreFilter, setMainGenreFilter] = useState("");
  const [subGenreFilter, setSubGenreFilter] = useState("");
  const [rankFilter, setRankFilter] = useState("");

  const [newMainGenreName, setNewMainGenreName] = useState("");
  const [mainGenreDrafts, setMainGenreDrafts] = useState<Record<string, string>>({});

  const [newSubGenreName, setNewSubGenreName] = useState("");
  const [newSubGenreMainId, setNewSubGenreMainId] = useState(mainGenres[0]?.id ?? "");
  const [subGenreDrafts, setSubGenreDrafts] = useState<Record<string, SubGenreDraft>>({});

  const mainGenreNameById = useMemo(
    () => new Map(mainGenres.map((genre) => [genre.id, genre.name])),
    [mainGenres],
  );
  const subGenreNameById = useMemo(
    () => new Map(subGenres.map((subGenre) => [subGenre.id, subGenre.name])),
    [subGenres],
  );

  useEffect(() => {
    setMainGenreDrafts(Object.fromEntries(mainGenres.map((genre) => [genre.id, genre.name])));
  }, [mainGenres]);

  useEffect(() => {
    setSubGenreDrafts(
      Object.fromEntries(
        subGenres.map((subGenre) => [
          subGenre.id,
          { name: subGenre.name, mainGenreId: subGenre.mainGenreId },
        ]),
      ),
    );
  }, [subGenres]);

  useEffect(() => {
    if (!mainGenres.some((genre) => genre.id === newSubGenreMainId)) {
      setNewSubGenreMainId(mainGenres[0]?.id ?? "");
    }
  }, [mainGenres, newSubGenreMainId]);

  const filterableSubGenres = mainGenreFilter
    ? subGenres.filter((subGenre) => subGenre.mainGenreId === mainGenreFilter)
    : subGenres;

  useEffect(() => {
    if (subGenreFilter && !filterableSubGenres.some((subGenre) => subGenre.id === subGenreFilter)) {
      setSubGenreFilter("");
    }
  }, [filterableSubGenres, subGenreFilter]);

  const filteredStores = stores.filter((store) => {
    const query = searchText.trim().toLowerCase();
    const matchesSearch =
      !query ||
      [store.name, store.area ?? "", store.memo ?? ""].some((value) =>
        value.toLowerCase().includes(query),
      );
    const matchesMainGenre = !mainGenreFilter || store.mainGenreId === mainGenreFilter;
    const matchesSubGenre = !subGenreFilter || store.subGenreId === subGenreFilter;
    const matchesRank =
      !rankFilter ||
      (rankFilter === "archive" ? store.rank === "archive" : store.rank === Number(rankFilter));

    return matchesSearch && matchesMainGenre && matchesSubGenre && matchesRank;
  });

  const applyMutationResult = (result: MutationResult, successMessage: string) => {
    setFeedbackMessage(result.ok ? successMessage : (result.message ?? "操作に失敗しました。"));
    return result.ok;
  };

  const handleAddMainGenre = () => {
    if (applyMutationResult(addMainGenre(newMainGenreName), "大ジャンルを追加しました。")) {
      setNewMainGenreName("");
    }
  };

  const handleAddSubGenre = () => {
    if (
      applyMutationResult(
        addSubGenre(newSubGenreMainId, newSubGenreName),
        "小ジャンルを追加しました。",
      )
    ) {
      setNewSubGenreName("");
    }
  };

  return (
    <div className="min-h-screen bg-neutral-50">
      <header className="border-b border-neutral-200 bg-white">
        <div className="mx-auto flex max-w-5xl items-center justify-between gap-3 px-4 py-4">
          <div>
            <p className="text-xs font-bold uppercase tracking-wide text-emerald-700">Settings</p>
            <h1 className="text-2xl font-bold text-neutral-950">設定</h1>
          </div>
          <button
            type="button"
            onClick={onBack}
            className="rounded-lg border border-neutral-300 px-4 py-2 text-sm font-bold text-neutral-700 hover:bg-neutral-100"
          >
            メインへ戻る
          </button>
        </div>
      </header>

      <main className="mx-auto max-w-5xl px-4 py-6">
        <div className="mb-5 grid grid-cols-3 gap-2 rounded-lg border border-neutral-200 bg-white p-1">
          <TabButton active={activeTab === "stores"} onClick={() => setActiveTab("stores")}>
            登録データ編集
          </TabButton>
          <TabButton
            active={activeTab === "mainGenres"}
            onClick={() => setActiveTab("mainGenres")}
          >
            ジャンル編集
          </TabButton>
          <TabButton active={activeTab === "subGenres"} onClick={() => setActiveTab("subGenres")}>
            種類編集
          </TabButton>
        </div>

        {feedbackMessage ? (
          <div className="mb-5 rounded-lg border border-emerald-200 bg-emerald-50 p-3 text-sm font-semibold text-emerald-800 whitespace-pre-line">
            {feedbackMessage}
          </div>
        ) : null}

        {activeTab === "stores" ? (
          <section className="space-y-4">
            <div className="rounded-lg border border-neutral-200 bg-white p-4">
              <div className="grid grid-cols-1 gap-3 md:grid-cols-4">
                <label className="block md:col-span-2">
                  <span className="mb-1 block text-xs font-bold text-neutral-500">検索</span>
                  <input
                    value={searchText}
                    onChange={(event) => setSearchText(event.target.value)}
                    className="w-full rounded-lg border border-neutral-300 px-3 py-2.5 text-sm"
                    placeholder="店名・エリア・メモ"
                  />
                </label>

                <FilterSelect
                  label="大ジャンル"
                  value={mainGenreFilter}
                  onChange={setMainGenreFilter}
                  options={mainGenres.map((genre) => ({ value: genre.id, label: genre.name }))}
                />
                <FilterSelect
                  label="小ジャンル"
                  value={subGenreFilter}
                  onChange={setSubGenreFilter}
                  options={filterableSubGenres.map((subGenre) => ({
                    value: subGenre.id,
                    label: subGenre.name,
                  }))}
                />
                <FilterSelect
                  label="現在順位"
                  value={rankFilter}
                  onChange={setRankFilter}
                  options={[
                    { value: "1", label: "1位" },
                    { value: "2", label: "2位" },
                    { value: "3", label: "3位" },
                    { value: "4", label: "4位" },
                    { value: "5", label: "5位" },
                    { value: "archive", label: "Archive" },
                  ]}
                />
              </div>
            </div>

            <div className="space-y-3">
              {filteredStores.length === 0 ? (
                <div className="rounded-lg border border-neutral-200 bg-white p-6 text-center text-sm text-neutral-500">
                  条件に一致する店舗はありません。
                </div>
              ) : (
                filteredStores.map((store) => (
                  <StoreSettingsRow
                    key={store.id}
                    store={store}
                    mainGenreName={mainGenreNameById.get(store.mainGenreId) ?? "未設定"}
                    subGenreName={subGenreNameById.get(store.subGenreId) ?? "未設定"}
                    onEdit={() => onEditStore(store)}
                    onArchive={() => {
                      onArchiveStore(store.id);
                      setFeedbackMessage("Archiveへ移動しました。");
                    }}
                    onDelete={() => {
                      if (window.confirm(`${store.name}を削除しますか？`)) {
                        onDeleteStore(store.id);
                        setFeedbackMessage("店舗を削除しました。");
                      }
                    }}
                  />
                ))
              )}
            </div>
          </section>
        ) : null}

        {activeTab === "mainGenres" ? (
          <section className="space-y-4">
            <div className="rounded-lg border border-neutral-200 bg-white p-4">
              <div className="grid grid-cols-1 gap-3 sm:grid-cols-[1fr_auto]">
                <input
                  value={newMainGenreName}
                  onChange={(event) => setNewMainGenreName(event.target.value)}
                  className="rounded-lg border border-neutral-300 px-3 py-2.5 text-sm"
                  placeholder="追加する大ジャンル名"
                />
                <button
                  type="button"
                  onClick={handleAddMainGenre}
                  className="rounded-lg bg-emerald-600 px-5 py-2.5 text-sm font-bold text-white hover:bg-emerald-700"
                >
                  追加
                </button>
              </div>
            </div>

            <div className="space-y-3">
              {mainGenres.map((genre, index) => (
                <div
                  key={genre.id}
                  className="grid grid-cols-1 gap-3 rounded-lg border border-neutral-200 bg-white p-4 md:grid-cols-[1fr_auto]"
                >
                  <input
                    value={mainGenreDrafts[genre.id] ?? genre.name}
                    onChange={(event) =>
                      setMainGenreDrafts((currentDrafts) => ({
                        ...currentDrafts,
                        [genre.id]: event.target.value,
                      }))
                    }
                    className="rounded-lg border border-neutral-300 px-3 py-2.5 text-sm font-semibold"
                  />
                  <div className="flex flex-wrap gap-2">
                    <SmallButton
                      onClick={() =>
                        applyMutationResult(
                          updateMainGenre(genre.id, mainGenreDrafts[genre.id] ?? genre.name),
                          "大ジャンル名を更新しました。",
                        )
                      }
                    >
                      保存
                    </SmallButton>
                    <SmallButton
                      onClick={() => moveMainGenre(genre.id, "up")}
                      disabled={index === 0}
                    >
                      上へ
                    </SmallButton>
                    <SmallButton
                      onClick={() => moveMainGenre(genre.id, "down")}
                      disabled={index === mainGenres.length - 1}
                    >
                      下へ
                    </SmallButton>
                    <DangerButton
                      onClick={() => {
                        if (window.confirm(`${genre.name}を削除しますか？`)) {
                          applyMutationResult(deleteMainGenre(genre.id), "大ジャンルを削除しました。");
                        }
                      }}
                    >
                      削除
                    </DangerButton>
                  </div>
                </div>
              ))}
            </div>
          </section>
        ) : null}

        {activeTab === "subGenres" ? (
          <section className="space-y-4">
            <div className="rounded-lg border border-neutral-200 bg-white p-4">
              <div className="grid grid-cols-1 gap-3 md:grid-cols-[220px_1fr_auto]">
                <select
                  value={newSubGenreMainId}
                  onChange={(event) => setNewSubGenreMainId(event.target.value)}
                  className="rounded-lg border border-neutral-300 bg-white px-3 py-2.5 text-sm"
                >
                  {mainGenres.map((genre) => (
                    <option key={genre.id} value={genre.id}>
                      {genre.name}
                    </option>
                  ))}
                </select>
                <input
                  value={newSubGenreName}
                  onChange={(event) => setNewSubGenreName(event.target.value)}
                  className="rounded-lg border border-neutral-300 px-3 py-2.5 text-sm"
                  placeholder="追加する小ジャンル名"
                />
                <button
                  type="button"
                  onClick={handleAddSubGenre}
                  className="rounded-lg bg-emerald-600 px-5 py-2.5 text-sm font-bold text-white hover:bg-emerald-700"
                >
                  追加
                </button>
              </div>
            </div>

            <div className="space-y-5">
              {mainGenres.map((genre) => {
                const children = subGenres.filter((subGenre) => subGenre.mainGenreId === genre.id);

                return (
                  <div key={genre.id} className="space-y-3">
                    <h2 className="text-sm font-bold text-neutral-600">{genre.name}</h2>
                    {children.length === 0 ? (
                      <div className="rounded-lg border border-neutral-200 bg-white p-4 text-sm text-neutral-500">
                        このジャンルに種類はありません。
                      </div>
                    ) : (
                      children.map((subGenre, index) => {
                        const draft = subGenreDrafts[subGenre.id] ?? {
                          name: subGenre.name,
                          mainGenreId: subGenre.mainGenreId,
                        };

                        return (
                          <div
                            key={subGenre.id}
                            className="grid grid-cols-1 gap-3 rounded-lg border border-neutral-200 bg-white p-4 lg:grid-cols-[1fr_220px_auto]"
                          >
                            <input
                              value={draft.name}
                              onChange={(event) =>
                                setSubGenreDrafts((currentDrafts) => ({
                                  ...currentDrafts,
                                  [subGenre.id]: { ...draft, name: event.target.value },
                                }))
                              }
                              className="rounded-lg border border-neutral-300 px-3 py-2.5 text-sm font-semibold"
                            />
                            <select
                              value={draft.mainGenreId}
                              onChange={(event) =>
                                setSubGenreDrafts((currentDrafts) => ({
                                  ...currentDrafts,
                                  [subGenre.id]: {
                                    ...draft,
                                    mainGenreId: event.target.value,
                                  },
                                }))
                              }
                              className="rounded-lg border border-neutral-300 bg-white px-3 py-2.5 text-sm"
                            >
                              {mainGenres.map((mainGenre) => (
                                <option key={mainGenre.id} value={mainGenre.id}>
                                  {mainGenre.name}
                                </option>
                              ))}
                            </select>
                            <div className="flex flex-wrap gap-2">
                              <SmallButton
                                onClick={() =>
                                  applyMutationResult(
                                    updateSubGenre(subGenre.id, draft),
                                    "小ジャンルを更新しました。",
                                  )
                                }
                              >
                                保存
                              </SmallButton>
                              <SmallButton
                                onClick={() => moveSubGenre(subGenre.id, "up")}
                                disabled={index === 0}
                              >
                                上へ
                              </SmallButton>
                              <SmallButton
                                onClick={() => moveSubGenre(subGenre.id, "down")}
                                disabled={index === children.length - 1}
                              >
                                下へ
                              </SmallButton>
                              <DangerButton
                                onClick={() => {
                                  if (window.confirm(`${subGenre.name}を削除しますか？`)) {
                                    applyMutationResult(
                                      deleteSubGenre(subGenre.id),
                                      "小ジャンルを削除しました。",
                                    );
                                  }
                                }}
                              >
                                削除
                              </DangerButton>
                            </div>
                          </div>
                        );
                      })
                    )}
                  </div>
                );
              })}
            </div>
          </section>
        ) : null}
      </main>
    </div>
  );
}

function TabButton({
  active,
  onClick,
  children,
}: {
  active: boolean;
  onClick: () => void;
  children: React.ReactNode;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={[
        "rounded-lg px-3 py-2.5 text-sm font-bold transition",
        active ? "bg-neutral-900 text-white" : "text-neutral-600 hover:bg-neutral-100",
      ].join(" ")}
    >
      {children}
    </button>
  );
}

function FilterSelect({
  label,
  value,
  onChange,
  options,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
  options: { value: string; label: string }[];
}) {
  return (
    <label className="block">
      <span className="mb-1 block text-xs font-bold text-neutral-500">{label}</span>
      <select
        value={value}
        onChange={(event) => onChange(event.target.value)}
        className="w-full rounded-lg border border-neutral-300 bg-white px-3 py-2.5 text-sm"
      >
        <option value="">すべて</option>
        {options.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
    </label>
  );
}

function StoreSettingsRow({
  store,
  mainGenreName,
  subGenreName,
  onEdit,
  onArchive,
  onDelete,
}: {
  store: Store;
  mainGenreName: string;
  subGenreName: string;
  onEdit: () => void;
  onArchive: () => void;
  onDelete: () => void;
}) {
  return (
    <div className="grid grid-cols-1 gap-3 rounded-lg border border-neutral-200 bg-white p-4 lg:grid-cols-[1fr_auto]">
      <div className="flex min-w-0 gap-4">
        {store.imageUrl ? (
          <img
            src={store.imageUrl}
            alt={store.name}
            className="h-16 w-16 shrink-0 rounded-lg object-cover"
            loading="lazy"
          />
        ) : (
          <div className="flex h-16 w-16 shrink-0 items-center justify-center rounded-lg bg-neutral-200 text-[11px] font-bold text-neutral-500">
            No image
          </div>
        )}
        <div className="min-w-0">
          <p className="truncate text-base font-bold text-neutral-950">{store.name}</p>
          <p className="mt-1 text-sm text-neutral-600">
            {mainGenreName} / {subGenreName}
          </p>
          <p className="mt-1 text-sm text-neutral-500">
            {formatRank(store.rank)} ・ {store.area || "エリア未登録"}
          </p>
        </div>
      </div>
      <div className="flex flex-wrap items-center gap-2">
        <SmallButton onClick={onEdit}>編集</SmallButton>
        <SmallButton onClick={onArchive} disabled={!isNumericRank(store.rank)}>
          Archive
        </SmallButton>
        <DangerButton onClick={onDelete}>削除</DangerButton>
      </div>
    </div>
  );
}

function SmallButton({
  children,
  onClick,
  disabled = false,
}: {
  children: React.ReactNode;
  onClick: () => void;
  disabled?: boolean;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      className="rounded-lg border border-neutral-300 px-3 py-2 text-sm font-bold text-neutral-700 hover:bg-neutral-100 disabled:cursor-not-allowed disabled:opacity-40"
    >
      {children}
    </button>
  );
}

function DangerButton({
  children,
  onClick,
}: {
  children: React.ReactNode;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className="rounded-lg border border-red-200 px-3 py-2 text-sm font-bold text-red-700 hover:bg-red-50"
    >
      {children}
    </button>
  );
}
