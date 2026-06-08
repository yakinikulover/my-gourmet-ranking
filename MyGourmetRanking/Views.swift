import SwiftUI
import PhotosUI
import UIKit
import MapKit
import CoreLocation

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
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainTabs
            } else {
                OnboardingView {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                        hasCompletedOnboarding = true
                    }
                }
            }
        }
    }

    private var mainTabs: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "list.star")
                }

            GourmetMapView()
                .tabItem {
                    Label("グルメMap", systemImage: "map")
                }

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "slider.horizontal.3")
                }
        }
        .tint(AppTheme.tomato)
    }
}

private struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var selectedPage = 0

    private let pages = OnboardingPage.samplePages

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                HStack {
                    Button("スキップ") {
                        onFinish()
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.softText)

                    Spacer()

                    Text("My Gourmet Ranking")
                        .font(.caption.weight(.black))
                        .tracking(1.2)
                        .foregroundStyle(AppTheme.tomato)
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 6)

                TabView(selection: $selectedPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: 18) {
                    HStack(spacing: 7) {
                        ForEach(pages.indices, id: \.self) { index in
                            Capsule()
                                .fill(index == selectedPage ? AppTheme.tomato : AppTheme.hairline)
                                .frame(width: index == selectedPage ? 24 : 7, height: 7)
                                .animation(.spring(response: 0.32, dampingFraction: 0.82), value: selectedPage)
                        }
                    }

                    Button {
                        if selectedPage == pages.count - 1 {
                            onFinish()
                        } else {
                            withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                                selectedPage += 1
                            }
                        }
                    } label: {
                        Text(selectedPage == pages.count - 1 ? "はじめる" : "次へ")
                            .font(.headline.weight(.black))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(AppTheme.tomato, in: Capsule())
                            .shadow(color: AppTheme.tomato.opacity(0.24), radius: 16, y: 8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let eyebrow: String
    let title: String
    let body: String
    let accent: Color
    let systemImage: String
    let style: OnboardingVisualStyle

    static let samplePages: [OnboardingPage] = [
        .init(
            eyebrow: "WELCOME",
            title: "自分だけの、うまい店帳。",
            body: "行った店を忘れない。ジャンルごとにBest5を育てて、あなたの食の記録を一冊に。",
            accent: AppTheme.tomato,
            systemImage: "fork.knife",
            style: .welcome
        ),
        .init(
            eyebrow: "BEST 5",
            title: "順位で残すと、記憶が濃くなる。",
            body: "1位から5位まで、TBDも含めて見やすく管理。迷ったら、今の好きで並べればOK。",
            accent: AppTheme.ink,
            systemImage: "list.number",
            style: .ranking
        ),
        .init(
            eyebrow: "GOURMET MAP",
            title: "行った店が、地図に育つ。",
            body: "保存したお店はMapへ。街ごとの記憶や、また行きたい場所が一目で見える。",
            accent: AppTheme.olive,
            systemImage: "map.fill",
            style: .map
        ),
        .init(
            eyebrow: "ARCHIVE",
            title: "Best外の名店も、ちゃんと残す。",
            body: "過去の名店、惜しくも圏外の店、いつかまた行きたい店。Archiveで自分の食史に。",
            accent: AppTheme.tomato,
            systemImage: "archivebox.fill",
            style: .archive
        )
    ]
}

private enum OnboardingVisualStyle {
    case welcome
    case ranking
    case map
    case archive
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            OnboardingVisual(page: page)
                .frame(maxWidth: .infinity)
                .frame(height: 330)
                .padding(.top, 10)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: page.systemImage)
                    Text(page.eyebrow)
                }
                .font(.caption.weight(.black))
                .tracking(1.2)
                .foregroundStyle(page.accent)

                Text(page.title)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(page.body)
                    .font(.body.weight(.medium))
                    .foregroundStyle(AppTheme.softText)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 0)
        }
    }
}

private struct OnboardingVisual: View {
    let page: OnboardingPage

    var body: some View {
        ZStack {
            Circle()
                .fill(page.accent.opacity(0.08))
                .frame(width: 280, height: 280)
                .offset(x: 55, y: -24)
            Circle()
                .fill(AppTheme.olive.opacity(0.08))
                .frame(width: 180, height: 180)
                .offset(x: -90, y: 72)

            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(AppTheme.card.opacity(0.92))
                .frame(width: 268, height: 286)
                .rotationEffect(.degrees(-2))
                .shadow(color: AppTheme.ink.opacity(0.09), radius: 22, y: 14)

            DashedDivider(color: AppTheme.hairline)
                .frame(width: 235)
                .rotationEffect(.degrees(-2))
                .offset(y: -106)

            TapeDecoration(color: AppTheme.tape)
                .scaleEffect(1.18)
                .offset(x: -65, y: -138)

            visualContent

            Image(systemName: "sparkles")
                .font(.title2.weight(.black))
                .foregroundStyle(page.accent)
                .rotationEffect(.degrees(-12))
                .offset(x: -132, y: -118)

            Image(systemName: "arrow.down.right")
                .font(.title3.weight(.black))
                .foregroundStyle(AppTheme.olive)
                .rotationEffect(.degrees(-10))
                .offset(x: 126, y: -90)
        }
    }

