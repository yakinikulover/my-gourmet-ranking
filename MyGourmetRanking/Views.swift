import SwiftUI
import PhotosUI
import UIKit

enum AppTheme {
    static let background = Color(hex: "FBF9F3")
    static let ink = Color(hex: "20211E")
    static let muted = Color(hex: "77786E")
    static let softText = Color(hex: "595B53")
    static let hairline = Color(hex: "D8D5C9")
    static let softFill = Color(hex: "F1EEE4")
    static let card = Color(hex: "FFFEFA")
    static let tomato = Color(hex: "C94328")
    static let olive = Color(hex: "8C9868")
    static let tape = Color(hex: "D9D9B4")
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var value: UInt64 = 0
        scanner.scanHexInt64(&value)

        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            AppTheme.background
            Canvas { context, size in
                for index in 0..<90 {
                    let x = CGFloat((index * 47) % 101) / 100 * size.width
                    let y = CGFloat((index * 71) % 103) / 102 * size.height
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: 1.2, height: 1.2)),
                        with: .color(AppTheme.ink.opacity(0.035))
                    )
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct DashedDivider: View {
    var color: Color = AppTheme.muted.opacity(0.55)

    var body: some View {
        Rectangle()
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
            .foregroundStyle(color)
            .frame(height: 1)
    }
}

struct TapeDecoration: View {
    var color: Color = AppTheme.tape

    var body: some View {
        Rectangle()
            .fill(color.opacity(0.84))
            .frame(width: 44, height: 11)
            .rotationEffect(.degrees(-2))
            .shadow(color: AppTheme.ink.opacity(0.05), radius: 1, y: 1)
    }
}

extension View {
    func modernCard(cornerRadius: CGFloat = 18) -> some View {
        self
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppTheme.hairline, lineWidth: 1)
            }
    }
}

struct ContentView: View {
    @EnvironmentObject private var dataStore: GourmetDataStore
    @State private var selectedMainGenreId = ""
    @State private var selectedSubGenreId = ""
    @State private var formSeed: StoreFormSeed?
    @State private var detailSeed: StoreDetailSeed?
    @State private var isGenrePickerPresented = false
    @State private var genrePickerMode: GenrePickerMode = .mainGenres

    private var availableSubGenres: [SubGenre] {
        dataStore.subGenres(for: selectedMainGenreId)
    }

    private var selectedMainGenre: MainGenre? {
        dataStore.sortedMainGenres.first { $0.id == selectedMainGenreId }
    }

    private var selectedSubGenre: SubGenre? {
        availableSubGenres.first { $0.id == selectedSubGenreId }
    }

    private var bestRows: [BestRankRow] {
        RankingEngine.buildBestRows(
            stores: dataStore.stores,
            mainGenreId: selectedMainGenreId,
            subGenreId: selectedSubGenreId
        )
    }

    private var archiveStores: [Store] {
        RankingEngine.archiveStores(
            stores: dataStore.stores,
            mainGenreId: selectedMainGenreId,
            subGenreId: selectedSubGenreId
        )
    }

    private var firstTBDRank: Int? {
        bestRows.first { row in
            if case .tbd = row {
                return true
            }
            return false
        }?.rank
    }

    private var hasSelectableCategory: Bool {
        !selectedMainGenreId.isEmpty && !selectedSubGenreId.isEmpty
    }

