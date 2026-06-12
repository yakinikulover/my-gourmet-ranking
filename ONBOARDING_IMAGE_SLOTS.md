# オンボーディング画像スロット（差し込み用の「箱」）

オンボーディング各画面の料理画像は、下記の **10個の画像セット（箱）** で管理しています。
各箱には現在プレースホルダ（「DROP IMAGE HERE」と表示される画像）が入っています。
**同名の PNG を上書き**すれば、そのままアプリに反映されます（コード側の変更は不要）。

## 入れ方
1. 用意した画像を、各スロットのファイルパスに **同じファイル名** で上書きコピーする。
   例: `MyGourmetRanking/Assets.xcassets/OnbArchiveRamen.imageset/OnbArchiveRamen.png`
2. ファイル名や拡張子を変える場合は、その `imageset/Contents.json` の `filename` も合わせて更新する。
3. Xcode で再ビルドすれば反映。

## 推奨仕様
- **正方形（1:1）** を推奨。表示は中央クロップ（`scaledToFill`）です。
- 解像度は **600×600px 以上**（@3x 表示でも鮮明になるサイズ）。
- 形式は PNG または JPEG。
- 料理が中央に来る構図にすると枠内で見切れません。

## スロット一覧

### 画面01（表紙・ヒーローのポラロイド3枚）
| スロット名 | ファイルパス | 推奨被写体 |
|---|---|---|
| `OnbCoverRamen`  | `Assets.xcassets/OnbCoverRamen.imageset/OnbCoverRamen.png`   | ラーメン（看板の一杯） |
| `OnbCoverCurry`  | `Assets.xcassets/OnbCoverCurry.imageset/OnbCoverCurry.png`   | カレー |
| `OnbCoverSweets` | `Assets.xcassets/OnbCoverSweets.imageset/OnbCoverSweets.png` | デザート（プリン等） |

### 画面02（Best5・1位/2位の写真）
| スロット名 | 紐づく店名 | 推奨被写体 |
|---|---|---|
| `OnbBestSukiyaki` | すき焼き おか乃 | すき焼き／鍋 |
| `OnbBestDonburi`  | 海鮮丼 まる新   | 海鮮丼 |

### 画面04（Archive・5件のサムネ）
| スロット名 | 紐づく店名 | 推奨被写体 |
|---|---|---|
| `OnbArchiveRamen`    | 麺屋 こころ     | ラーメン |
| `OnbArchiveYakitori` | 炭火焼鳥 とり松 | 焼き鳥（串） |
| `OnbArchiveTeishoku` | 大衆食堂 いちは | 定食／大衆食堂の料理 |
| `OnbArchiveCurry`    | 欧風カレー ひだまり | 欧風カレー |
| `OnbArchiveKozara`   | 小料理 てまり   | 小料理／小鉢 |

> ※ これらは **ダミー（架空店舗）** 用の画像です。実在店舗の写真や、ライセンス不明のストック写真は使用しないでください（App Store 公開時の著作権・商標リスクになります）。