    @ViewBuilder
    private var visualContent: some View {
        switch page.style {
        case .welcome:
            ZStack {
                FoodTile(title: "寿司", color: AppTheme.tomato, icon: "takeoutbag.and.cup.and.straw.fill")
                    .offset(x: -62, y: -48)
                    .rotationEffect(.degrees(-8))
                FoodTile(title: "焼肉", color: AppTheme.ink, icon: "flame.fill")
                    .offset(x: 58, y: -12)
                    .rotationEffect(.degrees(7))
                FoodTile(title: "カフェ", color: AppTheme.olive, icon: "cup.and.saucer.fill")
                    .offset(x: -2, y: 70)
                    .rotationEffect(.degrees(-2))
            }
        case .ranking:
            VStack(spacing: 10) {
                ForEach(1...5, id: \.self) { rank in
                    HStack(spacing: 12) {
                        Text("\(rank)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(rank <= 3 ? AppTheme.tomato : AppTheme.ink)
                            .frame(width: 30)
                        RoundedRectangle(cornerRadius: 10)
                            .fill(rank == 1 ? AppTheme.tomato.opacity(0.18) : AppTheme.softFill)
                            .frame(width: rank == 1 ? 118 : 92, height: 20)
                        Spacer()
                    }
                    .frame(width: 200)
                }
            }
            .padding(.top, 10)
        case .map:
            ZStack {
                ForEach(0..<4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(AppTheme.hairline, lineWidth: 1)
                        .frame(width: 210, height: 1)
                        .rotationEffect(.degrees(Double(index * 18 - 24)))
                        .offset(y: CGFloat(index * 34 - 48))
                }
                MapPinLabel(text: "1", color: AppTheme.tomato)
                    .offset(x: -48, y: -28)
                MapPinLabel(text: "A", color: AppTheme.olive)
                    .offset(x: 54, y: 38)
                MapPinLabel(text: "5", color: AppTheme.ink)
                    .offset(x: 20, y: -78)
            }
        case .archive:
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "archivebox.fill")
                        .foregroundStyle(AppTheme.olive)
                    Text("Archive")
                        .font(.title2.weight(.black))
                }
                ForEach(["元 1位  浅草の名店", "未ランクイン  深夜飯", "元 4位  また行きたい"], id: \.self) { text in
                    Text(text)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.ink)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(AppTheme.softFill, in: Capsule())
                }
            }
        }
    }
}

private struct FoodTile: View {
    let title: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2.weight(.black))
                .foregroundStyle(color)
            Text(title)
                .font(.caption.weight(.black))
                .foregroundStyle(AppTheme.ink)
        }
        .frame(width: 98, height: 88)
        .background(AppTheme.softFill, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(alignment: .top) {
            TapeDecoration()
                .offset(y: -6)
        }
    }
}

private struct MapPinLabel: View {
    let text: String
    let color: Color

