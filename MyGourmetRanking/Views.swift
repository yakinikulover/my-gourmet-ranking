import SwiftUI
import PhotosUI
import UIKit

enum AppTheme {
    static let background = Color.white
    static let ink = Color.black
    static let muted = Color(hex: "657786")
    static let softText = Color(hex: "536471")
    static let hairline = Color(hex: "EFF3F4")
    static let softFill = Color(hex: "F7F9F9")
    static let card = Color.white
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
        AppTheme.background.ignoresSafeArea()
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
                    VStack(alignment: .leading, spacing: 18) {
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
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    .padding(.bottom, 96)
                }

                Button {
                    openForm(rank: firstTBDRank.map(StoreRank.ranked) ?? .archive)
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .accessibilityLabel("登録")
                        .foregroundStyle(.white)
                    .frame(width: 62, height: 62)
                    .background(hasSelectableCategory ? AppTheme.ink : Color.gray)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.16), radius: 14, x: 0, y: 8)
                }
                .disabled(!hasSelectableCategory)
                .padding(20)
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
                    selectedSubGenreId: $selectedSubGenreId
                )
                .environmentObject(dataStore)
                .presentationDetents([.medium, .large])
            }
        }
    }

    private var selectorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Button {
                    isGenrePickerPresented = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.headline)
                            .foregroundStyle(AppTheme.softText)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(selectedSubGenre?.name ?? "ジャンルを選択")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppTheme.ink)
                                .lineLimit(1)
                            Text(selectedMainGenre?.name ?? "料理ジャンル")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(AppTheme.softText)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 0)
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.muted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 4)

                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                        .frame(width: 36, height: 36)
                        .background(AppTheme.softFill)
                        .clipShape(Circle())
                }
                .accessibilityLabel("設定")
            }
            .padding(.leading, 14)
            .padding(.trailing, 8)
            .padding(.vertical, 8)
            .background(AppTheme.softFill)
            .clipShape(Capsule())

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(availableSubGenres) { subGenre in
                        Button {
                            selectedSubGenreId = subGenre.id
                        } label: {
                            Text(subGenre.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(selectedSubGenreId == subGenre.id ? .white : AppTheme.ink)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(selectedSubGenreId == subGenre.id ? AppTheme.ink : AppTheme.softFill)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var bestSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Best5")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                Text("\(rankedCount)/5")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.ink)
                    .clipShape(Capsule())
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
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.hairline, lineWidth: 1)
            }
        }
    }

    private var archiveSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitleView(title: "Archive", subtitle: "Best5外の記録", count: "\(archiveStores.count)")

            if archiveStores.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Archiveの店舗はまだありません。")
                        .font(.headline)
                    Text("Best5から外した店や未ランクインの店がここに残ります。")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .modernCard()
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
                .background(AppTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppTheme.hairline, lineWidth: 1)
                }
            }
        }
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

struct GenrePickerSheet: View {
    @EnvironmentObject private var dataStore: GourmetDataStore
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMainGenreId: String
    @Binding var selectedSubGenreId: String
    @State private var searchText = ""

