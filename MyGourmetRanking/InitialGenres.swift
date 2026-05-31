import Foundation

enum InitialGenres {
    private static let timestamp = Date(timeIntervalSince1970: 1_717_113_600)

    private static let seeds: [(id: String, name: String, subGenres: [String])] = [
        ("japanese", "和風", ["全般", "寿司", "海鮮", "うなぎ", "天ぷら", "天丼", "とんかつ", "すき焼き", "そば", "うどん", "割烹・小料理", "鍋", "おでん"]),
        ("chinese", "中華", ["全般", "町中華", "高級中華", "チャーハン", "餃子", "麻婆豆腐", "担々麺", "点心"]),
        ("western", "洋食・西洋料理", ["全般", "洋食", "ハンバーグ", "オムライス", "カレー", "ステーキ", "ビストロ", "フレンチ", "イタリアン", "パスタ", "ピザ"]),
        ("meat", "焼肉・肉料理", ["全般", "焼肉", "ホルモン", "牛タン", "ジンギスカン", "焼き鳥", "焼きとん", "鉄板焼き"]),
        ("ramen", "ラーメン・麺", ["全般", "醤油ラーメン", "塩ラーメン", "味噌ラーメン", "豚骨ラーメン", "家系ラーメン", "二郎系", "つけ麺", "油そば・まぜそば"]),
        ("curry-ethnic", "カレー・エスニック", ["全般", "欧風カレー", "スパイスカレー", "インドカレー", "タイ料理", "ベトナム料理", "韓国料理"]),
        ("cafe-sweets", "カフェ・スイーツ", ["全般", "カフェ", "喫茶店", "パンケーキ", "パフェ", "ケーキ", "和菓子", "かき氷", "ベーカリー"]),
        ("fast-light", "ファスト・軽食", ["全般", "ハンバーガー", "サンドイッチ", "ホットドッグ", "タコス", "クレープ", "弁当", "おにぎり", "パン", "ベーグル"]),
        ("konamono", "粉もの", ["全般", "たこ焼き", "お好み焼き", "もんじゃ", "焼きそば", "広島焼き"]),
        ("bar", "酒場", ["全般", "居酒屋", "立ち飲み", "バー", "ワインバー", "日本酒", "ビール"]),
        ("occasion", "用途別", ["全般", "デート", "ひとり飯", "友達と行く", "会食", "記念日", "コスパ", "深夜飯", "ランチ", "サウナ後", "人に紹介したい"])
    ]

    static let mainGenres: [MainGenre] = seeds.enumerated().map { index, seed in
        MainGenre(
            id: seed.id,
            name: seed.name,
            sortOrder: index,
            createdAt: timestamp,
            updatedAt: timestamp
        )
    }

    static let subGenres: [SubGenre] = seeds.flatMap { seed in
        seed.subGenres.enumerated().map { index, name in
            SubGenre(
                id: "\(seed.id)-\(index + 1)",
                mainGenreId: seed.id,
                name: name,
                sortOrder: index,
                createdAt: timestamp,
                updatedAt: timestamp
            )
        }
    }