    var body: some View {
        VStack(spacing: 0) {
            Text(text)
                .font(.headline.weight(.black))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(color, in: Circle())
            Triangle()
                .fill(color)
                .frame(width: 15, height: 11)
                .rotationEffect(.degrees(180))
                .offset(y: -2)
        }
        .shadow(color: color.opacity(0.25), radius: 10, y: 5)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct HomeView: View {
    @EnvironmentObject private var dataStore: GourmetDataStore
    @EnvironmentObject private var proState: ProState
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
                    .environmentObject(proState)
            }
            .sheet(item: $detailSeed) { seed in
                StoreDetailView(storeId: seed.id)
                    .environmentObject(dataStore)
                    .environmentObject(proState)
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

            DashedDivider()
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

private enum GourmetMapFilterSheet: String, Identifiable {
    case genre
    case rank

    var id: String { rawValue }
}

struct GourmetMapView: View {
    @EnvironmentObject private var dataStore: GourmetDataStore
    @EnvironmentObject private var proState: ProState
    @StateObject private var locationManager = LocationManager()
    @State private var selectedMainGenreId: String?
    @State private var selectedSubGenreId: String?
    @State private var selectedRank: StoreRank?
    @State private var presentedFilterSheet: GourmetMapFilterSheet?
    @State private var selectedStoreId: String?
    @State private var detailSeed: StoreDetailSeed?
    @State private var isOrganizerPresented = false
    @State private var isNearbyRegistrationPresented = false
    @State private var paywallReason: PaywallReason?
    @State private var nearbyStoreCandidate: LocationSearchCandidate?
    @State private var nearbyFormSeed: StoreFormSeed?
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
            span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
        )
    )

    private var mappedStores: [Store] {
        dataStore.stores.filter { store in
            guard store.coordinate != nil else { return false }
            if !proState.isPro, store.rank != .rank1 { return false }
            if let selectedMainGenreId, store.mainGenreId != selectedMainGenreId { return false }
            if let selectedSubGenreId, store.subGenreId != selectedSubGenreId { return false }
            if let selectedRank, store.rank != selectedRank { return false }
            return true
        }
    }

    private var hasActiveFilters: Bool {
        selectedMainGenreId != nil || selectedSubGenreId != nil || selectedRank != nil
    }

    private var genreFilterLabel: String {
        if let selectedSubGenreId {
            return dataStore.subGenreName(for: selectedSubGenreId)
        }
        if let selectedMainGenreId {
            return dataStore.mainGenreName(for: selectedMainGenreId)
        }
        return "ジャンル"
    }

    private var rankFilterLabel: String {
        selectedRank?.label ?? "順位"
    }

    private var selectedStore: Store? {
        dataStore.stores.first { $0.id == selectedStoreId }
    }

    private var unregisteredMapCount: Int {
        dataStore.stores.filter { $0.coordinate == nil }.count
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $cameraPosition, selection: $selectedStoreId) {
                    ForEach(mappedStores) { store in
                        if let coordinate = store.coordinate {
                            Annotation(store.name, coordinate: coordinate) {
                                GourmetMapPin(store: store, isSelected: selectedStoreId == store.id)
                            }
                            .tag(store.id)
                        }
                    }
                }
                .mapStyle(.standard(pointsOfInterest: .excludingAll))
                .ignoresSafeArea(edges: .bottom)

                if mappedStores.isEmpty {
                    ContentUnavailableView(
                        "地図登録済みの店舗がありません",
                        systemImage: "map",
                        description: Text("店舗の登録・編集画面から場所を検索すると、ここにピンが表示されます。")
                    )
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                    .padding()
                }

                if let selectedStore {
                    Button {
                        detailSeed = StoreDetailSeed(id: selectedStore.id)
                    } label: {
                        GourmetMapStoreCard(store: selectedStore)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 12)
                }

                HStack {
                    Spacer()
                    Button {
                        if proState.isPro {
                            isNearbyRegistrationPresented = true
                        } else {
                            paywallReason = .mapFullAccess
                        }
                    } label: {
                        Label("近くで登録", systemImage: "location.fill")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 11)
                            .background(AppTheme.tomato, in: Capsule())
                            .shadow(color: AppTheme.tomato.opacity(0.25), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, selectedStore == nil ? 14 : 110)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                mapFilterBar
            }
            .navigationTitle("グルメMap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if proState.isPro {
                            isOrganizerPresented = true
                        } else {
                            paywallReason = .mapFullAccess
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "tray.and.arrow.down")
                                .font(.caption.weight(.bold))
                            Text("未登録")
                                .font(.caption.weight(.black))
                            if unregisteredMapCount > 0 {
                                Text("\(unregisteredMapCount)")
                                    .font(.caption2.weight(.black))
                                    .foregroundStyle(.white)
                                    .frame(minWidth: 20, minHeight: 20)
                                    .background(AppTheme.tomato, in: Circle())
                            }
                        }
                        .foregroundStyle(AppTheme.ink)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(AppTheme.card.opacity(0.94), in: Capsule())
                        .overlay {
                            Capsule()
                                .stroke(AppTheme.hairline, lineWidth: 1)
                        }
                    }
                    .accessibilityLabel("Map未登録店舗を整理")
                    .disabled(unregisteredMapCount == 0)
                    .opacity(unregisteredMapCount == 0 ? 0.55 : 1)
                }
            }
            .sheet(item: $detailSeed) { seed in
                StoreDetailView(storeId: seed.id)
                    .environmentObject(dataStore)
                    .environmentObject(proState)
            }
            .sheet(isPresented: $isOrganizerPresented) {
                MapRegistrationOrganizerView(searchRegion: currentSearchRegion)
                    .environmentObject(dataStore)
            }
            .sheet(isPresented: $isNearbyRegistrationPresented) {
                NearbyStorePickerView(
                    locationManager: locationManager,
                    fallbackRegion: currentSearchRegion
                ) { candidate in
                    nearbyStoreCandidate = candidate
                    isNearbyRegistrationPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        nearbyFormSeed = StoreFormSeed(
                            store: nil,
                            mainGenreId: dataStore.sortedMainGenres.first?.id ?? "",
                            subGenreId: dataStore.sortedMainGenres.first.flatMap { dataStore.subGenres(for: $0.id).first?.id } ?? "",
                            rank: .archive
                        )
                    }
                }
            }
            .sheet(item: $nearbyFormSeed) { seed in
                StoreFormView(seed: seed, locationCandidate: nearbyStoreCandidate)
                    .environmentObject(dataStore)
                    .environmentObject(proState)
            }
            .sheet(item: $presentedFilterSheet) { sheet in
                switch sheet {
                case .genre:
                    GourmetMapGenreFilterSheet(
                        selectedMainGenreId: $selectedMainGenreId,
                        selectedSubGenreId: $selectedSubGenreId
                    )
                    .environmentObject(dataStore)
                case .rank:
                    GourmetMapRankFilterSheet(selectedRank: $selectedRank)
                }
            }
            .sheet(item: $paywallReason) { reason in
                PaywallView(reason: reason)
                    .environmentObject(proState)
            }
            .onChange(of: mappedStores.map(\.id)) { _, _ in clearHiddenSelection() }
            .task {
                locationManager.requestLocation()
            }
        }
    }

    private var currentSearchRegion: MKCoordinateRegion {
        if let coordinate = locationManager.location?.coordinate {
            return MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            )
        }
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
            span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
        )
    }

    private var mapFilterBar: some View {
        VStack(spacing: 8) {
            if !proState.isPro {
                Button {
                    paywallReason = .mapFullAccess
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                        Text("FreeプランではBest1のみ表示")
                        Spacer()
                        Text("全店舗を表示")
                        Image(systemName: "chevron.right")
                    }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.tomato)
                    .padding(.horizontal, 4)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 8) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        mapFilterButton("すべて", isActive: !hasActiveFilters) {
                            selectedMainGenreId = nil
                            selectedSubGenreId = nil
                            selectedRank = nil
                        }
                        mapFilterButton(genreFilterLabel, isActive: selectedMainGenreId != nil) {
                            if proState.isPro {
                                presentedFilterSheet = .genre
                            } else {
                                paywallReason = .mapFullAccess
                            }
                        }
                        mapFilterButton(rankFilterLabel, isActive: selectedRank != nil) {
                            if proState.isPro {
                                presentedFilterSheet = .rank
                            } else {
                                paywallReason = .mapFullAccess
                            }
                        }
                    }
                }
                Spacer()
                Text("\(mappedStores.count)件")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.softText)
                    .fixedSize()
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private func mapFilterButton(_ title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .lineLimit(1)
                if title != "すべて" {
                    Image(systemName: "chevron.down")
                        .font(.caption2.weight(.black))
                }
            }
            .font(.subheadline.weight(.bold))
            .foregroundStyle(isActive ? .white : AppTheme.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(isActive ? AppTheme.ink : AppTheme.card)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func clearHiddenSelection() {
        if let selectedStoreId, !mappedStores.contains(where: { $0.id == selectedStoreId }) {
            self.selectedStoreId = nil
        }
    }
}

