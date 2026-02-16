# KA Apps

個人用macOSユーティリティアプリ集。Swift Package Managerでビルド（Xcode不要）。

## アプリ一覧

| アプリ | 説明 | ビルド | インストール先 |
|--------|------|--------|--------------|
| KA Window | ウィンドウ分割ショートカット | `bash build.sh` | `/Applications/KA Window.app` |
| KA Pointer | スポットライト・矩形ハイライト | `bash build-pointer.sh` | `/Applications/KA Pointer.app` |

## 命名規則

- すべてのアプリ名の頭に **KA** をつける
- 表示名: `KA Xxx`（スペースあり）
- コード識別子: `KAXxx`（スペースなし）
- バンドルID: `com.ka.xxx`

## 技術スタック

- macOS 14+, SwiftUI
- Swift Package Manager（`swift build`）
- メニューバー常駐（`MenuBarExtra` + `LSUIElement=true`）
- アクセシビリティ権限（`CGEvent tap`）
- Ad-hocコード署名（`codesign --force --sign -`）
- Sandbox無効（個人利用のみ）

## プロジェクト構成

```
Package.swift          # 全ターゲット定義（パッケージ名: KAApps）
build.sh               # KA Window ビルドスクリプト
build-pointer.sh       # KA Pointer ビルドスクリプト
KAWindow/              # KA Window ソース
  App/                 # エントリポイント, AppDelegate
  Core/                # WindowAction, WindowManager, Accessibility
  Hotkeys/             # HotkeyManager, HotkeyBinding, KeyCodeMap
  Settings/            # SettingsManager, LoginItemManager
  Views/               # MenuBarView, PreferencesView
KAPointer/             # KA Pointer ソース
  App/                 # エントリポイント, AppDelegate
  Core/                # ModifierKeyMonitor, Overlay, Spotlight, Rectangle
  Views/               # MenuBarView
```

## ビルド手順

```bash
# KA Window
bash build.sh
open "/Applications/KA Window.app"

# KA Pointer
bash build-pointer.sh
open "/Applications/KA Pointer.app"
```

初回起動時はシステム設定 > プライバシーとセキュリティ > アクセシビリティで許可が必要。
リビルド後はバイナリが変わるため、権限の再付与が必要な場合がある。

各アプリの詳細は各ディレクトリ内の `アプリ名.md` を参照。
