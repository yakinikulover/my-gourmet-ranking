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

    // Sample/demo data for the "完成イメージを体験する" experience.
    // Real Tokyo restaurants across several genres. The first 13 have map
    // coordinates (shown as pins); the last 10 have none, so they appear in
    // "Map未登録を整理". This data is never persisted as the user's own.
    // Sample thumbnails are bundled assets (offline-safe). Drop real food photos
    // into these imagesets to replace the placeholders — see SAMPLE_IMAGE_SLOTS.md.
    private static let imgRamen = "asset:SampleRamen"
    private static let imgSushi = "asset:SampleSushi"
    private static let imgMeat = "asset:SampleYakiniku"
    private static let imgNabe = "asset:SampleSukiyaki"
    private static let imgCafe = "asset:SampleCafe"
    private static let imgFood = "asset:SampleYakitori"
    private static let imgSet = "asset:SampleTeishoku"
    private static let imgCurry = "asset:SampleCurry"

    static let sampleStores: [Store] = [
        // ── ラーメン・麺（最多＝既定表示・Best5が埋まる + Archive） ──
        sampleStore(id: "sample-ramen-1", name: "中華そば 青葉 中野本店", mainGenreId: "ramen", subGenreId: "ramen-1",
                    rank: .rank1, area: "東京 中野", memo: "ダブルスープの原点。何度でも戻ってきたくなる一杯。",
                    imageUrl: imgRamen, latitude: 35.7068, longitude: 139.6659),
        sampleStore(id: "sample-ramen-2", name: "麺屋 一燈", mainGenreId: "ramen", subGenreId: "ramen-1",
                    rank: .rank2, area: "東京 新小岩", memo: "濃厚魚介がとにかく丁寧。並ぶ価値あり。",
                    imageUrl: imgRamen, latitude: 35.7166, longitude: 139.8585),
        sampleStore(id: "sample-ramen-3", name: "AFURI 恵比寿", mainGenreId: "ramen", subGenreId: "ramen-1",
                    rank: .rank3, area: "東京 恵比寿", memo: "柚子塩の爽やかさ。重くないので〆にも。",
                    imageUrl: imgRamen, latitude: 35.6464, longitude: 139.7100),
        sampleStore(id: "sample-ramen-5", name: "蒙古タンメン中本 上板橋", mainGenreId: "ramen", subGenreId: "ramen-1",
                    rank: .rank5, area: "東京 上板橋", memo: "辛さがクセになる。4位はあえて空けて比較中。",
                    imageUrl: imgRamen, latitude: 35.7616, longitude: 139.6740),
        sampleStore(id: "sample-ramen-arc-1", name: "三田製麺所 三田本店", mainGenreId: "ramen", subGenreId: "ramen-1",
                    rank: .archive, previousRank: 4, area: "東京 三田", memo: "前は4位。つけ汁は好きだけど再訪頻度は落ちた。",
                    imageUrl: imgRamen, latitude: 35.6485, longitude: 139.7470),
        sampleStore(id: "sample-ramen-arc-2", name: "せたが屋 駒沢本店", mainGenreId: "ramen", subGenreId: "ramen-1",
                    rank: .archive, area: "東京 駒沢", memo: "深夜に染みる醤油。Best入りは保留。",
                    imageUrl: imgRamen, latitude: 35.6262, longitude: 139.6620),

        // ── 寿司・海鮮 ──
        sampleStore(id: "sample-sushi-1", name: "寿司大 豊洲市場", mainGenreId: "sushi-seafood", subGenreId: "sushi-seafood-1",
                    rank: .rank1, area: "東京 豊洲", memo: "朝から並ぶ価値。おまかせの満足度が段違い。",
                    imageUrl: imgSushi, latitude: 35.6449, longitude: 139.7860),
        sampleStore(id: "sample-sushi-2", name: "立喰い寿司 魚がし日本一 新橋店", mainGenreId: "sushi-seafood", subGenreId: "sushi-seafood-1",
                    rank: .rank2, area: "東京 新橋", memo: "サクッと立ち食い。コスパと鮮度のバランス◎。",
                    imageUrl: imgSushi, latitude: 35.6662, longitude: 139.7585),

        // ── 焼肉・肉料理 ──
        sampleStore(id: "sample-meat-1", name: "焼肉 トラジ 恵比寿本店", mainGenreId: "meat", subGenreId: "meat-1",
                    rank: .rank1, area: "東京 恵比寿", memo: "接待でも普段でも。タレ焼肉の安定感。",
                    imageUrl: imgMeat, latitude: 35.6470, longitude: 139.7110),
        sampleStore(id: "sample-meat-2", name: "スタミナ苑", mainGenreId: "meat", subGenreId: "meat-1",
                    rank: .rank2, area: "東京 鹿浜", memo: "並んででも食べたいホルモン。遠征の価値あり。",
                    imageUrl: imgMeat, latitude: 35.7860, longitude: 139.7895),

        // ── 和食・すき焼き ──
        sampleStore(id: "sample-japanese-1", name: "人形町 今半 本店", mainGenreId: "japanese", subGenreId: "japanese-1",
                    rank: .rank1, area: "東京 人形町", memo: "王道のすき焼き。割下の余韻まで上品。",
                    imageUrl: imgNabe, latitude: 35.6856, longitude: 139.7820),

        // ── 焼鳥・串 ──
        sampleStore(id: "sample-yakitori-1", name: "鳥茶屋 別亭", mainGenreId: "yakitori-kushi", subGenreId: "yakitori-kushi-1",
                    rank: .rank1, area: "東京 神楽坂", memo: "炭の香りが効いた一本。うどんすきも有名。",
                    imageUrl: imgFood, latitude: 35.7010, longitude: 139.7400),

        // ── カフェ・スイーツ ──
        sampleStore(id: "sample-cafe-1", name: "ブルーボトルコーヒー 清澄白河", mainGenreId: "cafe-sweets", subGenreId: "cafe-sweets-1",
                    rank: .rank1, area: "東京 清澄白河", memo: "一杯ずつ淹れる丁寧さ。空間も気持ちいい。",
                    imageUrl: imgCafe, latitude: 35.6817, longitude: 139.7980),

        // ── Map未登録（10件・座標なし → 「Map未登録を整理」に出る） ──
        sampleStore(id: "sample-un-1", name: "すしざんまい 築地本店", mainGenreId: "sushi-seafood", subGenreId: "sushi-seafood-1",
                    rank: .rank3, area: "東京 築地", memo: "24時間の安心感。場所はあとで登録予定。", imageUrl: imgSushi),
        sampleStore(id: "sample-un-2", name: "叙々苑 游玄亭 西麻布", mainGenreId: "meat", subGenreId: "meat-1",
                    rank: .rank3, area: "東京 西麻布", memo: "特別な日の焼肉。", imageUrl: imgMeat),
        sampleStore(id: "sample-un-3", name: "天丼 金子半之助 日本橋本店", mainGenreId: "setmeal-don", subGenreId: "setmeal-don-1",
                    rank: .rank1, area: "東京 日本橋", memo: "穴子が立つ天丼。", imageUrl: imgSet),
        sampleStore(id: "sample-un-4", name: "とんかつ まい泉 青山本店", mainGenreId: "setmeal-don", subGenreId: "setmeal-don-1",
                    rank: .rank2, area: "東京 青山", memo: "やわらかヒレ。", imageUrl: imgSet),
        sampleStore(id: "sample-un-5", name: "喫茶 トリコロール 本店", mainGenreId: "cafe-sweets", subGenreId: "cafe-sweets-1",
                    rank: .rank2, area: "東京 銀座", memo: "ネルドリップの王道喫茶。", imageUrl: imgCafe),
        sampleStore(id: "sample-un-6", name: "カレーハウス CoCo壱番屋 新宿東口店", mainGenreId: "curry-ethnic", subGenreId: "curry-ethnic-1",
                    rank: .rank1, area: "東京 新宿", memo: "間違いない安心のカレー。", imageUrl: imgCurry),
        sampleStore(id: "sample-un-7", name: "鳥貴族 新宿東口店", mainGenreId: "yakitori-kushi", subGenreId: "yakitori-kushi-1",
                    rank: .rank2, area: "東京 新宿", memo: "気軽に串たくさん。", imageUrl: imgFood),
        sampleStore(id: "sample-un-8", name: "一蘭 渋谷スペイン坂店", mainGenreId: "ramen", subGenreId: "ramen-1",
                    rank: .archive, area: "東京 渋谷", memo: "集中して食べたい日に。", imageUrl: imgRamen),
        sampleStore(id: "sample-un-9", name: "大勝軒 永福町", mainGenreId: "ramen", subGenreId: "ramen-1",
                    rank: .archive, area: "東京 永福町", memo: "量も満足の中華そば。", imageUrl: imgRamen),
        sampleStore(id: "sample-un-10", name: "銀座 篝 本店", mainGenreId: "ramen", subGenreId: "ramen-1",
                    rank: .archive, area: "東京 銀座", memo: "鶏白湯SOBA。並びは覚悟。", imageUrl: imgRamen)
    ]

    private static func sampleStore(
        id: String,
        name: String,
        mainGenreId: String,
        subGenreId: String,
        rank: StoreRank,
        previousRank: Int? = nil,
        area: String,
        memo: String,
        imageUrl: String,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) -> Store {
        let hasCoordinate = latitude != nil && longitude != nil
        return Store(
            id: id,
            name: name,
            mainGenreId: mainGenreId,
            subGenreId: subGenreId,
            rank: rank,
            previousRank: previousRank,
            area: area,
            memo: memo,
            imageUrl: imageUrl,
            mapUrl: hasCoordinate ? "https://maps.apple.com/?ll=\(latitude!),\(longitude!)" : nil,
            latitude: latitude,
            longitude: longitude,
            createdAt: timestamp,
            updatedAt: timestamp
        )
    }
}