private struct GourmetMapGenreFilterSheet: View {
    @EnvironmentObject private var dataStore: GourmetDataStore
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMainGenreId: String?
    @Binding var selectedSubGenreId: String?

    private var visibleSubGenres: [SubGenre] {
        guard let selectedMainGenreId else { return [] }
        return dataStore.subGenres(for: selectedMainGenreId)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("大項目") {
                    selectionRow("すべてのジャンル", selected: selectedMainGenreId == nil) {
                        selectedMainGenreId = nil
                        selectedSubGenreId = nil
                    }
                    ForEach(dataStore.sortedMainGenres) { genre in
                        selectionRow(genre.name, selected: selectedMainGenreId == genre.id) {
                            selectedMainGenreId = genre.id
                            selectedSubGenreId = nil
                        }
                    }
                }

                if selectedMainGenreId != nil {
                    Section("中項目") {
                        selectionRow("すべて", selected: selectedSubGenreId == nil) {
                            selectedSubGenreId = nil
                        }
                        ForEach(visibleSubGenres) { genre in
                            selectionRow(genre.name, selected: selectedSubGenreId == genre.id) {
                                selectedSubGenreId = genre.id
                            }
                        }
                    }
                }
            }
            .navigationTitle("ジャンルで絞り込む")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { dismiss() }
                        .fontWeight(.bold)
                }
            }
        }
    }

    private func selectionRow(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.tomato)
                }
            }
        }
    }
}

private struct GourmetMapRankFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedRank: StoreRank?

    var body: some View {
        NavigationStack {
            List {
                selectionRow("すべての順位", rank: nil)
                ForEach(StoreRank.allCases) { rank in
                    selectionRow(rank.label, rank: rank)
                }
            }
            .navigationTitle("順位で絞り込む")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { dismiss() }
                        .fontWeight(.bold)
                }
            }
        }
    }

    private func selectionRow(_ title: String, rank: StoreRank?) -> some View {
        Button {
            selectedRank = rank
        } label: {
            HStack {
                Text(title)
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                if selectedRank == rank {
                    Image(systemName: "checkmark")
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.tomato)
                }
            }
        }
    }
}

struct MapRegistrationOrganizerView: View {
    @EnvironmentObject private var dataStore: GourmetDataStore
    @Environment(\.dismiss) private var dismiss
    let searchRegion: MKCoordinateRegion

    @State private var skippedStoreIds: Set<String> = []
    @State private var candidates: [LocationSearchCandidate] = []
    @State private var selectedCandidateIndex = 0
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var message: String?
    @State private var pendingRenameCandidate: LocationSearchCandidate?

    private var unresolvedStores: [Store] {
        dataStore.stores.filter { $0.coordinate == nil && !skippedStoreIds.contains($0.id) }
    }

    private var currentStore: Store? { unresolvedStores.first }
    private var selectedCandidate: LocationSearchCandidate? {
        candidates.indices.contains(selectedCandidateIndex) ? candidates[selectedCandidateIndex] : nil
    }

    var body: some View {
        NavigationStack {
            Group {
                if let store = currentStore {
                    ScrollView {
                        VStack(spacing: 18) {
                            HStack {
                                Text("残り \(unresolvedStores.count)件")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(AppTheme.tomato)
                                Spacer()
                                Button("スキップ") {
                                    skippedStoreIds.insert(store.id)
                                    resetSearch()
                                }
                                .font(.subheadline.weight(.semibold))
                            }

                            HStack(spacing: 14) {
                                ThumbnailView(source: store.primaryImageSource, name: store.name, size: 82)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("未登録店舗")
                                        .font(.caption.weight(.black))
                                        .foregroundStyle(AppTheme.tomato)
                                    Text(store.name)
                                        .font(.title3.weight(.bold))
                                        .foregroundStyle(AppTheme.ink)
                                    Text(store.area ?? "エリア未登録")
                                        .font(.subheadline)
                                        .foregroundStyle(AppTheme.softText)
                                }
                                Spacer()
                            }
                            .padding(14)
                            .background(AppTheme.card, in: RoundedRectangle(cornerRadius: 12))

                            Image(systemName: "arrow.down")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(AppTheme.olive)

                            if let candidate = selectedCandidate {
                                candidatePanel(candidate)
                                HStack {
                                    Button("前の候補") { selectedCandidateIndex -= 1 }
                                        .disabled(selectedCandidateIndex == 0)
                                    Spacer()
                                    Text("\(selectedCandidateIndex + 1) / \(candidates.count)")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(AppTheme.softText)
                                    Spacer()
                                    Button("次の候補") { selectedCandidateIndex += 1 }
                                        .disabled(selectedCandidateIndex >= candidates.count - 1)
                                }

                                Button {
                                    save(candidate, for: store)
                                } label: {
                                    Label("この場所で保存", systemImage: "checkmark.circle.fill")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(AppTheme.tomato)
                            } else if isSearching {
                                ProgressView("候補を検索中...")
                                    .padding(.top, 40)
                            } else {
                                candidateSearchField
                            }
                        }
                        .padding(18)
                    }
                    .background(AppBackgroundView())
                    .task(id: store.id) {
                        searchText = displaySearchName(for: store)
                        await search(query: searchText, store: store)
                    }
                } else {
                    ContentUnavailableView(
                        "整理が完了しました",
                        systemImage: "checkmark.circle",
                        description: Text("Map未登録の店舗はありません。")
                    )
                }
            }
            .navigationTitle("Map未登録を整理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
            .confirmationDialog(
                "店舗名をMap上の名前に合わせますか？",
                isPresented: Binding(
                    get: { pendingRenameCandidate != nil },
                    set: { if !$0 { pendingRenameCandidate = nil } }
                ),
                titleVisibility: .visible
            ) {
                if let store = currentStore, let candidate = pendingRenameCandidate {
                    Button("「\(candidate.name)」に変更して保存") {
                        dataStore.updateStoreLocation(store.id, candidate: candidate, renameToCandidate: true)
                        pendingRenameCandidate = nil
                        resetSearch()
                    }
                    Button("登録名は変えずに保存") {
                        dataStore.updateStoreLocation(store.id, candidate: candidate)
                        pendingRenameCandidate = nil
                        resetSearch()
                    }
                }
                Button("キャンセル", role: .cancel) {
                    pendingRenameCandidate = nil
                }
            } message: {
                if let store = currentStore, let candidate = pendingRenameCandidate {
                    Text("登録名「\(store.name)」とMap上の名前「\(candidate.name)」が違います。")
                }
            }
        }
    }

    private func candidatePanel(_ candidate: LocationSearchCandidate) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("候補の店舗")
                .font(.caption.weight(.black))
                .foregroundStyle(AppTheme.olive)
            candidateSearchField
            .padding(.bottom, 2)
            Label(candidate.area.isEmpty ? "主要地域なし" : candidate.area, systemImage: "mappin")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.softText)
            Text(candidate.address)
                .font(.footnote)
                .foregroundStyle(AppTheme.muted)

