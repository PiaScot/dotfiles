# Ubuntu apt に無い(または非推奨な)開発コマンド一覧

## 調査方法

「TABキー補完に出る約2500個のコマンドを1つずつ判定する」のは非現実的な
コストになるため、代わりに `pacman -Qe`(このArch機で明示的に個別インス
トールしたパッケージ、依存関係で自動的に入ったものは除く、51件)を出発点
にした。Arch専用の概念や本調査に無関係なもの(`base`, `base-devel`,
`paru`, `paru-debug`, `ex-vi-compat`)と、Android SDK関連(方針により自動化
対象外)を除いた約39件について、実際にUbuntuのaptリポジトリに存在するかを
1つずつ確認した。

判定は2方向:

- **aptで入るもの** → [`packages/common.txt`](../packages/common.txt) に追
  加した(`chafa`, `httpie`, `tealdeer`, `tree-sitter-cli`, `lazygit`,
  `zoxide`)。既存の `ripgrep`/`fd-find`/`fzf`/`gh`/`mold`/`eza`/`jq`/
  `direnv`/`git`/`tmux`/`zsh`/`python3`/`postgresql`/`fish`/`ffmpeg`/
  `openjdk-17-jdk` などは元々問題なくaptで入ることを確認済み。
- **aptで実質入らない(または著しく古い/別物)もの** → 下表にまとめる。

## 一覧

| COMMAND NAME | DESCRIPTION | どういった時に利用するのか | 作者/組織 | 最終バージョン(調査時点) |
|---|---|---|---|---|
| `flutter` | Google製のクロスプラットフォームUIフレームワーク兼CLI | モバイル/デスクトップ/Webアプリを1つのDartコードベースで開発する時 | Google (Flutter team) | 3.41.2 (stable) |
| `pnpm` | 高速・省ディスクなNode.jsパッケージマネージャ | npm/yarnの代替。モノレポやディスク節約をしたい時 | pnpm (作者: Zoltan Kochan) | 11.3.0 |
| `starship` | 高速・カスタマイズ可能なクロスシェルプロンプト | zsh/fish/bash等でGit状態や言語バージョンを表示するリッチなプロンプトが欲しい時 | Starship contributors (作者: Matan Kushner) | 1.26.0 |
| `uv` | Rust製の超高速Pythonパッケージ/プロジェクトマネージャ | pip/venv/pip-toolsの代替。Python依存関係解決を高速化したい時 | Astral | 0.12.10 |
| `docker` (+ `buildx`/`compose` プラグイン) | コンテナ実行エンジンとCLI | コンテナのビルド・実行・マルチコンテナ構成(compose)を扱う時 | Docker, Inc. | Engine 29.7.2 / buildx 0.37.0 / compose 5.5.1 |
| `go` | Googleのプログラミング言語ツールチェイン | Ubuntu の `golang-go` は数バージョン遅れているため、最新版が必要な開発では公式tarballを使う(`scripts/toolchains.sh` で自動化済み) | Google (Go team) | go1.27.1 |
| `node` / `npm` | JavaScript実行環境とその同梱パッケージマネージャ | Ubuntu の `nodejs`/`npm` は現行LTSより古いビルドになりがち。本リポジトリは pnpm 経由(`pnpm env use --global lts`)でNode本体も導入する方式を採用済み(詳細は [tool-management-strategy.md](tool-management-strategy.md)) | OpenJS Foundation (原作者: Ryan Dahl) | Node 22 "Jod" (22.23.2, LTS) |
| `rar` | 独自形式RARの圧縮/展開ツール(有償・非フリー) | RAR形式のアーカイブを**作成**する必要がある時。展開だけなら universe の `unrar-free` で足りることが多い | RARLAB (作者: Alexander Roshal) | 7.23 |

## 個別メモ

- **`docker`**: Ubuntu には旧世代の `docker.io` パッケージがあるが、
  `buildx`/`compose` プラグインを含む現行の Docker Engine を使うには
  Docker公式のaptリポジトリ(`download.docker.com`)を別途追加する必要が
  ある。
- **`go`**: `apt install golang-go` 自体は通じるが「数バージョン遅れ」が
  常態化しているため、本リポジトリは意図的に公式tarballルートを採用して
  いる(既に `scripts/toolchains.sh` で実装済み)。
- **`node`/`npm`**: 同様にaptのnodejsは古い。NodeSourceの公式リポジトリを
  追加する方法もあるが、本リポジトリは既に導入済みの `pnpm` 経由での導入
  で完結させている(nvm/n等の追加ツールは不要。詳細は
  [tool-management-strategy.md](tool-management-strategy.md) 参照)。
- **`rar`**: `packages/common.txt` に含めるかどうかは要検討。RAR
  **作成**が本当に必要でなければ、multiverse不要な `unrar-free`
  (universe)への置き換えで十分な可能性がある。今回は既存の記載を維持し、
  ここに注記のみ残す。
