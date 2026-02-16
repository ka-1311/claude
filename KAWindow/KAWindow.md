# KA Window

ウィンドウ分割ショートカットアプリ。Rectangle/Magnet の代替。

## ショートカット

| 操作 | ショートカット |
|------|--------------|
| 左半分 | Cmd+Ctrl+← |
| 右半分 | Cmd+Ctrl+→ |
| 右上1/4 | Cmd+Ctrl+↑ |
| 右下1/4 | Cmd+Ctrl+↓ |
| 左2/3 | Cmd+Shift+Ctrl+← |
| 右1/3 | Cmd+Shift+Ctrl+→ |
| 最大化 | Cmd+Shift+Ctrl+Return |
| 次のディスプレイ | Cmd+Shift+Ctrl+↓ |
| 前のディスプレイ | Cmd+Shift+Ctrl+↑ |

## 注意事項

- JISキーボード環境
- Xcodeはインストールされていない（`swift build`のみ使用）
- リビルド時は `tccutil reset Accessibility com.ka.window` で権限リセット可能
- Preferences UIからショートカットのカスタマイズ、ログイン時自動起動の設定が可能
