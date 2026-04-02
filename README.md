# journal_yamamoto

船舶操縦における環境場逆推定に関する論文原稿を、Typstで管理するためのリポジトリです。

## 概要

- 英語原稿: main.typ
- 日本語原稿: main_ja.typ
- 論文メタ情報（タイトル・著者・要旨）: paper_info.yaml
- 参考文献データ: references.bib
- 図: figs/
- スタイル・補助ライブラリ: libs/jasnaoe-conf/

## 必要環境

- Typst（CLI）

インストール例:

- macOS: brew install typst

## ビルド方法

### 英語版PDFを生成

typst compile main.typ main.pdf

### 日本語版PDFを生成

typst compile main_ja.typ main_ja.pdf

### 編集しながらプレビュー

typst watch main.typ main.pdf

必要に応じて main_ja.typ に置き換えてください。

## 使い方のメモ

- 著者情報や要旨は paper_info.yaml を編集します。
- 本文は main.typ または main_ja.typ を編集します。
- 文献は references.bib に追加し、本文内で引用キーを参照します。

## ディレクトリ構成

.
├── main.typ
├── main_ja.typ
├── paper_info.yaml
├── references.bib
├── figs/
└── libs/
	└── jasnaoe-conf/
		├── direct_bib_lib.typ
		├── jasnaoe-conf_lib.typ
		└── jasnaoe-reference.csl

## 注意事項

- コンパイルには Typst のバージョン差異による挙動差が生じる場合があります。
- フォントや環境依存で見た目が変わる場合は、ローカル環境のフォント設定を確認してください。