    private var normalizedQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var visibleMainGenres: [MainGenre] {
        guard !normalizedQuery.isEmpty else {
            return dataStore.sortedMainGenres
        }

        return dataStore.sortedMainGenres.filter { mainGenre in
            mainGenre.name.lowercased().contains(normalizedQuery)
                || dataStore.subGenres(for: mainGenre.id).contains {
                    $0.name.lowercased().contains(normalizedQuery)
                }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchField

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        mainGenreChips

                        ForEach(visibleMainGenres) { mainGenre in
                            let subGenres = visibleSubGenres(for: mainGenre)
                            if !subGenres.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(mainGenre.name)
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(AppTheme.ink)
                                        .padding(.horizontal, 2)

                                    VStack(spacing: 0) {
                                        ForEach(subGenres) { subGenre in
                                            Button {
                                                selectedMainGenreId = mainGenre.id
                                                selectedSubGenreId = subGenre.id
                                                dismiss()
                                            } label: {
                                                HStack(spacing: 12) {
                                                    Text(subGenre.name)
                                                        .font(.body.weight(.semibold))
                                                        .foregroundStyle(AppTheme.ink)
                                                    Spacer()
                                                    if selectedMainGenreId == mainGenre.id && selectedSubGenreId == subGenre.id {
                                                        Image(systemName: "checkmark")
                                                            .font(.body.weight(.bold))
                                                            .foregroundStyle(AppTheme.ink)
                                                    }
                                                }
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 13)
                                                .contentShape(Rectangle())
                                            }
                                            .buttonStyle(.plain)

                                            if subGenre.id != subGenres.last?.id {
                                                Rectangle()
                                                    .fill(AppTheme.hairline)
                                                    .frame(height: 1)
                                                    .padding(.leading, 14)
                                            }
                                        }
                                    }
                                    .background(AppTheme.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(AppTheme.hairline, lineWidth: 1)
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .background(AppBackgroundView())
            .navigationTitle("ジャンルを選択")
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

    private var mainGenreChips: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(dataStore.sortedMainGenres) { mainGenre in
                    Button {
                        selectedMainGenreId = mainGenre.id
                        selectedSubGenreId = dataStore.subGenres(for: mainGenre.id).first?.id ?? ""
                        searchText = ""
                    } label: {
                        Text(mainGenre.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selectedMainGenreId == mainGenre.id ? .white : AppTheme.ink)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(selectedMainGenreId == mainGenre.id ? AppTheme.ink : AppTheme.softFill)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
    }

    private func visibleSubGenres(for mainGenre: MainGenre) -> [SubGenre] {
        let subGenres = dataStore.subGenres(for: mainGenre.id)
        guard !normalizedQuery.isEmpty else {
            return subGenres
        }

        if mainGenre.name.lowercased().contains(normalizedQuery) {
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
            return style == .archive ? 58 : 54
        }

        return 76
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
            return 12
        }

        return 14
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
        .background(AppTheme.card)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppTheme.hairline)
                .frame(height: 1)
                .padding(.leading, style == .best ? rowPadding : 0)
        }
        .opacity(style == .archive ? 0.9 : 1)
    }

    private var bestCardBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                rankBadge
                Text(store.name)
                    .font(.system(size: titleSize, weight: .semibold))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.muted.opacity(0.55))
            }

            HStack(alignment: .top, spacing: 14) {
                ThumbnailView(source: store.primaryImageSource, name: store.name, size: imageSize)

                VStack(alignment: .leading, spacing: verticalSpacing) {
                    Text(store.area ?? "エリア未登録")
                        .font(.caption)
                        .foregroundStyle(AppTheme.softText)
                        .lineLimit(1)
                    Text(store.memo ?? "メモ未登録")
                        .font(memoFont)
                        .foregroundStyle(AppTheme.softText)
                        .lineLimit(2, reservesSpace: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var compactCardBody: some View {
        HStack(alignment: .top, spacing: 12) {
            ThumbnailView(source: store.primaryImageSource, name: store.name, size: imageSize)

            VStack(alignment: .leading, spacing: verticalSpacing) {
                HStack(spacing: 7) {
                    rankBadge
                    Text(store.area ?? "エリア未登録")
                        .font(.caption)
                        .foregroundStyle(AppTheme.softText)
                        .lineLimit(1)
                }

                Text(store.name)
                    .font(.system(size: titleSize, weight: .semibold))
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
                Text("\(rank)位")
                    .font(.system(size: titleSize, weight: .semibold))
                    .foregroundStyle(AppTheme.ink)
                    .frame(width: 42, alignment: .leading)
            } else {
                Text(rankLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.softText)
            }
        }
    }
}

struct TBDCardView: View {
    let rank: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Text("\(rank)位")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.ink)
                    .frame(width: 42, alignment: .leading)
                Text("TBD")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                Image(systemName: "plus")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.ink)
            }

            HStack(alignment: .top, spacing: 14) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppTheme.softFill)
                    .frame(width: 76, height: 76)
                    .overlay {
                        Image(systemName: "fork.knife")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppTheme.softText)
                    }

                Text("この順位に店舗を登録")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.softText)
                    .lineLimit(2, reservesSpace: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(14)
        .background(AppTheme.card)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppTheme.hairline)
                .frame(height: 1)
                .padding(.leading, 14)
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

    var body: some View {
        Group {
            switch source {
            case .local(let fileName):
                if let image = ImageStorage.image(for: fileName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    placeholder
                }
            case .remote(let imageUrl):
                if let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
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
    @State private var selectedTagIds: Set<String>
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
        _selectedTagIds = State(initialValue: Set(seed.store?.tagIds ?? []))
    }

    private var availableSubGenres: [SubGenre] {
        dataStore.subGenres(for: mainGenreId)
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
                    }

                    Picker("小ジャンル", selection: $subGenreId) {
                        ForEach(availableSubGenres) { subGenre in
                            Text(subGenre.name).tag(subGenre.id)
                        }
                    }

                    Picker("順位", selection: $rank) {
                        ForEach(StoreRank.allCases) { rank in
                            Text(rank.label).tag(rank)
                        }
                    }
                }

                Section("店舗メモ") {
                    TextField("エリア", text: $area)
                    TextField("Google Map URL", text: $mapUrl, axis: .vertical)
                    TextField("一言メモ", text: $memo, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("用途タグ") {
                    if dataStore.sortedOccasionTags.isEmpty {
                        Text("設定画面で用途タグを追加できます。")
                            .foregroundStyle(AppTheme.softText)
                    } else {
                        ForEach(dataStore.sortedOccasionTags) { tag in
                            Button {
                                toggleTag(tag.id)
                            } label: {
                                HStack {
                                    Text(tag.name)
                                        .foregroundStyle(AppTheme.ink)
                                    Spacer()
                                    if selectedTagIds.contains(tag.id) {
                                        Image(systemName: "checkmark")
                                            .font(.body.weight(.semibold))
                                            .foregroundStyle(AppTheme.ink)
                                    }
                                }
                            }
                        }
                    }
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
                mapUrl: mapUrl,
                tagIds: orderedSelectedTagIds()
            ),
            editingStoreId: seed.store?.id
        )
        dismiss()
    }

    private func toggleTag(_ tagId: String) {
        if selectedTagIds.contains(tagId) {
            selectedTagIds.remove(tagId)
        } else {
            selectedTagIds.insert(tagId)
        }
    }

    private func orderedSelectedTagIds() -> [String] {
        dataStore.sortedOccasionTags.map(\.id).filter { selectedTagIds.contains($0) }
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
                        VStack(alignment: .leading, spacing: 18) {
                            ZStack(alignment: .bottomLeading) {
                                DetailHeroImage(store: store)
                                LinearGradient(colors: [.clear, .black.opacity(0.78)], startPoint: .center, endPoint: .bottom)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(store.rank.label)
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(AppTheme.ink)
                                        .clipShape(Capsule())
                                    Text(store.name)
                                        .font(.system(size: 30, weight: .bold))
                                        .foregroundStyle(.white)
                                        .lineLimit(2)
                                }
                                .padding(18)
                            }
                            .frame(height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                            VStack(alignment: .leading, spacing: 12) {
                                detailRow("大ジャンル", dataStore.mainGenreName(for: store.mainGenreId))
                                detailRow("小ジャンル", dataStore.subGenreName(for: store.subGenreId))
                                detailRow("現在順位", store.rank.label)
                                detailRow("元順位", store.previousRank.map { "\($0)位" } ?? "未ランクイン")
                                detailRow("エリア", store.area ?? "未登録")
                                detailRow("用途タグ", tagText(for: store))
                                detailRow("メモ", store.memo ?? "未登録")

                                if let mapUrl = store.mapUrl, let url = URL(string: mapUrl) {
                                    Link("Google Map URLを開く", destination: url)
                                        .font(.headline)
                                } else {
                                    detailRow("Google Map URL", "未登録")
                                }
                            }

                            VStack(spacing: 10) {
                                Button {
                                    formSeed = StoreFormSeed(store: store)
                                } label: {
                                    Label("編集", systemImage: "square.and.pencil")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)

                                Button {
                                    dataStore.archiveStore(store.id)
                                    dismiss()
                                } label: {
                                    Label("Archiveへ移動", systemImage: "archivebox")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .disabled(store.rank == .archive)

                                Button(role: .destructive) {
                                    dataStore.deleteStore(store.id)
                                    dismiss()
                                } label: {
                                    Label("削除", systemImage: "trash")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(.top, 8)
                        }
                        .padding()
                    }
                    .background(AppBackgroundView())
                } else {
                    ContentUnavailableView("店舗が見つかりません", systemImage: "questionmark.folder")
                }
            }
            .navigationTitle(store?.name ?? "詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
            .sheet(item: $formSeed) { seed in
                StoreFormView(seed: seed)
                    .environmentObject(dataStore)
            }
        }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.softText)
            Text(value)
                .font(.body)
                .foregroundStyle(AppTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .modernCard(cornerRadius: 18)
    }

    private func tagText(for store: Store) -> String {
        let tagNames = dataStore.tagNames(for: store.tagIds)
        return tagNames.isEmpty ? "未登録" : tagNames.joined(separator: " / ")
    }
}