    static let sampleStores: [Store] = [
        sampleStore(
            id: "sample-sukiyaki-1",
            name: "銀座 霜降り研究所",
            mainGenreId: "japanese",
            subGenreId: "japanese-8",
            rank: .rank1,
            previousRank: nil,
            area: "銀座",
            memo: "割下の香りが強くて、卵まで主役になる一皿。",
            imageUrl: "https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=900&q=80"
        ),
        sampleStore(
            id: "sample-sukiyaki-2",
            name: "浅草 鍋と月",
            mainGenreId: "japanese",
            subGenreId: "japanese-8",
            rank: .rank2,
            previousRank: nil,
            area: "浅草",
            memo: "落ち着いた店内。甘めの味付けで友達にも紹介しやすい。",
            imageUrl: "https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=80"
        ),
        sampleStore(
            id: "sample-sukiyaki-3",
            name: "恵比寿 牛鍋ネオン",
            mainGenreId: "japanese",
            subGenreId: "japanese-8",
            rank: .rank3,
            previousRank: nil,
            area: "恵比寿",
            memo: "少し今っぽい雰囲気。デート用途ならかなり強い。",
            imageUrl: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80"
        ),
        sampleStore(
            id: "sample-sukiyaki-5",
            name: "日本橋 すき焼き灯",
            mainGenreId: "japanese",
            subGenreId: "japanese-8",
            rank: .rank5,
            previousRank: nil,
            area: "日本橋",
            memo: "ランチの満足度が高い。4位はあえてTBDにして比較用。",
            imageUrl: "https://images.unsplash.com/photo-1551218808-94e220e084d2?auto=format&fit=crop&w=900&q=80"
        ),
        sampleStore(
            id: "sample-sukiyaki-archive-1",
            name: "神楽坂 甘辛亭",
            mainGenreId: "japanese",
            subGenreId: "japanese-8",
            rank: .archive,
            previousRank: 4,
            area: "神楽坂",
            memo: "前は4位。おいしいけど再訪優先度は少し下がった。",
            imageUrl: "https://images.unsplash.com/photo-1528605248644-14dd04022da1?auto=format&fit=crop&w=900&q=80"
        ),
        sampleStore(
            id: "sample-sukiyaki-archive-2",
            name: "渋谷 夜鍋スタンド",
            mainGenreId: "japanese",
            subGenreId: "japanese-8",
            rank: .archive,
            previousRank: nil,
            area: "渋谷",
            memo: "未ランクイン。深夜に使えるけどBest入りは保留。",
            imageUrl: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=900&q=80"
        ),
        sampleStore(
            id: "sample-sushi-1",
            name: "青山 鮨ミニマル",
            mainGenreId: "japanese",
            subGenreId: "japanese-2",
            rank: .rank1,
            previousRank: nil,
            area: "青山",
            memo: "小ぶりでテンポが良い。ひとりでも入りやすい鮨。",
            imageUrl: "https://images.unsplash.com/photo-1553621042-f6e147245754?auto=format&fit=crop&w=900&q=80"
        ),
        sampleStore(
            id: "sample-ramen-1",
            name: "代々木 余韻つけ麺",
            mainGenreId: "ramen",
            subGenreId: "ramen-8",
            rank: .rank1,
            previousRank: nil,
            area: "代々木",
            memo: "魚介の余韻が長い。並んでも許せる完成度。",
            imageUrl: "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=900&q=80"
        ),
        sampleStore(
            id: "sample-cafe-1",
            name: "表参道 Cloud Brew",
            mainGenreId: "cafe-sweets",
            subGenreId: "cafe-sweets-2",
            rank: .rank1,
            previousRank: nil,
            area: "表参道",
            memo: "席間が広くて作業しやすい。ラテもちゃんとうまい。",
            imageUrl: "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=900&q=80"
        ),
        sampleStore(
            id: "sample-burger-1",
            name: "中目黒 Bite Club",
            mainGenreId: "fast-light",
            subGenreId: "fast-light-2",
            rank: .rank1,
            previousRank: nil,
            area: "中目黒",
            memo: "肉感強め。ポテトまでちゃんと覚えている店。",
            imageUrl: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=900&q=80"
        )
    ]

    private static func sampleStore(
        id: String,
        name: String,
        mainGenreId: String,
        subGenreId: String,
        rank: StoreRank,
        previousRank: Int?,
        area: String,
        memo: String,
        imageUrl: String
    ) -> Store {
        Store(
            id: id,
            name: name,
            mainGenreId: mainGenreId,
            subGenreId: subGenreId,
            rank: rank,
            previousRank: previousRank,
            area: area,
            memo: memo,
            imageUrl: imageUrl,
            mapUrl: "https://maps.google.com/?q=\(area.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? area)",
            createdAt: timestamp,
            updatedAt: timestamp
        )
    }
}
