import SwiftUI

enum AppTheme {
    static let background = Color(hex: "F6F7FB")
    static let ink = Color(hex: "16151A")
    static let muted = Color(hex: "6F6B7A")
    static let coral = Color(hex: "FF4D67")
    static let hotPink = Color(hex: "FF2F8E")
    static let mint = Color(hex: "34D399")
    static let lemon = Color(hex: "D9F99D")
    static let cyan = Color(hex: "38BDF8")
    static let card = Color.white.opacity(0.88)

    static let heroGradient = LinearGradient(
        colors: [Color(hex: "111111"), Color(hex: "FF4D67"), Color(hex: "38BDF8")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [hotPink, coral, mint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
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
        LinearGradient(
            colors: [AppTheme.background, Color.white, Color(hex: "EEF7FF")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

extension View {
    func modernCard(cornerRadius: CGFloat = 24) -> some View {
        self
            .background(.ultraThinMaterial)
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 10)
    }
}

struct ContentView: View {
    @EnvironmentObject private var dataStore: GourmetDataStore
    @State private var selectedMainGenreId = ""
    @State private var selectedSubGenreId = ""
    @State private var formSeed: StoreFormSeed?
    @State private var detailSeed: StoreDetailSeed?

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
                        heroSection
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
                    .padding(.top, 8)
                    .padding(.bottom, 96)
                }
                .scrollIndicators(.hidden)

                Button {
                    openForm(rank: firstTBDRank.map(StoreRank.ranked) ?? .archive)
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .accessibilityLabel("登録")
                        .foregroundStyle(.white)
                    .frame(width: 62, height: 62)
                    .background(hasSelectableCategory ? AppTheme.accentGradient : LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing))
                    .clipShape(Circle())
                    .shadow(color: AppTheme.hotPink.opacity(0.28), radius: 18, x: 0, y: 10)
                }
                .disabled(!hasSelectableCategory)
                .padding(20)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("設定")
                }
            }
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
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("MY GOURMET")
                        .font(.caption.bold())
                        .tracking(1.8)
                        .foregroundStyle(.white.opacity(0.72))
                    Text("いま一番うまい店を、\n5つだけ残す。")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineSpacing(2)
                        .minimumScaleFactor(0.86)
                }
                Spacer()
                Image(systemName: "sparkles")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.lemon)
                    .padding(12)
                    .background(.white.opacity(0.14))
                    .clipShape(Circle())
            }

            HStack(spacing: 10) {
                MetricPill(value: "\(rankedCount)/5", label: "Best")
                MetricPill(value: "\(archiveStores.count)", label: "Archive")
                MetricPill(value: selectedSubGenre?.name ?? "未設定", label: selectedMainGenre?.name ?? "Genre")
            }
        }
        .padding(22)
        .background(AppTheme.heroGradient)
        .overlay(alignment: .bottomTrailing) {
            Text("Best5")
                .font(.system(size: 56, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.08))
                .padding(.trailing, 8)
                .padding(.bottom, 4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: AppTheme.coral.opacity(0.28), radius: 24, x: 0, y: 16)
    }

    private var selectorSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Menu {
                    ForEach(dataStore.sortedMainGenres) { genre in
                        Button(genre.name) {
                            selectedMainGenreId = genre.id
                            selectedSubGenreId = preferredSubGenreId(for: genre.id)
                        }
                    }
                } label: {
                    SelectorChip(title: selectedMainGenre?.name ?? "大ジャンル", icon: "fork.knife")
                }

                Menu {
                    ForEach(availableSubGenres) { subGenre in
                        Button(subGenre.name) {
                            selectedSubGenreId = subGenre.id
                        }
                    }
                } label: {
                    SelectorChip(title: selectedSubGenre?.name ?? "小ジャンル", icon: "tag")
                }
                .disabled(availableSubGenres.isEmpty)
            }

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(availableSubGenres) { subGenre in
                        Button {
                            selectedSubGenreId = subGenre.id
                        } label: {
                            Text(subGenre.name)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(selectedSubGenreId == subGenre.id ? .white : AppTheme.ink)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(selectedSubGenreId == subGenre.id ? AnyShapeStyle(AppTheme.accentGradient) : AnyShapeStyle(.ultraThinMaterial))
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
        VStack(alignment: .leading, spacing: 12) {
            SectionTitleView(
                title: "\(selectedSubGenre?.name ?? "未設定") Best5",
                subtitle: selectedMainGenre?.name ?? "未設定",
                count: "\(rankedCount)/5"
            )

            ForEach(bestRows) { row in
                switch row {
                case .store(let rank, let store):
                    Button {
                        detailSeed = StoreDetailSeed(id: store.id)
                    } label: {
                        StoreCardView(store: store, rankLabel: "\(rank)位", style: .best)
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

    private var archiveSection: some View {
        VStack(alignment: .leading, spacing: 12) {
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

struct MetricPill: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.headline.bold())
                .lineLimit(1)
            Text(label)
                .font(.caption2.bold())
                .foregroundStyle(.white.opacity(0.68))
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.white.opacity(0.13))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct SelectorChip: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline.bold())
                .foregroundStyle(AppTheme.coral)
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(AppTheme.ink)
                .lineLimit(1)
            Image(systemName: "chevron.down")
                .font(.caption.bold())
                .foregroundStyle(AppTheme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .modernCard(cornerRadius: 18)
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
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.coral)
                    .tracking(0.8)
                Text(title)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
            }
            Spacer()
            Text(count)
                .font(.subheadline.bold())
                .foregroundStyle(AppTheme.ink)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.lemon)
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

struct StoreCardView: View {
    let store: Store
    let rankLabel: String
    var style: StoreCardStyle = .best

    private var imageSize: CGFloat {
        switch style {
        case .best: 92
        case .archive: 72
        case .compact: 62
        }
    }

    private var isFirstRank: Bool {
        rankLabel == "1位"
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack(alignment: .topLeading) {
                ThumbnailView(imageUrl: store.imageUrl, name: store.name, size: imageSize)
                if style == .best {
                    Text(rankLabel)
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(isFirstRank ? AppTheme.accentGradient : LinearGradient(colors: [AppTheme.ink.opacity(0.86), AppTheme.ink.opacity(0.64)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .clipShape(Capsule())
                        .padding(6)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 7) {
                    if style != .best {
                        Text(rankLabel)
                            .font(.caption.bold())
                            .foregroundStyle(style == .archive ? AppTheme.muted : AppTheme.coral)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Capsule())
                    }
                    Text(store.area ?? "エリア未登録")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.muted)
                        .lineLimit(1)
                }

                Text(store.name)
                    .font(.system(size: style == .best ? 19 : 16, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)
                Text(store.memo ?? "メモ未登録")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)

            if style == .best {
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.muted.opacity(0.65))
            }
        }
        .padding(style == .compact ? 10 : 14)
        .modernCard(cornerRadius: style == .compact ? 18 : 24)
        .overlay {
            RoundedRectangle(cornerRadius: style == .compact ? 18 : 24, style: .continuous)
                .stroke(isFirstRank ? AppTheme.hotPink.opacity(0.35) : Color.white.opacity(0.45), lineWidth: 1)
        }
        .opacity(style == .archive ? 0.9 : 1)
    }
}

struct TBDCardView: View {
    let rank: Int

    var body: some View {
        HStack(spacing: 14) {
            Text("\(rank)位")
                .font(.headline.bold())
                .foregroundStyle(AppTheme.coral)
                .frame(width: 58, height: 58)
                .background(AppTheme.coral.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("TBD")
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.ink)
                Text("この順位に店舗を登録")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)
            }
            Spacer()

            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundStyle(AppTheme.coral)
        }
        .padding(14)
        .background(.white.opacity(0.72))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.coral.opacity(0.35), style: StrokeStyle(lineWidth: 1.3, dash: [7]))
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct ThumbnailView: View {
    let imageUrl: String?
    let name: String
    let size: CGFloat

    var body: some View {
        Group {
            if let imageUrl, let url = URL(string: imageUrl) {
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
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: min(22, size / 3.5), style: .continuous))
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(colors: [AppTheme.coral.opacity(0.18), AppTheme.cyan.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: "fork.knife")
                .font(.title3.bold())
                .foregroundStyle(AppTheme.coral)
        }
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
    @State private var imageUrl: String
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
        _imageUrl = State(initialValue: seed.store?.imageUrl ?? "")
        _memo = State(initialValue: seed.store?.memo ?? "")
        _mapUrl = State(initialValue: seed.store?.mapUrl ?? "")
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
                    TextField("サムネイル画像URL", text: $imageUrl, axis: .vertical)
                    TextField("Google Map URL", text: $mapUrl, axis: .vertical)
                    TextField("一言メモ", text: $memo, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppBackgroundView())
            .tint(AppTheme.coral)
            .navigationTitle(seed.store == nil ? "店舗を登録" : "店舗を編集")
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

        dataStore.saveStore(
            StoreFormData(
                name: name,
                mainGenreId: mainGenreId,
                subGenreId: subGenreId,
                rank: rank,
                area: area,
                memo: memo,
                imageUrl: imageUrl,
                mapUrl: mapUrl
            ),
            editingStoreId: seed.store?.id
        )
        dismiss()
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
                                DetailHeroImage(imageUrl: store.imageUrl, name: store.name)
                                LinearGradient(colors: [.clear, .black.opacity(0.78)], startPoint: .center, endPoint: .bottom)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(store.rank.label)
                                        .font(.caption.bold())
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(AppTheme.accentGradient)
                                        .clipShape(Capsule())
                                    Text(store.name)
                                        .font(.system(size: 30, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                        .lineLimit(2)
                                }
                                .padding(18)
                            }
                            .frame(height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))

                            VStack(alignment: .leading, spacing: 12) {
                                detailRow("大ジャンル", dataStore.mainGenreName(for: store.mainGenreId))
                                detailRow("小ジャンル", dataStore.subGenreName(for: store.subGenreId))
                                detailRow("現在順位", store.rank.label)
                                detailRow("元順位", store.previousRank.map { "\($0)位" } ?? "未ランクイン")
                                detailRow("エリア", store.area ?? "未登録")
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
                .font(.caption.bold())
                .foregroundStyle(AppTheme.coral)
            Text(value)
                .font(.body)
                .foregroundStyle(AppTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .modernCard(cornerRadius: 18)
    }
}

struct DetailHeroImage: View {
    let imageUrl: String?
    let name: String

    var body: some View {
        Group {
            if let imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Rectangle()
                            .fill(AppTheme.heroGradient)
                    }
                }
            } else {
                Rectangle()
                    .fill(AppTheme.heroGradient)
            }
        }
        .accessibilityLabel(name)
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
            Picker("設定セクション", selection: $selectedTab) {
                ForEach(SettingsTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()

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
        .tint(AppTheme.coral)
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