            Map(initialPosition: .region(MKCoordinateRegion(
                center: candidate.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))) {
                Marker(candidate.name, coordinate: candidate.coordinate)
                    .tint(AppTheme.tomato)
            }
            .id(candidate.id)
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .allowsHitTesting(false)
        }
        .padding(15)
        .background(AppTheme.card, in: RoundedRectangle(cornerRadius: 12))
    }

    private var candidateSearchField: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.olive)
                TextField("候補の店舗名を検索", text: candidateSearchTextBinding)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppTheme.ink)
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await searchManually() }
                    }
                if !visibleSearchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.muted.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.olive.opacity(0.28), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            Button {
                Task { await searchManually() }
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(AppTheme.ink, in: RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .disabled(visibleSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSearching)
        }
    }

    @MainActor
    private func search(query: String, store: Store? = nil) async {
        isSearching = true
        message = nil
        candidates = []
        selectedCandidateIndex = 0
        defer { isSearching = false }

        let displayQuery = searchDisplayText(query, store: store)
        var queries = [displayQuery]
        if let store {
            queries.append([displaySearchName(for: store), store.area ?? ""].filter { !$0.isEmpty }.joined(separator: " "))
            queries.append(displaySearchName(for: store))
        }
        candidates = await searchLocationCandidates(queries: queries, region: searchRegion, limit: 8)
        selectedCandidateIndex = 0
    }

    @MainActor
    private func searchManually() async {
        let query = visibleSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }

        isSearching = true
        message = nil
        candidates = []
        selectedCandidateIndex = 0
        defer { isSearching = false }

        searchText = query
        let area = currentStore?.area?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let queries = [
            [query, area].filter { !$0.isEmpty }.joined(separator: " "),
            query
        ]
        candidates = await searchLocationCandidates(queries: queries, region: nil, limit: 8)
    }

    private func resetSearch() {
        candidates = []
        selectedCandidateIndex = 0
        searchText = ""
        message = nil
    }

    private func save(_ candidate: LocationSearchCandidate, for store: Store) {
        if normalizedName(store.name) == normalizedName(candidate.name) {
            dataStore.updateStoreLocation(store.id, candidate: candidate)
            resetSearch()
        } else {
            pendingRenameCandidate = candidate
        }
    }

    private func normalizedName(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "　", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func displaySearchName(for store: Store) -> String {
        searchDisplayText(store.name, store: store)
    }

    private var visibleSearchText: String {
        searchDisplayText(searchText, store: currentStore)
    }

    private var candidateSearchTextBinding: Binding<String> {
        Binding(
            get: { visibleSearchText },
            set: { newValue in
                searchText = searchDisplayText(newValue, store: currentStore)
            }
        )
    }

    private func searchDisplayText(_ value: String, store: Store?) -> String {
        var cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)

        if let area = store?.area?.trimmingCharacters(in: .whitespacesAndNewlines), !area.isEmpty {
            let areaSuffixes = [" \(area)", "　\(area)", area]
            for suffix in areaSuffixes where cleaned.hasSuffix(suffix) && cleaned.count > suffix.count {
                cleaned.removeLast(suffix.count)
                cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
                break
            }
        }

        var parts = cleaned
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
        let areaTokens = Set(
            (store?.area ?? "")
                .split(whereSeparator: { $0.isWhitespace || $0 == "・" || $0 == "," || $0 == "、" })
                .map(String.init)
        )

        while let last = parts.last, isSearchAreaToken(last, areaTokens: areaTokens) {
            parts.removeLast()
        }

        let nameOnly = parts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        return nameOnly.isEmpty ? value.trimmingCharacters(in: .whitespacesAndNewlines) : nameOnly
    }

    private func isSearchAreaToken(_ token: String, areaTokens: Set<String>) -> Bool {
        if areaTokens.contains(token) {
            return true
        }
        if token == "東京" || token == "東京都" {
            return true
        }
        return ["都", "道", "府", "県", "市", "区", "町", "村"].contains { token.hasSuffix($0) }
    }
}

