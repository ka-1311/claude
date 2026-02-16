# KA Pointer

スクリーンポインタハイライトアプリ。ScreenPointer の代替。

## 操作

| 操作 | トリガー |
|------|---------|
| スポットライト ON/OFF | 左Cmd+右Cmd 同時押し（トグル） |
| 矩形ハイライト ON/OFF | 左Cmd+右Cmd+Shift 同時押し（トグル） |

## 注意事項

- JISキーボード環境
- Xcodeはインストールされていない（`swift build`のみ使用）
- リビルド時は `tccutil reset Accessibility com.ka.pointer` で権限リセット可能
- スポットライト半径: 60px
- 左右Cmdの同時押しはCGEvent tapのflagsChangedイベントでkeycode 55(左)/54(右)を個別追跡して検出
