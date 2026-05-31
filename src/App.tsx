import { useEffect, useMemo, useState } from "react";
import { ArchiveList } from "./components/ArchiveList";
import { GenreSelect } from "./components/GenreSelect";
import { RankingList } from "./components/RankingList";
import { SettingsPanel } from "./components/SettingsPanel";
import { StoreModal, type StoreModalMode } from "./components/StoreModal";
import { useRankingStore } from "./hooks/useRankingStore";
import { buildBestRows, getArchiveStores } from "./lib/ranking";
import type { NumericRank, Store, StorePayload, StoreRank } from "./types";

type Screen = "main" | "settings";

type ModalState = {
  mode: StoreModalMode;
  store?: Store | null;
  initialRank?: StoreRank;
};

function App() {
  const {
    stores,
    mainGenres,
    subGenres,
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
  } = useRankingStore();

  const [screen, setScreen] = useState<Screen>("main");
  const [selectedMainGenreId, setSelectedMainGenreId] = useState(mainGenres[0]?.id ?? "");
  const [selectedSubGenreId, setSelectedSubGenreId] = useState("");
  const [modalState, setModalState] = useState<ModalState | null>(null);

  const selectedMainGenre = mainGenres.find((genre) => genre.id === selectedMainGenreId);
  const availableSubGenres = useMemo(
    () => subGenres.filter((subGenre) => subGenre.mainGenreId === selectedMainGenreId),
    [selectedMainGenreId, subGenres],
  );
  const selectedSubGenre = availableSubGenres.find((subGenre) => subGenre.id === selectedSubGenreId);

  useEffect(() => {
    if (mainGenres.length === 0) {
      setSelectedMainGenreId("");
      return;
    }

    if (!selectedMainGenreId || !mainGenres.some((genre) => genre.id === selectedMainGenreId)) {
      setSelectedMainGenreId(mainGenres[0].id);
    }
  }, [mainGenres, selectedMainGenreId]);

  useEffect(() => {
    if (availableSubGenres.length === 0) {
      setSelectedSubGenreId("");
      return;
    }

    if (
      !selectedSubGenreId ||
      !availableSubGenres.some((subGenre) => subGenre.id === selectedSubGenreId)
    ) {
      setSelectedSubGenreId(availableSubGenres[0].id);
    }
  }, [availableSubGenres, selectedSubGenreId]);

  const bestRows = useMemo(
    () => buildBestRows(stores, selectedMainGenreId, selectedSubGenreId),
    [stores, selectedMainGenreId, selectedSubGenreId],
  );

  const archiveStores = useMemo(
    () => getArchiveStores(stores, selectedMainGenreId, selectedSubGenreId),
    [stores, selectedMainGenreId, selectedSubGenreId],
  );

  const firstTbdRank = bestRows.find((row) => row.type === "tbd")?.rank;

  const handleMainGenreChange = (mainGenreId: string) => {
    setSelectedMainGenreId(mainGenreId);
    const firstSubGenre = subGenres.find((subGenre) => subGenre.mainGenreId === mainGenreId);
    setSelectedSubGenreId(firstSubGenre?.id ?? "");
  };

  const handleSaveStore = (payload: StorePayload, storeId?: string) => {
    saveStore(payload, storeId);
    setSelectedMainGenreId(payload.mainGenreId);
    setSelectedSubGenreId(payload.subGenreId);
  };

  const openCreateModal = (initialRank: StoreRank = firstTbdRank ?? "archive") => {
    setModalState({ mode: "create", store: null, initialRank });
  };

  const openDetailModal = (store: Store) => {
    setModalState({ mode: "detail", store });
  };

  const openEditModal = (store: Store) => {
    setModalState({ mode: "edit", store });
  };

  const modal = modalState ? (
    <StoreModal
      isOpen={Boolean(modalState)}
      mode={modalState.mode}
      store={modalState.store}
      initialMainGenreId={selectedMainGenreId}
      initialSubGenreId={selectedSubGenreId}
      initialRank={modalState.initialRank}
      mainGenres={mainGenres}
      subGenres={subGenres}
      onClose={() => setModalState(null)}
      onSave={handleSaveStore}
      onDelete={deleteStore}
      onMoveToArchive={archiveStore}
    />
  ) : null;

  if (screen === "settings") {
    return (
      <>
        <SettingsPanel
          stores={stores}
          mainGenres={mainGenres}
          subGenres={subGenres}
          onBack={() => setScreen("main")}
          onEditStore={openEditModal}
          onDeleteStore={deleteStore}
          onArchiveStore={archiveStore}
          addMainGenre={addMainGenre}
          updateMainGenre={updateMainGenre}
          deleteMainGenre={deleteMainGenre}
          moveMainGenre={moveMainGenre}
          addSubGenre={addSubGenre}
          updateSubGenre={updateSubGenre}
          deleteSubGenre={deleteSubGenre}
          moveSubGenre={moveSubGenre}
        />
        {modal}
      </>
    );
  }

  const hasCategory = Boolean(selectedMainGenreId && selectedSubGenreId);

  return (
    <div className="min-h-screen bg-neutral-50 pb-28">
      <header className="border-b border-neutral-200 bg-white">
        <div className="mx-auto max-w-5xl px-4 py-4">
          <div className="mb-4 flex items-center justify-between gap-4">
            <div>
              <p className="text-xs font-bold uppercase tracking-wide text-emerald-700">
                My Gourmet Ranking
              </p>
              <h1 className="text-2xl font-bold text-neutral-950">グルメランキング</h1>
            </div>
            <button
              type="button"
              onClick={() => setScreen("settings")}
              className="rounded-lg border border-neutral-300 px-4 py-2 text-sm font-bold text-neutral-700 hover:bg-neutral-100"
            >
              設定
            </button>
          </div>

          <GenreSelect
            mainGenres={mainGenres}
            subGenres={subGenres}
            selectedMainGenreId={selectedMainGenreId}
            selectedSubGenreId={selectedSubGenreId}
            onMainGenreChange={handleMainGenreChange}
            onSubGenreChange={setSelectedSubGenreId}
          />
        </div>
      </header>

      <main className="mx-auto max-w-5xl px-4 py-6">
        {hasCategory ? (
          <div className="space-y-8">
            <section>
              <div className="mb-4 flex items-end justify-between gap-3">
                <div>
                  <p className="text-sm font-semibold text-neutral-500">
                    {selectedMainGenre?.name ?? "未設定"}
                  </p>
                  <h2 className="text-3xl font-bold text-neutral-950">
                    {selectedSubGenre?.name ?? "未設定"} Best5
                  </h2>
                </div>
                <p className="rounded-full bg-emerald-100 px-3 py-1 text-sm font-bold text-emerald-700">
                  {bestRows.filter((row) => row.type === "store").length}/5
                </p>
              </div>
              <RankingList
                rows={bestRows}
                onStoreClick={openDetailModal}
                onTbdClick={(rank: NumericRank) => openCreateModal(rank)}
              />
            </section>

            <section>
              <div className="mb-4 flex items-center justify-between">
                <h2 className="text-xl font-bold text-neutral-950">Archive</h2>
                <span className="text-sm font-semibold text-neutral-500">
                  {archiveStores.length}件
                </span>
              </div>
              <ArchiveList stores={archiveStores} onStoreClick={openDetailModal} />
            </section>
          </div>
        ) : (
          <div className="rounded-lg border border-neutral-200 bg-white p-6 text-center">
            <h2 className="text-lg font-bold text-neutral-950">表示できる種類がありません</h2>
            <p className="mt-2 text-sm text-neutral-500">
              設定画面で大ジャンルと小ジャンルを追加してください。
            </p>
          </div>
        )}
      </main>

      <button
        type="button"
        onClick={() => openCreateModal()}
        disabled={!hasCategory}
        className="fixed bottom-6 right-6 flex h-14 w-14 items-center justify-center rounded-full bg-emerald-600 text-3xl font-light leading-none text-white shadow-soft transition hover:bg-emerald-700 disabled:cursor-not-allowed disabled:opacity-45"
        aria-label="店舗を登録"
      >
        +
      </button>

      {modal}
    </div>
  );
}

export default App;