    private var rankedCount: Int {
        bestRows.filter { row in
            if case .store = row {
                return true
            }
            return false
        }.count
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AppBackgroundView()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        selectorSection

                        if hasSelectableCategory {
                            bestSection
                            archiveSection
                        } else {
                            ContentUnavailableView(
                                "表示できる種類がありません",
                                systemImage: "tray",
                                description: Text("設定画面で大ジャンルと小ジャンルを追加してください。")
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    .padding(.bottom, 112)
                }

                Button {
                    openForm(rank: firstTBDRank.map(StoreRank.ranked) ?? .archive)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .medium))
                        .accessibilityLabel("登録")
                        .foregroundStyle(.white)
                    .frame(width: 66, height: 66)
                    .background(hasSelectableCategory ? AppTheme.tomato : Color.gray)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.85), lineWidth: 2)
                            .padding(3)
                    }
                    .shadow(color: AppTheme.tomato.opacity(0.24), radius: 12, x: 0, y: 7)
                }
                .disabled(!hasSelectableCategory)
                .padding(22)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarHidden(true)
            .onAppear(perform: syncSelection)
            .onChange(of: dataStore.sortedMainGenres) { _, _ in syncSelection() }
            .onChange(of: dataStore.sortedSubGenres) { _, _ in syncSelection() }
            .sheet(item: $formSeed) { seed in
                StoreFormView(seed: seed)
                    .environmentObject(dataStore)
            }
            .sheet(item: $detailSeed) { seed in
                StoreDetailView(storeId: seed.id)
                    .environmentObject(dataStore)
            }
            .sheet(isPresented: $isGenrePickerPresented) {
                GenrePickerSheet(
                    selectedMainGenreId: $selectedMainGenreId,
                    selectedSubGenreId: $selectedSubGenreId,
                    mode: genrePickerMode
                )
                .environmentObject(dataStore)
                .presentationDetents([.medium, .large])
            }
        }
    }

    private var selectorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            filterScrollRow(
                icon: "fork.knife",
                label: "カテゴリ",
                tint: AppTheme.tomato,
                mode: .mainGenres
            ) {
                ForEach(dataStore.sortedMainGenres) { mainGenre in
                    Button {
                        selectMainGenre(mainGenre.id)
                    } label: {
                        selectorChip(
                            title: mainGenre.name,
                            isSelected: selectedMainGenreId == mainGenre.id,
                            tint: AppTheme.tomato
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            filterScrollRow(
                icon: "tag",
                label: "ジャンル",
                tint: AppTheme.olive,
                mode: .subGenres
            ) {
                ForEach(availableSubGenres) { subGenre in
                    Button {
                        selectedSubGenreId = subGenre.id
                    } label: {
                        selectorChip(
                            title: subGenre.name,
                            isSelected: selectedSubGenreId == subGenre.id,
                            tint: AppTheme.olive
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 10) {
                DashedDivider()
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.softText)
                        .frame(width: 30, height: 30)
                        .background(AppTheme.softFill)
                        .clipShape(Circle())
                }
                .accessibilityLabel("設定")
            }
        }
    }

    private var bestSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("BEST 5")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .tracking(1)
                        .foregroundStyle(AppTheme.ink)
                    Rectangle()
                        .fill(AppTheme.tomato)
                        .frame(width: 122, height: 3)
                        .rotationEffect(.degrees(-2))
                }
                Spacer()
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundStyle(AppTheme.tomato)
                    .padding(12)
                    .overlay {
                        Circle()
                            .stroke(AppTheme.tomato, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                    }
            }

            VStack(alignment: .leading, spacing: 0) {
                ForEach(bestRows) { row in
                    switch row {
                    case .store(let rank, let store):
                        Button {
                            detailSeed = StoreDetailSeed(id: store.id)
                        } label: {
                            StoreCardView(store: store, rankLabel: "\(rank)位", rank: rank, style: .best)
                        }
                        .buttonStyle(.plain)
                    case .tbd(let rank):
                        Button {
                            openForm(rank: .ranked(rank))
                        } label: {
                            TBDCardView(rank: rank)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var archiveSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "archivebox")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(AppTheme.olive)
                Text("Archive")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                Text("\(archiveStores.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.olive)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.olive.opacity(0.12))
                    .clipShape(Capsule())
                Spacer()
                Text("Best5外の記録")
                    .font(.caption)
                    .foregroundStyle(AppTheme.softText)
            }

            if archiveStores.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Archiveの店舗はまだありません。")
                        .font(.headline)
                    Text("Best5から外した店や未ランクインの店がここに残ります。")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 14)
                .padding(.horizontal, 4)
            } else {
                VStack(spacing: 0) {
                    ForEach(archiveStores) { store in
                        Button {
                            detailSeed = StoreDetailSeed(id: store.id)
                        } label: {
                            StoreCardView(
                                store: store,
                                rankLabel: store.previousRank.map { "元\($0)位" } ?? "未ランクイン",
                                style: .archive
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func filterScrollRow<Content: View>(
        icon: String,
        label: String,
        tint: Color,
        mode: GenrePickerMode,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 9) {
            Button {
                genrePickerMode = mode
                isGenrePickerPresented = true
            } label: {
                VStack(spacing: 3) {
                    Image(systemName: icon)
                        .font(.subheadline.weight(.bold))
                    Text(label)
                        .font(.system(size: 9, weight: .black, design: .rounded))
                }
                .foregroundStyle(tint)
                .frame(width: 54, height: 48)
                .background(tint.opacity(0.11))
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            }
            .buttonStyle(.plain)

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    content()
                }
                .padding(.vertical, 2)
                .padding(.trailing, 2)
            }
            .scrollIndicators(.hidden)
            .contentMargins(.horizontal, 0, for: .scrollContent)
        }
    }

    private func selectorChip(title: String, isSelected: Bool, tint: Color) -> some View {
        Text(title)
            .font(.system(size: 14, weight: isSelected ? .bold : .medium, design: .rounded))
            .foregroundStyle(isSelected ? .white : AppTheme.ink)
            .lineLimit(1)
            .padding(.horizontal, 13)
            .frame(height: 40)
            .background(isSelected ? tint : AppTheme.softFill)
            .clipShape(Capsule())
            .overlay {
                if !isSelected {
                    Capsule()
                        .stroke(AppTheme.hairline, lineWidth: 1)
                }
            }
    }

    private func selectMainGenre(_ mainGenreId: String) {
        selectedMainGenreId = mainGenreId
        selectedSubGenreId = preferredSubGenreId(for: mainGenreId)
    }

    private func syncSelection() {
        let mainGenres = dataStore.sortedMainGenres
        if selectedMainGenreId.isEmpty || !mainGenres.contains(where: { $0.id == selectedMainGenreId }) {
            selectedMainGenreId = mainGenres.max { lhs, rhs in
                storeCount(mainGenreId: lhs.id) < storeCount(mainGenreId: rhs.id)
            }?.id ?? mainGenres.first?.id ?? ""
        }

        let subGenres = dataStore.subGenres(for: selectedMainGenreId)
        if selectedSubGenreId.isEmpty || !subGenres.contains(where: { $0.id == selectedSubGenreId }) {
            selectedSubGenreId = preferredSubGenreId(for: selectedMainGenreId)
        }
    }

    private func preferredSubGenreId(for mainGenreId: String) -> String {
        let subGenres = dataStore.subGenres(for: mainGenreId)
        return subGenres.max { lhs, rhs in
            storeCount(mainGenreId: mainGenreId, subGenreId: lhs.id)
                < storeCount(mainGenreId: mainGenreId, subGenreId: rhs.id)
        }?.id ?? subGenres.first?.id ?? ""
    }

    private func storeCount(mainGenreId: String, subGenreId: String? = nil) -> Int {
        dataStore.stores.filter { store in
            store.mainGenreId == mainGenreId && (subGenreId == nil || store.subGenreId == subGenreId)
        }.count
    }

    private func openForm(rank: StoreRank) {
        formSeed = StoreFormSeed(
            store: nil,
            mainGenreId: selectedMainGenreId,
            subGenreId: selectedSubGenreId,
            rank: rank
        )
    }
}

struct FilterToken: View {
    let title: String

    var body: some View {
        HStack(spacing: 5) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(1)
            Image(systemName: "chevron.down")
                .font(.caption2.weight(.bold))
                .foregroundStyle(AppTheme.muted)
        }
    }
}

enum GenrePickerMode {
    case mainGenres
    case subGenres
}

struct GenrePickerSheet: View {
    @EnvironmentObject private var dataStore: GourmetDataStore
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMainGenreId: String
    @Binding var selectedSubGenreId: String
    let mode: GenrePickerMode
    @State private var searchText = ""

    private var normalizedQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var selectedMainGenre: MainGenre? {
        dataStore.sortedMainGenres.first { $0.id == selectedMainGenreId }
    }

    private var visibleMainGenres: [MainGenre] {
        guard let selectedMainGenre else {
            return dataStore.sortedMainGenres
        }
        return [selectedMainGenre]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchField

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        if mode == .mainGenres {
                            mainGenreList
                        } else {
                            subGenreList
                        }
                    }
                    .padding(16)
                }
            }
            .background(AppBackgroundView())
            .navigationTitle(mode == .mainGenres ? "カテゴリを選択" : "ジャンルを選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
        .tint(AppTheme.ink)
    }

    private var mainGenreList: some View {
        VStack(spacing: 0) {
            ForEach(filteredMainGenres) { mainGenre in
                Button {
                    selectedMainGenreId = mainGenre.id
                    selectedSubGenreId = dataStore.subGenres(for: mainGenre.id).first?.id ?? ""
                    dismiss()
                } label: {
                    selectionRow(
                        title: mainGenre.name,
                        isSelected: selectedMainGenreId == mainGenre.id
                    )
                }
                .buttonStyle(.plain)
                DashedDivider(color: AppTheme.hairline)
            }
        }
    }

    private var subGenreList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(selectedMainGenre?.name ?? "選択中のカテゴリ")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.tomato)

            VStack(spacing: 0) {
                ForEach(filteredSelectedSubGenres) { subGenre in
                    Button {
                        selectedSubGenreId = subGenre.id
                        dismiss()
                    } label: {
                        selectionRow(
                            title: subGenre.name,
                            isSelected: selectedSubGenreId == subGenre.id
                        )
                    }
                    .buttonStyle(.plain)
                    DashedDivider(color: AppTheme.hairline)
                }
            }
        }
    }

    private var filteredSelectedSubGenres: [SubGenre] {
        guard let selectedMainGenre else {
            return []
        }
        return visibleSubGenres(for: selectedMainGenre)
    }

    private var filteredMainGenres: [MainGenre] {
        guard !normalizedQuery.isEmpty else {
            return dataStore.sortedMainGenres
        }
        return dataStore.sortedMainGenres.filter { $0.name.lowercased().contains(normalizedQuery) }
    }

    private func selectionRow(title: String, isSelected: Bool) -> some View {
        HStack {
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.body.weight(.bold))
                    .foregroundStyle(AppTheme.tomato)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.headline)
                .foregroundStyle(AppTheme.softText)
            TextField("定食、寿司、ラーメンなど", text: $searchText)
                .textInputAutocapitalization(.never)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.softText)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppTheme.softFill)
        .clipShape(Capsule())
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func visibleSubGenres(for mainGenre: MainGenre) -> [SubGenre] {
        let subGenres = dataStore.subGenres(for: mainGenre.id)
        guard !normalizedQuery.isEmpty else {
            return subGenres
        }

        return subGenres.filter { $0.name.lowercased().contains(normalizedQuery) }
    }
}

