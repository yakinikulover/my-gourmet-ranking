import type { MainGenre, SubGenre } from "../types";

type GenreSelectProps = {
  mainGenres: MainGenre[];
  subGenres: SubGenre[];
  selectedMainGenreId: string;
  selectedSubGenreId: string;
  onMainGenreChange: (mainGenreId: string) => void;
  onSubGenreChange: (subGenreId: string) => void;
};

export function GenreSelect({
  mainGenres,
  subGenres,
  selectedMainGenreId,
  selectedSubGenreId,
  onMainGenreChange,
  onSubGenreChange,
}: GenreSelectProps) {
  const availableSubGenres = subGenres.filter(
    (subGenre) => subGenre.mainGenreId === selectedMainGenreId,
  );

  return (
    <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
      <label className="block">
        <span className="mb-1 block text-xs font-bold text-neutral-500">大ジャンル</span>
        <select
          value={selectedMainGenreId}
          onChange={(event) => onMainGenreChange(event.target.value)}
          className="w-full rounded-lg border border-neutral-300 bg-white px-3 py-2.5 text-sm font-semibold text-neutral-900"
        >
          {mainGenres.map((genre) => (
            <option key={genre.id} value={genre.id}>
              {genre.name}
            </option>
          ))}
        </select>
      </label>
      <label className="block">
        <span className="mb-1 block text-xs font-bold text-neutral-500">小ジャンル</span>
        <select
          value={selectedSubGenreId}
          onChange={(event) => onSubGenreChange(event.target.value)}
          disabled={availableSubGenres.length === 0}
          className="w-full rounded-lg border border-neutral-300 bg-white px-3 py-2.5 text-sm font-semibold text-neutral-900 disabled:bg-neutral-100"
        >
          {availableSubGenres.map((genre) => (
            <option key={genre.id} value={genre.id}>
              {genre.name}
            </option>
          ))}
        </select>
      </label>
    </div>
  );
}