struct DetailHeroImage: View {
    let store: Store

    var body: some View {
        GeometryReader { proxy in
            let sources = store.imageSources
            if sources.count > 1 {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(sources) { source in
                            StoreImageContent(source: source, name: store.name, placeholder: Rectangle().fill(AppTheme.softFill))
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .clipped()
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.paging)
            } else {
                StoreImageContent(
                    source: sources.first,
                    name: store.name,
                    placeholder: Rectangle().fill(AppTheme.softFill)
                )
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
            }
        }
    }
}

enum SettingsTab: String, CaseIterable, Identifiable {
    case stores = "登録データ編集"
    case mainGenres = "ジャンル編集"
    case subGenres = "種類編集"
    case tags = "タグ編集"

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
    @State private var tagFilter = ""

    @State private var newMainGenreName = ""
    @State private var mainGenreDrafts: [String: String] = [:]

    @State private var newSubGenreName = ""
    @State private var newSubGenreMainId = ""
    @State private var subGenreDrafts: [String: SubGenreDraft] = [:]

    @State private var newTagName = ""
    @State private var tagDrafts: [String: String] = [:]

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
            let matchesTag = tagFilter.isEmpty || (store.tagIds ?? []).contains(tagFilter)
            return matchesSearch && matchesMainGenre && matchesSubGenre && matchesRank && matchesTag
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
                case .tags:
                    tagSection
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
        .onChange(of: dataStore.sortedOccasionTags) { _, _ in syncTagDrafts() }
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