struct SectionTitleView: View {
    let title: String
    let subtitle: String
    let count: String

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 3) {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.softText)
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.ink)
            }
            Spacer()
            Text(count)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.ink)
                .clipShape(Capsule())
        }
    }
}

struct StoreDetailSeed: Identifiable {
    let id: String
}

struct StoreFormSeed: Identifiable {
    let id = UUID()
    let store: Store?
    let mainGenreId: String
    let subGenreId: String
    let rank: StoreRank

    init(store: Store?, mainGenreId: String, subGenreId: String, rank: StoreRank) {
        self.store = store
        self.mainGenreId = mainGenreId
        self.subGenreId = subGenreId
        self.rank = rank
    }

    init(store: Store) {
        self.store = store
        mainGenreId = store.mainGenreId
        subGenreId = store.subGenreId
        rank = store.rank
    }
}

enum StoreCardStyle {
    case best
    case archive
    case compact
}

enum StoreImageSource: Identifiable, Equatable {
    case local(String)
    case remote(String)

    var id: String {
        switch self {
        case .local(let fileName): "local-\(fileName)"
        case .remote(let url): "remote-\(url)"
        }
    }
}

extension Store {
    var imageSources: [StoreImageSource] {
        let localSources = (imageFileNames ?? []).map(StoreImageSource.local)
        if !localSources.isEmpty {
            return localSources
        }
        guard let imageUrl else {
            return []
        }
        return [.remote(imageUrl)]
    }

    var primaryImageSource: StoreImageSource? {
        imageSources.first
    }
}

struct StoreCardView: View {
    let store: Store
    let rankLabel: String
    var rank: Int?
    var style: StoreCardStyle = .best

    private var imageSize: CGFloat {
        guard style == .best else {
            return style == .archive ? 68 : 54
        }

        return 92
    }

    private var titleSize: CGFloat {
        guard style == .best else {
            return style == .archive ? 16 : 15
        }

        return 18
    }

    private var memoFont: Font {
        guard style == .best else {
            return .subheadline
        }

        return .footnote
    }

    private var rowPadding: CGFloat {
        guard style == .best else {
            return 10
        }

        return 10
    }

    private var verticalSpacing: CGFloat {
        5
    }

    var body: some View {
        Group {
            if style == .best {
                bestCardBody
            } else {
                compactCardBody
            }
        }
        .padding(rowPadding)
        .background(AppTheme.card.opacity(style == .archive ? 0.48 : 0.72))
        .overlay(alignment: .bottom) {
            DashedDivider(color: AppTheme.hairline)
        }
        .opacity(style == .archive ? 0.9 : 1)
    }

    private var bestCardBody: some View {
        HStack(alignment: .center, spacing: 12) {
            rankBadge

            ZStack(alignment: .top) {
                ThumbnailView(source: store.primaryImageSource, name: store.name, size: imageSize)
                    .clipShape(Rectangle())
                    .padding(.top, 4)
                TapeDecoration(color: rank == 2 ? Color(hex: "E6B9A7") : AppTheme.tape)
                    .offset(y: -2)
            }

            VStack(alignment: .leading, spacing: verticalSpacing + 1) {
                HStack {
                    Text(store.name)
                        .font(.system(size: titleSize, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "bookmark.fill")
                        .font(.caption)
                        .foregroundStyle(AppTheme.olive)
                }

                HStack(spacing: 5) {
                    Image(systemName: "mappin")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.olive)
                    Text(store.area ?? "エリア未登録")
                        .font(.caption)
                        .foregroundStyle(AppTheme.softText)
                        .lineLimit(1)
                }

                Text(store.memo ?? "メモ未登録")
                    .font(memoFont)
                    .foregroundStyle(AppTheme.softText)
                    .lineLimit(2, reservesSpace: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 112)
    }

    private var compactCardBody: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack(alignment: .top) {
                ThumbnailView(source: store.primaryImageSource, name: store.name, size: imageSize)
                    .clipShape(Rectangle())
                    .padding(.top, 4)
                TapeDecoration()
                    .scaleEffect(0.8)
                    .offset(y: -3)
            }

            VStack(alignment: .leading, spacing: verticalSpacing) {
                HStack(spacing: 7) {
                    rankBadge
                    Text(store.area ?? "エリア未登録")
                        .font(.caption)
                        .foregroundStyle(AppTheme.softText)
                        .lineLimit(1)
                }

                Text(store.name)
                    .font(.system(size: titleSize, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)
                Text(store.memo ?? "メモ未登録")
                    .font(memoFont)
                    .foregroundStyle(AppTheme.softText)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)

            if style == .best {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.muted.opacity(0.55))
            }
        }
    }

