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
}
