# サンプル体験データ用 画像スロット（差し込み用の「箱」）

「完成イメージを体験する」（サンプルモード）の店舗サムネイルは、ジャンル別の
**8個の画像セット（箱）** で管理しています。現在は「SAMPLE — DROP IMAGE」の
プレースホルダが入っています。**同名の画像を上書き**すれば反映されます
（コード変更不要。`imageUrl: "asset:Sample…"` 経由でバンドル画像を表示）。

## 入れ方
1. 各スロットのパスに **同じファイル名（PNG）** で上書きコピー。
   例: `MyGourmetRanking/Assets.xcassets/SampleRamen.imageset/SampleRamen.png`
2. 拡張子を変える場合は、その `imageset/Contents.json` の `filename` も更新。
3. Xcodeで再ビルドすれば反映。

## 推奨仕様
- **正方形（1:1）／600×600px以上**（表示は中央クロップ `scaledToFill`）。
- 料理が中央に来る、明るく美味しそうな写真。

## スロット一覧（ジャンル単位・複数店舗で共有）
| スロット名 | ファイルパス | 被写体 | 使う店舗例 |
|---|---|---|---|
| `SampleRamen`    | `Assets.xcassets/SampleRamen.imageset/SampleRamen.png`       | ラーメン／つけ麺 | 青葉・一燈・AFURI 等 |
| `SampleSushi`    | `Assets.xcassets/SampleSushi.imageset/SampleSushi.png`       | 寿司・海鮮丼 | 寿司大・魚がし日本一 等 |
| `SampleYakiniku` | `Assets.xcassets/SampleYakiniku.imageset/SampleYakiniku.png` | 焼肉（盛り合わせ） | トラジ・スタミナ苑・叙々苑 |
| `SampleSukiyaki` | `Assets.xcassets/SampleSukiyaki.imageset/SampleSukiyaki.png` | すき焼き／鍋 | 今半 |
| `SampleCafe`     | `Assets.xcassets/SampleCafe.imageset/SampleCafe.png`         | カフェ（コーヒー） | ブルーボトル・トリコロール |
| `SampleYakitori` | `Assets.xcassets/SampleYakitori.imageset/SampleYakitori.png` | 焼き鳥（串） | 鳥茶屋・鳥貴族 |
| `SampleTeishoku` | `Assets.xcassets/SampleTeishoku.imageset/SampleTeishoku.png` | 定食／天丼／とんかつ | 金子半之助・まい泉 |
| `SampleCurry`    | `Assets.xcassets/SampleCurry.imageset/SampleCurry.png`       | カレー | CoCo壱番屋 |

> サンプルは**保存されない一時データ**です。実在店舗名は地図機能の体験用で、
> 画像はあくまでジャンルを表すイメージ（特定店舗の実写真である必要はありません）。

---

## Codex（画像生成AI）への依頼文（コピペ用）

> グルメ記録アプリの「サンプル体験モード」用に、料理ジャンルを表す**正方形（1:1）の
> 食べ物写真を8枚**生成してください。用途はアプリ内のサンプル店舗サムネイルです。
>
> 共通要件：
> - サイズ 1024×1024 の正方形、料理を中央に大きく配置
> - 実在店舗のロゴ・看板・人物・文字は写さない（料理そのものだけ）
> - 明るく自然光、美味しそうで上質、背景はシンプル（木目テーブルや無地）
> - 写真風リアルなクオリティ（イラストではなく料理写真）
>
> 生成してほしい8枚（ファイル名＝中身）：
> 1. **SampleRamen** … 醤油ラーメンまたはつけ麺。丼に入った湯気の立つ一杯
> 2. **SampleSushi** … 海鮮丼または握り寿司の盛り合わせ
> 3. **SampleYakiniku** … 焼肉の盛り合わせ（生肉の美しい霜降り、または網焼き）
> 4. **SampleSukiyaki** … すき焼き鍋（牛肉・春菊・豆腐・割下）
> 5. **SampleCafe** … カフェラテ／コーヒー（カフェの一杯）
> 6. **SampleYakitori** … 焼き鳥の串盛り（炭火）
> 7. **SampleTeishoku** … 和定食または天丼／とんかつ定食
> 8. **SampleCurry** … 欧風カレーライス
>
> 各画像は上記の名前で書き出してください（例: `SampleRamen.png`）。