struct NearbyStorePickerView: View {
    @ObservedObject var locationManager: LocationManager
    let fallbackRegion: MKCoordinateRegion
    let onSelect: (LocationSearchCandidate) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var candidates: [LocationSearchCandidate] = []
    @State private var isSearching = false

    private var currentRegion: MKCoordinateRegion {
        if let coordinate = locationManager.location?.coordinate {
            return MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
            )
        }
        return fallbackRegion
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("近くのお店から登録")
                            .font(.title3.weight(.black))
                            .foregroundStyle(AppTheme.ink)
                        Text(locationManager.location == nil ? "現在地が使えない場合は、表示中のMap範囲から候補を探します。" : "現在地周辺の飲食店を候補として表示します。")
                            .font(.footnote)
                            .foregroundStyle(AppTheme.softText)
                    }

                    HStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppTheme.olive)
                            TextField("店名・駅名・住所で検索", text: $searchText)
                                .submitLabel(.search)
                                .onSubmit {
                                    Task { await searchNearby() }
                                }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 11)
                        .background(.white, in: RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.olive.opacity(0.25), lineWidth: 1)
                        }

                        Button {
                            Task { await searchNearby() }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(width: 42, height: 42)
                                .background(AppTheme.ink, in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        .disabled(isSearching)
                    }

                    if isSearching {
                        ProgressView("候補を検索中...")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                    } else if candidates.isEmpty {
                        ContentUnavailableView(
                            "候補がまだありません",
                            systemImage: "location.magnifyingglass",
                            description: Text("店名で検索するか、現在地周辺の候補を再検索してください。")
                        )
                        .padding(.vertical, 20)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(candidates) { candidate in
                                Button {
                                    onSelect(candidate)
                                    dismiss()
                                } label: {
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(.title3.weight(.bold))
                                            .foregroundStyle(AppTheme.tomato)
                                            .frame(width: 32, height: 32)
                                            .background(AppTheme.tomato.opacity(0.1), in: Circle())
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(candidate.name)
                                                .font(.headline.weight(.black))
                                                .foregroundStyle(AppTheme.ink)
                                            Text(candidate.area.isEmpty ? "主要地域なし" : candidate.area)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(AppTheme.softText)
                                            Text(candidate.address)
                                                .font(.caption)
                                                .foregroundStyle(AppTheme.muted)
                                                .lineLimit(2)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption.weight(.black))
                                            .foregroundStyle(AppTheme.muted)
                                            .padding(.top, 6)
                                    }
                                    .padding(14)
                                    .background(AppTheme.card, in: RoundedRectangle(cornerRadius: 14))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(18)
            }
            .background(AppBackgroundView())
            .navigationTitle("近くで登録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("再検索") {
                        Task { await searchNearby(forceNearby: true) }
                    }
                    .disabled(isSearching)
                }
            }
            .task {
                locationManager.requestLocation()
                await searchNearby(forceNearby: true)
            }
        }
    }

    @MainActor
    private func searchNearby(forceNearby: Bool = false) async {
        isSearching = true
        defer { isSearching = false }

        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let queries = trimmed.isEmpty || forceNearby ? ["レストラン", "飲食店", "カフェ"] : [trimmed, "\(trimmed) レストラン"]
        candidates = await searchLocationCandidates(queries: queries, region: currentRegion, limit: 12)
    }
}

struct GourmetMapPin: View {
    let store: Store
    let isSelected: Bool

    private var accent: Color {
        store.rank == .archive ? AppTheme.olive : AppTheme.tomato
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(accent)
                if let rank = store.rank.numericValue {
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                } else {
                    Image(systemName: "archivebox.fill")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: isSelected ? 38 : 32, height: isSelected ? 38 : 32)
            .overlay {
                Circle().stroke(.white, lineWidth: 2)
            }
            .shadow(color: .black.opacity(isSelected ? 0.18 : 0.12), radius: isSelected ? 4 : 3, y: 2)

            Image(systemName: "triangle.fill")
                .font(.system(size: 9))
                .foregroundStyle(accent)
                .rotationEffect(.degrees(180))
                .offset(y: -2)
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
    }
}

struct GourmetMapStoreCard: View {
    @EnvironmentObject private var dataStore: GourmetDataStore
    let store: Store