    private var rankBadge: some View {
        Group {
            if style == .best, let rank {
                VStack(spacing: -3) {
                    Text("\(rank)")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(rank <= 3 ? AppTheme.tomato : AppTheme.ink)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text("位")
                        .font(.caption2.weight(.black))
                        .foregroundStyle(rank <= 3 ? AppTheme.tomato : AppTheme.ink)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .offset(x: -6)
                .frame(width: 48, alignment: .center)
                .overlay(alignment: .trailing) {
                    DashedDivider(color: AppTheme.hairline)
                        .frame(width: 104)
                        .rotationEffect(.degrees(90))
                        .offset(x: 58)
                }
            } else {
                Text(rankLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.olive)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.olive.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
    }
}

struct TBDCardView: View {
    let rank: Int

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(spacing: -3) {
                Text("\(rank)")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(rank <= 3 ? AppTheme.tomato : AppTheme.ink)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("位")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(rank <= 3 ? AppTheme.tomato : AppTheme.ink)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .offset(x: -6)
            .frame(width: 48, alignment: .center)
            .overlay(alignment: .trailing) {
                DashedDivider(color: AppTheme.hairline)
                    .frame(width: 104)
                    .rotationEffect(.degrees(90))
                    .offset(x: 58)
            }

            ZStack(alignment: .top) {
                ZStack {
                    Rectangle()
                        .fill(AppTheme.softFill)
                    Path { path in
                        for value in stride(from: 14.0, to: 92.0, by: 14.0) {
                            path.move(to: CGPoint(x: value, y: 0))
                            path.addLine(to: CGPoint(x: value, y: 92))
                            path.move(to: CGPoint(x: 0, y: value))
                            path.addLine(to: CGPoint(x: 92, y: value))
                        }
                    }
                    .stroke(AppTheme.hairline.opacity(0.55), lineWidth: 0.5)
                    Text("TBD")
                        .font(.system(size: 22, weight: .regular, design: .rounded))
                        .italic()
                        .foregroundStyle(AppTheme.softText)
                }
                .frame(width: 92, height: 92)
                .shadow(color: AppTheme.ink.opacity(0.09), radius: 3, y: 2)
                .padding(.top, 4)
                TapeDecoration(color: rank % 2 == 0 ? Color(hex: "E5D8BE") : AppTheme.tape)
                    .offset(y: -2)
            }

            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text("TBD")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                    Spacer()
                    Image(systemName: "plus")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(AppTheme.olive)
                }
                HStack(spacing: 5) {
                    Image(systemName: "mappin")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.olive)
                    Text("未登録")
                        .font(.caption)
                        .foregroundStyle(AppTheme.softText)
                }
                Text("行ったらメモを残そう")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.softText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 112)
        .padding(10)
        .background(AppTheme.card.opacity(0.62))
        .overlay(alignment: .bottom) {
            DashedDivider(color: AppTheme.hairline)
        }
    }
}

struct ThumbnailView: View {
    let source: StoreImageSource?
    let name: String
    let size: CGFloat

    var body: some View {
        StoreImageContent(source: source, name: name, placeholder: placeholder)
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: min(18, size / 4), style: .continuous))
    }

    private var placeholder: some View {
        ZStack {
            AppTheme.softFill
            Image(systemName: "fork.knife")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.softText)
        }
    }
}

struct StoreImageContent<Placeholder: View>: View {
    let source: StoreImageSource?
    let name: String
    let placeholder: Placeholder
    let contentMode: ContentMode

    init(
        source: StoreImageSource?,
        name: String,
        placeholder: Placeholder,
        contentMode: ContentMode = .fill
    ) {
        self.source = source
        self.name = name
        self.placeholder = placeholder
        self.contentMode = contentMode
    }

    var body: some View {
        Group {
            switch source {
            case .local(let fileName):
                if let image = ImageStorage.image(for: fileName) {
                    configuredImage(Image(uiImage: image))
                } else {
                    placeholder
                }
            case .remote(let imageUrl):
                if let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            configuredImage(image)
                        default:
                            placeholder
                        }
                    }
                } else {
                    placeholder
                }
            case nil:
                placeholder
            }
        }
        .accessibilityLabel(name)
    }

    @ViewBuilder
    private func configuredImage(_ image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: contentMode)
    }
}

struct PhotoDraft: Identifiable, Equatable {
    let id: String
    let fileName: String?
    let data: Data?

    init(fileName: String) {
        id = "file-\(fileName)"
        self.fileName = fileName
        data = nil
    }

    init(data: Data) {
        id = "draft-\(UUID().uuidString)"
        fileName = nil
        self.data = data
    }
}

struct PhotoDraftThumbnail: View {
    let draft: PhotoDraft

