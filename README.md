# My Gourmet Ranking

個人用のiPhone向けグルメランキング管理アプリ。

## セットアップ

1. Xcode 16.3以降で `MyGourmetRanking.xcodeproj` を開く
2. Schemeで `MyGourmetRanking` を選択する
3. iPhone Simulatorを選択してRunする

## ビルド

```sh
xcodebuild -project MyGourmetRanking.xcodeproj \
  -scheme MyGourmetRanking \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## 概要

大ジャンル・小ジャンルごとに飲食店を管理し、Best1〜5とArchiveに分けて記録できます。

## 技術構成

- SwiftUI
- Xcode project
- UserDefaults(JSON)保存

## 主な機能

- 大ジャンルと小ジャンルの選択に応じたランキング表示
- Best1〜5と未登録順位のTBD表示
- Best5外店舗のArchive管理
- 店舗の登録・詳細確認・編集・Archive移動・削除
- 設定画面での登録データ、ジャンル、種類の管理
- 初期ジャンル・種類データの自動投入
- 端末内UserDefaults保存