    var body: some View {
        HStack(spacing: 13) {
            ThumbnailView(source: store.primaryImageSource, name: store.name, size: 72)

            VStack(alignment: .leading, spacing: 5) {
                Text(store.rank.label)
                    .font(.caption.weight(.black))
                    .foregroundStyle(store.rank == .archive ? AppTheme.olive : AppTheme.tomato)
                Text(store.name)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)
                Label(store.area ?? "エリア未登録", systemImage: "mappin")
                    .font(.caption)
                    .foregroundStyle(AppTheme.softText)
                Text(dataStore.subGenreName(for: store.subGenreId))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppTheme.muted)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.muted)
        }
        .padding(12)
        .background(AppTheme.card.opacity(0.96), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: AppTheme.ink.opacity(0.14), radius: 12, y: 5)
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

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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

                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Image(systemName: "note.text")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppTheme.olive)
                        .frame(width: 12, alignment: .center)
                    Text(store.memo ?? "メモ未登録")
                        .font(memoFont)
                        .foregroundStyle(AppTheme.softText)
                        .lineLimit(2, reservesSpace: true)
                }
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
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Image(systemName: "note.text")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppTheme.olive)
                        .frame(width: 12, alignment: .center)
                    Text(store.memo ?? "メモ未登録")
                        .font(memoFont)
                        .foregroundStyle(AppTheme.softText)
                        .lineLimit(2)
                }
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
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Image(systemName: "note.text")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppTheme.olive)
                        .frame(width: 12, alignment: .center)
                    Text("行ったらメモを残そう")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.softText)
                }
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
    @EnvironmentObject private var proState: ProState
    @Environment(\.dismiss) private var dismiss

    private let seed: StoreFormSeed
    private let initialLocationCandidate: LocationSearchCandidate?
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
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var locationCandidates: [LocationSearchCandidate] = []
    @State private var isSearchingLocation = false
    @State private var manualLocationQuery = ""
    @State private var validationMessage: String?
    @State private var paywallReason: PaywallReason?

    init(seed: StoreFormSeed, locationCandidate: LocationSearchCandidate? = nil) {
        self.seed = seed
        initialLocationCandidate = locationCandidate
        _name = State(initialValue: seed.store?.name ?? locationCandidate?.name ?? "")
        _mainGenreId = State(initialValue: seed.store?.mainGenreId ?? seed.mainGenreId)
        _subGenreId = State(initialValue: seed.store?.subGenreId ?? seed.subGenreId)
        _rank = State(initialValue: seed.store?.rank ?? seed.rank)
        _area = State(initialValue: seed.store?.area ?? locationCandidate?.area ?? "")
        _legacyImageUrl = State(initialValue: seed.store?.imageUrl ?? "")
        _photoDrafts = State(initialValue: (seed.store?.imageFileNames ?? []).map(PhotoDraft.init(fileName:)))
        _memo = State(initialValue: seed.store?.memo ?? "")
        _mapUrl = State(initialValue: seed.store?.mapUrl ?? locationCandidate?.mapUrl ?? "")
        _latitude = State(initialValue: seed.store?.latitude ?? locationCandidate?.coordinate.latitude)
        _longitude = State(initialValue: seed.store?.longitude ?? locationCandidate?.coordinate.longitude)
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

                Section("グルメMap") {
                    Button {
                        Task { await searchLocation() }
                    } label: {
                        Label(isSearchingLocation ? "検索中..." : "店名とエリアから場所を検索", systemImage: "map")
                    }
                    .disabled(isSearchingLocation || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    HStack {
                        TextField("店名・駅名・住所で手動検索", text: $manualLocationQuery)
                        Button("検索") {
                            Task { await searchLocation(query: manualLocationQuery) }
                        }
                        .disabled(manualLocationQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSearchingLocation)
                    }

                    if latitude != nil, longitude != nil {
                        Label("グルメMapに表示されます", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(AppTheme.olive)
                        Button("地図から外す", role: .destructive) {
                            latitude = nil
                            longitude = nil
                            locationCandidates = []
                        }
                    } else {
                        Text("候補を選ぶと、グルメMapに店舗ピンが表示されます。")
                            .font(.caption)
                            .foregroundStyle(AppTheme.softText)
                    }

                    ForEach(locationCandidates) { candidate in
                        Button {
                            applyLocation(candidate)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(candidate.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppTheme.ink)
                                Text(candidate.address)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.softText)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
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
            .sheet(item: $paywallReason) { reason in
                PaywallView(reason: reason)
                    .environmentObject(proState)
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
        guard canSaveArchiveSelection else {
            paywallReason = .archiveLimit
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
                latitude: latitude,
                longitude: longitude
            ),
            editingStoreId: seed.store?.id
        )
        dismiss()
    }

    private var canSaveArchiveSelection: Bool {
        guard !proState.isPro, rank == .archive, seed.store?.rank != .archive else {
            return true
        }
        return dataStore.stores.filter { $0.rank == .archive }.count < 3
    }

    private func syncRankSelection() {
        guard !availableRankOptions.contains(rank) else {
            return
        }
        rank = availableRankOptions.first { $0.numericValue != nil } ?? .archive
    }

    @MainActor
    private func searchLocation(query: String? = nil) async {
        isSearchingLocation = true
        validationMessage = nil
        defer { isSearchingLocation = false }

        let trimmedQuery = query?.trimmingCharacters(in: .whitespacesAndNewlines)
        let baseQuery = trimmedQuery?.isEmpty == false ? trimmedQuery! : [name, area].filter { !$0.isEmpty }.joined(separator: " ")
        var queries = [baseQuery]
        if !area.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            queries.append([name, area].filter { !$0.isEmpty }.joined(separator: " "))
        }
        queries.append(name)

        locationCandidates = await searchLocationCandidates(
            queries: queries,
            region: locationSearchRegion,
            limit: 5
        )
    }

    private var locationSearchRegion: MKCoordinateRegion? {
        if let latitude, let longitude {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
        if let coordinate = initialLocationCandidate?.coordinate {
            return MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
        return nil
    }

    private func applyLocation(_ candidate: LocationSearchCandidate) {
        latitude = candidate.coordinate.latitude
        longitude = candidate.coordinate.longitude
        if area.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            area = candidate.area
        }
        if mapUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            mapUrl = "https://maps.apple.com/?ll=\(candidate.coordinate.latitude),\(candidate.coordinate.longitude)&q=\(candidate.encodedName)"
        }
        locationCandidates = []
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

struct LocationSearchCandidate: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let area: String
    let coordinate: CLLocationCoordinate2D

    init(mapItem: MKMapItem) {
        name = mapItem.name ?? "名称未登録"
        coordinate = mapItem.placemark.coordinate
        let parts = [
            mapItem.placemark.administrativeArea,
            mapItem.placemark.locality,
            mapItem.placemark.subLocality,
            mapItem.placemark.thoroughfare
        ].compactMap { $0 }
        address = parts.isEmpty ? "住所情報なし" : parts.joined(separator: " ")
        area = [mapItem.placemark.locality, mapItem.placemark.subLocality].compactMap { $0 }.joined(separator: " ")
    }

    var encodedName: String {
        name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
    }

    var mapUrl: String {
        "https://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)&q=\(encodedName)"
    }

    var dedupeKey: String {
        "\(name.lowercased())|\(address.lowercased())"
    }
}

@MainActor
private func searchLocationCandidates(
    queries: [String],
    region: MKCoordinateRegion?,
    limit: Int
) async -> [LocationSearchCandidate] {
    var results: [LocationSearchCandidate] = []
    var seenKeys: Set<String> = []

    for rawQuery in queries {
        let query = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { continue }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        if let region {
            request.region = region
        }

        guard let response = try? await MKLocalSearch(request: request).start() else {
            continue
        }

        for mapItem in response.mapItems {
            let candidate = LocationSearchCandidate(mapItem: mapItem)
            guard seenKeys.insert(candidate.dedupeKey).inserted else { continue }
            results.append(candidate)
        }
    }

    if let region {
        let center = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        results.sort {
            let first = CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            let second = CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude)
            return first.distance(from: center) < second.distance(from: center)
        }
    }

    return Array(results.prefix(limit))
}

struct StoreDetailView: View {
    @EnvironmentObject private var dataStore: GourmetDataStore
    @EnvironmentObject private var proState: ProState
    @Environment(\.dismiss) private var dismiss
    let storeId: String
    @State private var formSeed: StoreFormSeed?
    @State private var paywallReason: PaywallReason?

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
                                    if !proState.isPro, dataStore.stores.filter({ $0.rank == .archive }).count >= 3 {
                                        paywallReason = .archiveLimit
                                    } else {
                                        dataStore.archiveStore(store.id)
                                        dismiss()
                                    }
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
                    .environmentObject(proState)
            }
            .sheet(item: $paywallReason) { reason in
                PaywallView(reason: reason)
                    .environmentObject(proState)
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
    @EnvironmentObject private var proState: ProState
    @State private var selectedTab: SettingsTab = .stores
    @State private var formSeed: StoreFormSeed?
    @State private var message: SettingsMessage?
    @State private var paywallReason: PaywallReason?

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
                proSection
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
                .environmentObject(proState)
        }
        .sheet(item: $paywallReason) { reason in
            PaywallView(reason: reason)
                .environmentObject(proState)
        }
        .alert(item: $message) { message in
            Alert(title: Text(message.title), message: Text(message.body), dismissButton: .default(Text("OK")))
        }
        .alert("Pro", isPresented: Binding(get: { proState.message != nil }, set: { if !$0 { proState.message = nil } })) {
            Button("OK") { proState.message = nil }
        } message: {
            Text(proState.message ?? "")
        }
    }

    private var proSection: some View {
        Section("Proプラン") {
            if proState.isPro {
                Label("Pro有効", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(AppTheme.olive)
            } else {
                Button {
                    paywallReason = .settings
                } label: {
                    Label("Proにアップグレード", systemImage: "crown.fill")
                }
            }

            Button {
                Task { await proState.restorePurchases() }
            } label: {
                Label("購入を復元", systemImage: "arrow.clockwise")
            }
            .disabled(proState.isLoading)

            Link(destination: RevenueCatConfig.termsURL) {
                Label("利用規約", systemImage: "doc.text")
            }
            Link(destination: RevenueCatConfig.privacyURL) {
                Label("プライバシーポリシー", systemImage: "lock")
            }
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
                            if !proState.isPro, dataStore.stores.filter({ $0.rank == .archive }).count >= 3 {
                                paywallReason = .archiveLimit
                            } else {
                                dataStore.archiveStore(store.id)
                            }
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
                    guard requireProForEditing() else { return }
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
                                guard requireProForEditing() else { return }
                                if let error = dataStore.updateMainGenre(
                                    id: genre.id,
                                    name: mainGenreDrafts[genre.id] ?? genre.name
                                ) {
                                    showError(error)
                                }
                            }
                            Button("上へ") {
                                guard requireProForEditing() else { return }
                                dataStore.moveMainGenre(id: genre.id, direction: .up)
                            }
                            .disabled(index == 0)
                            Button("下へ") {
                                guard requireProForEditing() else { return }
                                dataStore.moveMainGenre(id: genre.id, direction: .down)
                            }
                            .disabled(index == dataStore.sortedMainGenres.count - 1)
                            Spacer()
                            Button("削除", role: .destructive) {
                                guard requireProForEditing() else { return }
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
                    guard requireProForEditing() else { return }
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
                                        guard requireProForEditing() else { return }
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
                                        guard requireProForEditing() else { return }
                                        dataStore.moveSubGenre(id: subGenre.id, direction: .up)
                                    }
                                    .disabled(index == 0)
                                    Button("下へ") {
                                        guard requireProForEditing() else { return }
                                        dataStore.moveSubGenre(id: subGenre.id, direction: .down)
                                    }
                                    .disabled(index == children.count - 1)
                                    Spacer()
                                    Button("削除", role: .destructive) {
                                        guard requireProForEditing() else { return }
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

    private func requireProForEditing() -> Bool {
        guard !proState.isPro else { return true }
        paywallReason = .genreEditing
        return false
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