    var body: some View {
        Group {
            if let data = draft.data, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if let fileName = draft.fileName, let image = ImageStorage.image(for: fileName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                AppTheme.softFill
            }
        }
        .frame(width: 82, height: 82)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct StoreFormView: View {
    @EnvironmentObject private var dataStore: GourmetDataStore
    @Environment(\.dismiss) private var dismiss

    private let seed: StoreFormSeed
    @State private var name: String
    @State private var mainGenreId: String
    @State private var subGenreId: String
    @State private var rank: StoreRank
    @State private var area: String
    @State private var legacyImageUrl: String
    @State private var photoDrafts: [PhotoDraft]
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var isImportingPhotos = false
    @State private var memo: String
    @State private var mapUrl: String
    @State private var validationMessage: String?

    init(seed: StoreFormSeed) {
        self.seed = seed
        _name = State(initialValue: seed.store?.name ?? "")
        _mainGenreId = State(initialValue: seed.store?.mainGenreId ?? seed.mainGenreId)
        _subGenreId = State(initialValue: seed.store?.subGenreId ?? seed.subGenreId)
        _rank = State(initialValue: seed.store?.rank ?? seed.rank)
        _area = State(initialValue: seed.store?.area ?? "")
        _legacyImageUrl = State(initialValue: seed.store?.imageUrl ?? "")
        _photoDrafts = State(initialValue: (seed.store?.imageFileNames ?? []).map(PhotoDraft.init(fileName:)))
        _memo = State(initialValue: seed.store?.memo ?? "")
        _mapUrl = State(initialValue: seed.store?.mapUrl ?? "")
    }

    private var availableSubGenres: [SubGenre] {
        dataStore.subGenres(for: mainGenreId)
    }

    private var availableRankOptions: [StoreRank] {
        let editingStoreId = seed.store?.id
        let occupiedRanks = Set(
            dataStore.stores.compactMap { store -> StoreRank? in
                guard store.id != editingStoreId,
                      store.mainGenreId == mainGenreId,
                      store.subGenreId == subGenreId,
                      store.rank.numericValue != nil else {
                    return nil
                }
                return store.rank
            }
        )

        return StoreRank.allCases.filter { rank in
            rank == .archive || !occupiedRanks.contains(rank)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                if let validationMessage {
                    Section {
                        Text(validationMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section("基本情報") {
                    TextField("店名", text: $name)

                    Picker("大ジャンル", selection: $mainGenreId) {
                        ForEach(dataStore.sortedMainGenres) { genre in
                            Text(genre.name).tag(genre.id)
                        }
                    }
                    .onChange(of: mainGenreId) { _, newValue in
                        let subGenres = dataStore.subGenres(for: newValue)
                        if !subGenres.contains(where: { $0.id == subGenreId }) {
                            subGenreId = subGenres.first?.id ?? ""
                        }
                        syncRankSelection()
                    }

                    Picker("小ジャンル", selection: $subGenreId) {
                        ForEach(availableSubGenres) { subGenre in
                            Text(subGenre.name).tag(subGenre.id)
                        }
                    }
                    .onChange(of: subGenreId) { _, _ in
                        syncRankSelection()
                    }

                    Picker("順位", selection: $rank) {
                        ForEach(availableRankOptions) { rank in
                            Text(rank.label).tag(rank)
                        }
                    }
                    Text("登録済みの順位は選択肢から外しています。")
                        .font(.caption)
                        .foregroundStyle(AppTheme.softText)
                }

                Section("店舗メモ") {
                    TextField("エリア", text: $area)
                    TextField("Google Map URL", text: $mapUrl, axis: .vertical)
                    TextField("一言メモ", text: $memo, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("写真") {
                    PhotosPicker(selection: $selectedPhotoItems, maxSelectionCount: 6, matching: .images) {
                        Label(isImportingPhotos ? "読み込み中" : "カメラロールから写真を選択", systemImage: "photo.on.rectangle.angled")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .disabled(isImportingPhotos)

                    if photoDrafts.isEmpty, !legacyImageUrl.isEmpty {
                        HStack(spacing: 12) {
                            ThumbnailView(source: .remote(legacyImageUrl), name: name.isEmpty ? "既存画像" : name, size: 72)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("既存のURL画像を使用中")
                                    .font(.subheadline.weight(.semibold))
                                Text("写真を選ぶとカメラロール画像に置き換わります。")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.softText)
                            }
                        }
                    }

                    if !photoDrafts.isEmpty {
                        ScrollView(.horizontal) {
                            HStack(spacing: 10) {
                                ForEach(photoDrafts) { draft in
                                    ZStack(alignment: .topTrailing) {
                                        PhotoDraftThumbnail(draft: draft)
                                        Button {
                                            photoDrafts.removeAll { $0.id == draft.id }
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(.white)
                                                .frame(width: 24, height: 24)
                                                .background(AppTheme.ink)
                                                .clipShape(Circle())
                                        }
                                        .buttonStyle(.plain)
                                        .padding(5)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .scrollIndicators(.hidden)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppBackgroundView())
            .tint(AppTheme.ink)
            .navigationTitle(seed.store == nil ? "店舗を登録" : "店舗を編集")
            .onAppear(perform: syncRankSelection)
            .onChange(of: selectedPhotoItems) { _, newItems in
                guard !newItems.isEmpty else {
                    return
                }
                Task {
                    await importSelectedPhotos(newItems)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存", action: save)
                        .fontWeight(.bold)
                }
            }
        }
    }

    private func save() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationMessage = "店名を入力してください。"
            return
        }
        guard !mainGenreId.isEmpty, !subGenreId.isEmpty else {
            validationMessage = "大ジャンルと小ジャンルを選択してください。"
            return
        }
        guard availableRankOptions.contains(rank) else {
            validationMessage = "選択した順位はすでに登録されています。空いている順位かArchiveを選択してください。"
            syncRankSelection()
            return
        }

        let existingFileNames = photoDrafts.compactMap(\.fileName)
        let newImageDataItems = photoDrafts.compactMap(\.data)
        let savedFileNames: [String]
        do {
            savedFileNames = try ImageStorage.saveImages(newImageDataItems)
        } catch {
            validationMessage = "写真の保存に失敗しました。もう一度選択してください。"
            return
        }
        let imageFileNames = existingFileNames + savedFileNames

        dataStore.saveStore(
            StoreFormData(
                name: name,
                mainGenreId: mainGenreId,
                subGenreId: subGenreId,
                rank: rank,
                area: area,
                memo: memo,
                imageUrl: imageFileNames.isEmpty ? legacyImageUrl : "",
                imageFileNames: imageFileNames,
                mapUrl: mapUrl
            ),
            editingStoreId: seed.store?.id
        )
        dismiss()
    }

    private func syncRankSelection() {
        guard !availableRankOptions.contains(rank) else {
            return
        }
        rank = availableRankOptions.first { $0.numericValue != nil } ?? .archive
    }

    @MainActor
    private func importSelectedPhotos(_ items: [PhotosPickerItem]) async {
        isImportingPhotos = true
        defer {
            isImportingPhotos = false
            selectedPhotoItems = []
        }

        var importedDrafts: [PhotoDraft] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                importedDrafts.append(PhotoDraft(data: data))
            }
        }

        guard !importedDrafts.isEmpty else {
            validationMessage = "写真を読み込めませんでした。別の写真を選んでください。"
            return
        }

        legacyImageUrl = ""
        photoDrafts.append(contentsOf: importedDrafts)
    }
}

struct StoreDetailView: View {
    @EnvironmentObject private var dataStore: GourmetDataStore
    @Environment(\.dismiss) private var dismiss
    let storeId: String
    @State private var formSeed: StoreFormSeed?

    private var store: Store? {
        dataStore.stores.first { $0.id == storeId }
    }

    var body: some View {
        NavigationStack {
            Group {
                if let store {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            ZStack(alignment: .top) {
                                DetailHeroImage(store: store)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    .shadow(color: AppTheme.ink.opacity(0.12), radius: 8, y: 5)
                                TapeDecoration()
                                    .frame(width: 72)
                                    .scaleEffect(1.3)
                                    .offset(y: -7)
                            }
                            .frame(height: 300)

                            VStack(alignment: .leading, spacing: 14) {
                                HStack(alignment: .top, spacing: 14) {
                                    detailRankStamp(store.rank.label)
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(store.name)
                                            .font(.system(size: 31, weight: .black, design: .rounded))
                                            .foregroundStyle(AppTheme.ink)
                                            .lineLimit(2)
                                        HStack(spacing: 7) {
                                            Image(systemName: "mappin")
                                                .foregroundStyle(AppTheme.olive)
                                            Text(store.area ?? "エリア未登録")
                                                .font(.subheadline.weight(.medium))
                                                .foregroundStyle(AppTheme.softText)
                                        }
                                    }
                                }

                                DashedDivider(color: AppTheme.tomato.opacity(0.55))

                                HStack(spacing: 8) {
                                    detailTag(dataStore.mainGenreName(for: store.mainGenreId), icon: "fork.knife")
                                    detailTag(dataStore.subGenreName(for: store.subGenreId), icon: "tag")
                                    if let previousRank = store.previousRank {
                                        detailTag("元\(previousRank)位", icon: "arrow.uturn.backward")
                                    }
                                }
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("MY NOTE")
                                    .font(.caption.weight(.black))
                                    .tracking(1.5)
                                    .foregroundStyle(AppTheme.tomato)
                                Text(store.memo ?? "まだメモはありません。")
                                    .font(.system(size: 17, weight: .regular, design: .rounded))
                                    .foregroundStyle(AppTheme.ink)
                                    .lineSpacing(8)
                                    .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
                                DashedDivider()
                                if let mapUrl = store.mapUrl, let url = URL(string: mapUrl) {
                                    Link(destination: url) {
                                        Label("Google Mapで見る", systemImage: "map")
                                            .font(.subheadline.weight(.bold))
                                            .foregroundStyle(AppTheme.olive)
                                    }
                                } else {
                                    Label("Google Map 未登録", systemImage: "map")
                                        .font(.subheadline)
                                        .foregroundStyle(AppTheme.muted)
                                }
                            }
                            .padding(18)
                            .background(AppTheme.card.opacity(0.72))
                            .overlay(alignment: .topTrailing) {
                                TapeDecoration(color: Color(hex: "E6B9A7"))
                                    .offset(x: -18, y: -5)
                            }

                            HStack(spacing: 10) {
                                Button {
                                    formSeed = StoreFormSeed(store: store)
                                } label: {
                                    Label("編集", systemImage: "pencil")
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(AppTheme.tomato)

                                Button {
                                    dataStore.archiveStore(store.id)
                                    dismiss()
                                } label: {
                                    Label("Archive", systemImage: "archivebox")
                                }
                                .buttonStyle(.bordered)
                                .tint(AppTheme.olive)
                                .disabled(store.rank == .archive)

                                Spacer()

                                Button(role: .destructive) {
                                    dataStore.deleteStore(store.id)
                                    dismiss()
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(AppTheme.muted)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                    }
                    .background(AppBackgroundView())
                } else {
                    ContentUnavailableView("店舗が見つかりません", systemImage: "questionmark.folder")
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(AppTheme.ink)
                }
            }
            .sheet(item: $formSeed) { seed in
                StoreFormView(seed: seed)
                    .environmentObject(dataStore)
            }
        }
    }

    private func detailTag(_ value: String, icon: String) -> some View {
        Label(value, systemImage: icon)
            .font(.caption.weight(.bold))
            .foregroundStyle(AppTheme.softText)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(AppTheme.softFill)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
    }

    private func detailRankStamp(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 18, weight: .black, design: .rounded))
            .foregroundStyle(AppTheme.tomato)
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .overlay {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(AppTheme.tomato, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
            }
            .rotationEffect(.degrees(-2))
    }
}

struct DetailHeroImage: View {
    let store: Store
    @State private var selectedImageIndex = 0
    @State private var isViewerPresented = false

    var body: some View {
        GeometryReader { proxy in
            let sources = store.imageSources
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedImageIndex) {
                    if sources.isEmpty {
                        StoreImageContent(
                            source: nil,
                            name: store.name,
                            placeholder: Rectangle().fill(AppTheme.softFill)
                        )
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                        .tag(0)
                    } else {
                        ForEach(Array(sources.enumerated()), id: \.element.id) { index, source in
                            StoreImageContent(
                                source: source,
                                name: store.name,
                                placeholder: Rectangle().fill(AppTheme.softFill)
                            )
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()
                            .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(width: proxy.size.width, height: proxy.size.height)

                if sources.count > 1 {
                    PhotoPageDots(count: sources.count, selectedIndex: selectedImageIndex)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.36), in: Capsule())
                        .padding(.bottom, 14)
                        .allowsHitTesting(false)
                }
            }
            .overlay(alignment: .topTrailing) {
                if sources.count > 1 {
                    PhotoCountBadge(currentIndex: selectedImageIndex, count: sources.count)
                        .padding(14)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture().onEnded {
                    guard !sources.isEmpty else {
                        return
                    }
                    isViewerPresented = true
                }
            )
            .onChange(of: sources) { _, newSources in
                guard selectedImageIndex >= newSources.count else {
                    return
                }
                selectedImageIndex = max(newSources.count - 1, 0)
            }
            .fullScreenCover(isPresented: $isViewerPresented) {
                FullScreenPhotoViewer(
                    sources: sources,
                    storeName: store.name,
                    selectedImageIndex: $selectedImageIndex
                )
            }
        }
    }
}

struct PhotoPageDots: View {
    let count: Int
    let selectedIndex: Int

    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == selectedIndex ? .white : .white.opacity(0.38))
                    .frame(width: 7, height: 7)
            }
        }
        .animation(.easeInOut(duration: 0.18), value: selectedIndex)
    }
}

struct PhotoCountBadge: View {
    let currentIndex: Int
    let count: Int

    var body: some View {
        Text("\(currentIndex + 1)/\(count)")
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.black.opacity(0.56), in: Capsule())
    }
}

struct FullScreenPhotoViewer: View {
    let sources: [StoreImageSource]
    let storeName: String
    @Binding var selectedImageIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var verticalDragOffset: CGFloat = 0

    private var dragProgress: Double {
        min(Double(verticalDragOffset / 360), 0.72)
    }

    var body: some View {
        ZStack {
            Color.black
                .opacity(1 - dragProgress)
                .ignoresSafeArea()

            TabView(selection: $selectedImageIndex) {
                if sources.isEmpty {
                    Color.black
                        .tag(0)
                } else {
                    ForEach(Array(sources.enumerated()), id: \.element.id) { index, source in
                        StoreImageContent(
                            source: source,
                            name: storeName,
                            placeholder: Color.black,
                            contentMode: .fit
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .offset(y: verticalDragOffset)
            .ignoresSafeArea()

            VStack {
                Spacer()

                if sources.count > 1 {
                    PhotoPageDots(count: sources.count, selectedIndex: selectedImageIndex)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(.black.opacity(0.42), in: Capsule())
                        .padding(.bottom, 22)
                }
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 18)
                .onChanged { value in
                    let verticalMovement = value.translation.height
                    let horizontalMovement = abs(value.translation.width)
                    guard verticalMovement > 0, verticalMovement > horizontalMovement else {
                        return
                    }
                    verticalDragOffset = verticalMovement
                }
                .onEnded { value in
                    let verticalMovement = value.translation.height
                    let horizontalMovement = abs(value.translation.width)
                    let shouldDismiss = verticalMovement > 120 && verticalMovement > horizontalMovement * 1.2

                    if shouldDismiss {
                        dismiss()
                    } else {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                            verticalDragOffset = 0
                        }
                    }
                }
        )
        .onAppear(perform: clampSelectedImageIndex)
        .onChange(of: sources) { _, _ in
            clampSelectedImageIndex()
        }
    }

    private func clampSelectedImageIndex() {
        let maxIndex = max(sources.count - 1, 0)
        if selectedImageIndex > maxIndex {
            selectedImageIndex = maxIndex
        }
    }
}

enum SettingsTab: String, CaseIterable, Identifiable {
    case stores = "登録データ編集"
    case mainGenres = "ジャンル編集"
    case subGenres = "種類編集"

    var id: String { rawValue }
}

struct SettingsView: View {
    @EnvironmentObject private var dataStore: GourmetDataStore
    @State private var selectedTab: SettingsTab = .stores
    @State private var formSeed: StoreFormSeed?
    @State private var message: SettingsMessage?

    @State private var searchText = ""
    @State private var mainGenreFilter = ""
    @State private var subGenreFilter = ""
    @State private var rankFilter = ""

    @State private var newMainGenreName = ""
    @State private var mainGenreDrafts: [String: String] = [:]

    @State private var newSubGenreName = ""
    @State private var newSubGenreMainId = ""
    @State private var subGenreDrafts: [String: SubGenreDraft] = [:]

    private var filteredStores: [Store] {
        dataStore.stores.filter { store in
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let matchesSearch = query.isEmpty
                || store.name.lowercased().contains(query)
                || (store.area ?? "").lowercased().contains(query)
                || (store.memo ?? "").lowercased().contains(query)
            let matchesMainGenre = mainGenreFilter.isEmpty || store.mainGenreId == mainGenreFilter
            let matchesSubGenre = subGenreFilter.isEmpty || store.subGenreId == subGenreFilter
            let matchesRank = rankFilter.isEmpty
                || (rankFilter == "archive" ? store.rank == .archive : store.rank.rawValue == rankFilter)
            return matchesSearch && matchesMainGenre && matchesSubGenre && matchesRank
        }
    }

    private var filterableSubGenres: [SubGenre] {
        if mainGenreFilter.isEmpty {
            return dataStore.sortedSubGenres
        }
        return dataStore.subGenres(for: mainGenreFilter)
    }

    var body: some View {
        VStack(spacing: 0) {
            settingsTabBar

            List {
                switch selectedTab {
                case .stores:
                    registeredStoreSection
                case .mainGenres:
                    mainGenreSection
                case .subGenres:
                    subGenreSection
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .background(AppBackgroundView())
        .tint(AppTheme.ink)
        .navigationTitle("設定")
        .onAppear(perform: syncDrafts)
        .onChange(of: dataStore.sortedMainGenres) { _, _ in syncMainGenreDrafts() }
        .onChange(of: dataStore.sortedSubGenres) { _, _ in syncSubGenreDrafts() }
        .sheet(item: $formSeed) { seed in
            StoreFormView(seed: seed)
                .environmentObject(dataStore)
        }
        .alert(item: $message) { message in
            Alert(title: Text(message.title), message: Text(message.body), dismissButton: .default(Text("OK")))
        }
    }

    private var settingsTabBar: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(SettingsTab.allCases) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        Text(tab.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selectedTab == tab ? .white : AppTheme.ink)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(selectedTab == tab ? AppTheme.ink : AppTheme.softFill)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .scrollIndicators(.hidden)
    }

    private var registeredStoreSection: some View {
        Group {
            Section("検索・絞り込み") {
                TextField("店名・エリア・メモ", text: $searchText)

                Picker("大ジャンル", selection: $mainGenreFilter) {
                    Text("すべて").tag("")
                    ForEach(dataStore.sortedMainGenres) { genre in
                        Text(genre.name).tag(genre.id)
                    }
                }
                .onChange(of: mainGenreFilter) { _, _ in
                    if !filterableSubGenres.contains(where: { $0.id == subGenreFilter }) {
                        subGenreFilter = ""
                    }
                }

                Picker("小ジャンル", selection: $subGenreFilter) {
                    Text("すべて").tag("")
                    ForEach(filterableSubGenres) { subGenre in
                        Text(subGenre.name).tag(subGenre.id)
                    }
                }

                Picker("現在順位", selection: $rankFilter) {
                    Text("すべて").tag("")
                    ForEach(StoreRank.allCases) { rank in
                        Text(rank.label).tag(rank.rawValue)
                    }
                }
            }

            Section("登録データ") {
                if filteredStores.isEmpty {
                    Text("条件に一致する店舗はありません。")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(filteredStores) { store in
                        StoreSettingsRow(store: store) {
                            formSeed = StoreFormSeed(store: store)
                        } onArchive: {
                            dataStore.archiveStore(store.id)
                        } onDelete: {
                            dataStore.deleteStore(store.id)
                        }
                    }
                }
            }
        }
    }

    private var mainGenreSection: some View {
        Group {
            Section("大ジャンル追加") {
                TextField("大ジャンル名", text: $newMainGenreName)
                Button("追加") {
                    if let error = dataStore.addMainGenre(name: newMainGenreName) {
                        showError(error)
                    } else {
                        newMainGenreName = ""
                    }
                }
            }

            Section("大ジャンル一覧") {
                ForEach(Array(dataStore.sortedMainGenres.enumerated()), id: \.element.id) { index, genre in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("ジャンル名", text: bindingForMainGenre(id: genre.id, fallback: genre.name))
                        HStack {
                            Button("保存") {
                                if let error = dataStore.updateMainGenre(
                                    id: genre.id,
                                    name: mainGenreDrafts[genre.id] ?? genre.name
                                ) {
                                    showError(error)
                                }
                            }
                            Button("上へ") {
                                dataStore.moveMainGenre(id: genre.id, direction: .up)
                            }
                            .disabled(index == 0)
                            Button("下へ") {
                                dataStore.moveMainGenre(id: genre.id, direction: .down)
                            }
                            .disabled(index == dataStore.sortedMainGenres.count - 1)
                            Spacer()
                            Button("削除", role: .destructive) {
                                if let error = dataStore.deleteMainGenre(id: genre.id) {
                                    showError(error)
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private var subGenreSection: some View {
        Group {
            Section("小ジャンル追加") {
                Picker("大ジャンル", selection: $newSubGenreMainId) {
                    ForEach(dataStore.sortedMainGenres) { genre in
                        Text(genre.name).tag(genre.id)
                    }
                }
                TextField("小ジャンル名", text: $newSubGenreName)
                Button("追加") {
                    if let error = dataStore.addSubGenre(mainGenreId: newSubGenreMainId, name: newSubGenreName) {
                        showError(error)
                    } else {
                        newSubGenreName = ""
                    }
                }
            }

            ForEach(dataStore.sortedMainGenres) { mainGenre in
                Section(mainGenre.name) {
                    let children = dataStore.subGenres(for: mainGenre.id)
                    if children.isEmpty {
                        Text("このジャンルに種類はありません。")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(children.enumerated()), id: \.element.id) { index, subGenre in
                            VStack(alignment: .leading, spacing: 8) {
                                TextField(
                                    "種類名",
                                    text: bindingForSubGenreName(id: subGenre.id, fallback: subGenre.name)
                                )
                                Picker(
                                    "紐づく大ジャンル",
                                    selection: bindingForSubGenreMain(id: subGenre.id, fallback: subGenre.mainGenreId)
                                ) {
                                    ForEach(dataStore.sortedMainGenres) { genre in
                                        Text(genre.name).tag(genre.id)
                                    }
                                }
                                HStack {
                                    Button("保存") {
                                        let draft = subGenreDrafts[subGenre.id]
                                            ?? SubGenreDraft(name: subGenre.name, mainGenreId: subGenre.mainGenreId)
                                        if let error = dataStore.updateSubGenre(
                                            id: subGenre.id,
                                            name: draft.name,
                                            mainGenreId: draft.mainGenreId
                                        ) {
                                            showError(error)
                                        }
                                    }
                                    Button("上へ") {
                                        dataStore.moveSubGenre(id: subGenre.id, direction: .up)
                                    }
                                    .disabled(index == 0)
                                    Button("下へ") {
                                        dataStore.moveSubGenre(id: subGenre.id, direction: .down)
                                    }
                                    .disabled(index == children.count - 1)
                                    Spacer()
                                    Button("削除", role: .destructive) {
                                        if let error = dataStore.deleteSubGenre(id: subGenre.id) {
                                            showError(error)
                                        }
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
    }

    private func syncDrafts() {
        syncMainGenreDrafts()
        syncSubGenreDrafts()
        if newSubGenreMainId.isEmpty {
            newSubGenreMainId = dataStore.sortedMainGenres.first?.id ?? ""
        }
    }

    private func syncMainGenreDrafts() {
        mainGenreDrafts = Dictionary(uniqueKeysWithValues: dataStore.sortedMainGenres.map { ($0.id, $0.name) })
    }

    private func syncSubGenreDrafts() {
        subGenreDrafts = Dictionary(
            uniqueKeysWithValues: dataStore.sortedSubGenres.map {
                ($0.id, SubGenreDraft(name: $0.name, mainGenreId: $0.mainGenreId))
            }
        )
        if !dataStore.sortedMainGenres.contains(where: { $0.id == newSubGenreMainId }) {
            newSubGenreMainId = dataStore.sortedMainGenres.first?.id ?? ""
        }
    }

    private func bindingForMainGenre(id: String, fallback: String) -> Binding<String> {
        Binding(
            get: { mainGenreDrafts[id] ?? fallback },
            set: { mainGenreDrafts[id] = $0 }
        )
    }

    private func bindingForSubGenreName(id: String, fallback: String) -> Binding<String> {
        Binding(
            get: { subGenreDrafts[id]?.name ?? fallback },
            set: { newValue in
                let current = subGenreDrafts[id] ?? SubGenreDraft(name: fallback, mainGenreId: "")
                subGenreDrafts[id] = SubGenreDraft(name: newValue, mainGenreId: current.mainGenreId)
            }
        )
    }

    private func bindingForSubGenreMain(id: String, fallback: String) -> Binding<String> {
        Binding(
            get: { subGenreDrafts[id]?.mainGenreId ?? fallback },
            set: { newValue in
                let current = subGenreDrafts[id] ?? SubGenreDraft(name: "", mainGenreId: fallback)
                subGenreDrafts[id] = SubGenreDraft(name: current.name, mainGenreId: newValue)
            }
        )
    }

    private func showError(_ message: String) {
        self.message = SettingsMessage(title: "操作できません", body: message)
    }
}

struct SubGenreDraft {
    var name: String
    var mainGenreId: String
}

struct SettingsMessage: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

struct StoreSettingsRow: View {
    @EnvironmentObject private var dataStore: GourmetDataStore
    let store: Store
    let onEdit: () -> Void
    let onArchive: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            StoreCardView(store: store, rankLabel: store.rank.label, style: .compact)

            Text("\(dataStore.mainGenreName(for: store.mainGenreId)) / \(dataStore.subGenreName(for: store.subGenreId))")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Button("編集", action: onEdit)
                Button("Archive", action: onArchive)
                    .disabled(store.rank == .archive)
                Spacer()
                Button("削除", role: .destructive, action: onDelete)
            }
            .buttonStyle(.bordered)
        }
    }
}