                Picker("用途タグ", selection: $tagFilter) {
                    Text("すべて").tag("")
                    ForEach(dataStore.sortedOccasionTags) { tag in
                        Text(tag.name).tag(tag.id)
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

    private var tagSection: some View {
        Group {
            Section("用途タグ追加") {
                TextField("タグ名", text: $newTagName)
                Button("追加") {
                    if let error = dataStore.addOccasionTag(name: newTagName) {
                        showError(error)
                    } else {
                        newTagName = ""
                    }
                }
            }

            Section("用途タグ一覧") {
                if dataStore.sortedOccasionTags.isEmpty {
                    Text("用途タグはまだありません。")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(dataStore.sortedOccasionTags.enumerated()), id: \.element.id) { index, tag in
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("タグ名", text: bindingForTag(id: tag.id, fallback: tag.name))
                            HStack {
                                Button("保存") {
                                    if let error = dataStore.updateOccasionTag(
                                        id: tag.id,
                                        name: tagDrafts[tag.id] ?? tag.name
                                    ) {
                                        showError(error)
                                    }
                                }
                                Button("上へ") {
                                    dataStore.moveOccasionTag(id: tag.id, direction: .up)
                                }
                                .disabled(index == 0)
                                Button("下へ") {
                                    dataStore.moveOccasionTag(id: tag.id, direction: .down)
                                }
                                .disabled(index == dataStore.sortedOccasionTags.count - 1)
                                Spacer()
                                Button("削除", role: .destructive) {
                                    dataStore.deleteOccasionTag(id: tag.id)
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

    private func syncDrafts() {
        syncMainGenreDrafts()
        syncSubGenreDrafts()
        syncTagDrafts()
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

    private func syncTagDrafts() {
        tagDrafts = Dictionary(uniqueKeysWithValues: dataStore.sortedOccasionTags.map { ($0.id, $0.name) })
        if !dataStore.sortedOccasionTags.contains(where: { $0.id == tagFilter }) {
            tagFilter = ""
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

    private func bindingForTag(id: String, fallback: String) -> Binding<String> {
        Binding(
            get: { tagDrafts[id] ?? fallback },
            set: { tagDrafts[id] = $0 }
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

            let tagNames = dataStore.tagNames(for: store.tagIds)
            if !tagNames.isEmpty {
                Text(tagNames.joined(separator: " / "))
                    .font(.caption)
                    .foregroundStyle(AppTheme.softText)
            }

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
