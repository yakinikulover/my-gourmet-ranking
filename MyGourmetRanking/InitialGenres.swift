import Foundation

enum InitialGenres {
    private static let timestamp = Date(timeIntervalSince1970: 1_717_113_600)

    struct GenreSeed {
        let id: String
        let name: String
        let subGenres: [(id: String, name: String)]
    }

    static let seeds: [GenreSeed] = [
        GenreSeed(id: "japanese", name: "和食・日本料理", subGenres: [
            ("japanese-1", "全般"),
            ("japanese-2", "日本料理"),
            ("japanese-3", "割烹・小料理"),
            ("japanese-4", "天ぷら"),
            ("japanese-5", "うなぎ"),
            ("japanese-6", "おでん"),
            ("japanese-7", "鍋"),
            ("japanese-8", "すき焼き"),
            ("japanese-9", "しゃぶしゃぶ"),
            ("japanese-10", "おばんざい"),
            ("japanese-11", "郷土料理")
        ]),
        GenreSeed(id: "sushi-seafood", name: "寿司・海鮮", subGenres: [
            ("sushi-seafood-1", "全般"),
            ("sushi-seafood-2", "寿司"),
            ("sushi-seafood-3", "回転寿司"),
            ("sushi-seafood-4", "海鮮"),
            ("sushi-seafood-5", "刺身"),
            ("sushi-seafood-6", "海鮮丼"),
            ("sushi-seafood-7", "かに"),
            ("sushi-seafood-8", "ふぐ"),
            ("sushi-seafood-9", "オイスターバー")
        ]),
        GenreSeed(id: "setmeal-don", name: "定食・食堂・丼", subGenres: [
            ("setmeal-don-1", "全般"),
            ("setmeal-don-2", "定食"),
            ("setmeal-don-3", "食堂"),
            ("setmeal-don-4", "町の定食"),
            ("setmeal-don-5", "丼"),
            ("setmeal-don-6", "牛丼"),
            ("setmeal-don-7", "親子丼"),
            ("setmeal-don-8", "天丼"),
            ("setmeal-don-9", "かつ丼"),
            ("setmeal-don-10", "とんかつ"),
            ("setmeal-don-11", "からあげ"),
            ("setmeal-don-12", "弁当"),
            ("setmeal-don-13", "おにぎり")
        ]),
        GenreSeed(id: "meat", name: "焼肉・肉料理", subGenres: [
            ("meat-1", "全般"),
            ("meat-2", "焼肉"),
            ("meat-3", "ホルモン"),
            ("meat-4", "牛タン"),
            ("meat-5", "ジンギスカン"),
            ("meat-6", "ステーキ"),
            ("meat-7", "鉄板焼き"),
            ("meat-8", "肉料理")
        ]),
        GenreSeed(id: "yakitori-kushi", name: "焼鳥・串", subGenres: [
            ("yakitori-kushi-1", "全般"),
            ("yakitori-kushi-2", "焼き鳥"),
            ("yakitori-kushi-3", "焼きとん"),
            ("yakitori-kushi-4", "串焼き"),
            ("yakitori-kushi-5", "串カツ・串揚げ"),
            ("yakitori-kushi-6", "鳥料理")
        ]),
        GenreSeed(id: "ramen", name: "ラーメン・麺", subGenres: [
            ("ramen-1", "全般"),
            ("ramen-2", "ラーメン"),
            ("ramen-3", "醤油ラーメン"),
            ("ramen-4", "塩ラーメン"),
            ("ramen-5", "味噌ラーメン"),
            ("ramen-6", "豚骨ラーメン"),
            ("ramen-7", "家系ラーメン"),
            ("ramen-8", "つけ麺"),
            ("ramen-9", "油そば・まぜそば"),
            ("ramen-10", "そば"),
            ("ramen-11", "うどん"),
            ("ramen-12", "焼きそば"),
            ("ramen-13", "二郎系")
        ]),
        GenreSeed(id: "chinese", name: "中華", subGenres: [
            ("chinese-1", "全般"),
            ("chinese-2", "町中華"),
            ("chinese-3", "高級中華"),
            ("chinese-4", "チャーハン"),
            ("chinese-5", "餃子"),
            ("chinese-6", "麻婆豆腐"),
            ("chinese-7", "担々麺"),
            ("chinese-8", "点心"),
            ("chinese-9", "台湾料理")
        ]),
        GenreSeed(id: "western", name: "洋食・西洋料理", subGenres: [
            ("western-1", "全般"),
            ("western-2", "洋食"),
            ("western-3", "ハンバーグ"),
            ("western-4", "オムライス"),
            ("western-5", "ステーキ"),
            ("western-6", "ビストロ"),
            ("western-7", "フレンチ"),
            ("western-8", "イタリアン"),
            ("western-9", "パスタ"),
            ("western-10", "ピザ"),
            ("western-11", "ハンバーガー")
        ]),
        GenreSeed(id: "curry-ethnic", name: "カレー・エスニック", subGenres: [
            ("curry-ethnic-1", "全般"),
            ("curry-ethnic-2", "カレー"),
            ("curry-ethnic-3", "欧風カレー"),
            ("curry-ethnic-4", "スパイスカレー"),
            ("curry-ethnic-5", "インドカレー"),
            ("curry-ethnic-6", "タイ料理"),
            ("curry-ethnic-7", "ベトナム料理"),
            ("curry-ethnic-8", "韓国料理"),
            ("curry-ethnic-9", "アジア料理")
        ]),
        GenreSeed(id: "cafe-sweets", name: "カフェ・スイーツ", subGenres: [
            ("cafe-sweets-1", "全般"),
            ("cafe-sweets-2", "カフェ"),
            ("cafe-sweets-3", "喫茶店"),
            ("cafe-sweets-4", "パンケーキ"),
            ("cafe-sweets-5", "パフェ"),
            ("cafe-sweets-6", "ケーキ"),
            ("cafe-sweets-7", "和菓子"),
            ("cafe-sweets-8", "かき氷"),
            ("cafe-sweets-9", "ベーカリー")
        ]),
        GenreSeed(id: "fast-light", name: "ファスト・軽食", subGenres: [
            ("fast-light-1", "全般"),
            ("fast-light-2", "ハンバーガー"),
            ("fast-light-3", "サンドイッチ"),
            ("fast-light-4", "ホットドッグ"),
            ("fast-light-5", "パン"),
            ("fast-light-6", "ベーグル"),
            ("fast-light-7", "タコス"),
            ("fast-light-8", "たこ焼き"),
            ("fast-light-9", "お好み焼き"),
            ("fast-light-10", "もんじゃ"),
            ("fast-light-11", "ファミレス"),
            ("fast-light-12", "ファストフード"),
            ("fast-light-13", "クレープ")
        ]),
        GenreSeed(id: "bar", name: "酒場・バー", subGenres: [
            ("bar-1", "全般"),
            ("bar-2", "居酒屋"),
            ("bar-3", "立ち飲み"),
            ("bar-4", "バー"),
            ("bar-5", "ワインバー"),
            ("bar-6", "日本酒"),
            ("bar-7", "ビール"),
            ("bar-8", "ダイニングバー"),
            ("bar-9", "バル")
        ])
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
        seed.subGenres.enumerated().map { index, subGenre in
            SubGenre(
                id: subGenre.id,
                mainGenreId: seed.id,
                name: subGenre.name,
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
            mainGenreId: "sushi-seafood",
            subGenreId: "sushi-seafood-2",
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
