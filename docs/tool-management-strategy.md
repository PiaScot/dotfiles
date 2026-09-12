# 開発ツール導入戦略: mise比較 / Node周りの簡素化 / システム全体 vs プロジェクト単位

[docs/commands.md](commands.md) の調査結果を踏まえた、ツール導入方法の戦略
まとめ。

## 1. `mise` との比較 -- 個別 `curl` は本当にベストか

現状は「GitHub/公式サイトから個別に `curl` する」方式(zoxide→apt化済み、
starship/pnpm/neovimはcurl script、go/rust/flutterは各公式手順)。これを
`mise`(旧rtx、asdf互換の統一バージョンマネージャ)に統一できないか検証し
た結果は以下の通り。

### mise で代替できる範囲

`mise` のレジストリには [docs/commands.md](commands.md) に挙げたツールの
多くが実際に登録されている(`ripgrep`, `fzf`, `zoxide`, `gh`, `jq` など)。
CLIユーティリティ単体の導入だけを見れば、`mise use -g ripgrep@latest` の
ような統一コマンドで多くを賄えるのは事実。

### それでも個別インストーラ/aptを維持すべき理由

| 観点 | apt / 公式インストーラ(現状) | mise統一 |
|---|---|---|
| Flutter | 公式 `git clone -b stable` | **非推奨**: mise公式flutterプラグインは2026年5月にarchive済みでメンテ終了 |
| JDK/Go/Rust | `home/.zshrc` のハードコードパス(`/usr/lib/jvm/...`, `/usr/local/go`, `~/.cargo`)とそのまま一致 | パスをmiseのshim形式に書き換える必要があり、既存dotfilesへの変更が大きい |
| セキュリティ更新 | apt経由のものは `unattended-upgrades` 等ディストリの仕組みに自動的に乗る | mise管理下のバイナリは自分で更新確認が必要 |
| 依存の追加 | 追加ツール不要(apt/curlのみ) | miseというツール自体への依存が増える |
| CLIツールのバージョン鮮度 | apt/curl scriptはやや古い場合がある(例: go, node) | 常に最新に追従しやすい |

### 結論

**「個別curl/apt」路線を維持するのが妥当**。理由は、(a) Flutterのmise
プラグインがarchive済みで実用不可、(b) JAVA_HOME等のパスがハードコードさ
れておりmise化すると dotfiles 側の変更コストが大きい、(c) システム全体の
ベースライン導入(後述のGo/Rust/Javaの「最低限グローバルに1つ」)には
apt/公式インストーラの方が自動更新やディストリとの統合の面で相性が良い、
ため。

ただし、**per-project(プロジェクト単位)のバージョン切り替えに限っては
miseは有効な選択肢**(4節を参照)。「システム全体をmiseに統一する」ので
はなく「プロジェクトごとの一時的なバージョン切り替えにmiseを足す」という
併用が最もバランスが良い。

## 2. mise が実際に不要になった箇所

前回の作業で `scripts/install.sh` は `mise` を curl インストールするだけ
で一切使っていなかったため削除済み。今回さらに `zoxide` を curl script
から `packages/common.txt`(apt)に切り替えた(Ubuntu universeに
`zoxide` パッケージが存在することを確認済み)。同様に `starship` は
Ubuntu 24.04+ のaptにも存在するが**古い**ため、現状の公式curlインストーラ
のまま維持する。

## 3. npm / Node.js / pnpm の導入が面倒な問題

### 結論: nvm/n は不要。pnpmだけで完結する

指摘の通り「Node/npmを先に入れて、それからnvmやnを...」という順序で考え
ると導入ステップが増えて面倒に感じるが、これは不要な複雑化である。

`pnpm` の公式インストーラ(`https://get.pnpm.io/install.sh`)は
**Node.jsが一切入っていない状態でも動く自己完結型バイナリ**を配置する。
つまり:

```
1. curl https://get.pnpm.io/install.sh | sh -   # Node不要、pnpm単体で完結
2. pnpm env use --global lts                     # これでNode.js本体が入る
3. npm はそのNode.jsに同梱されてくるので別途インストール不要
```

この3ステップで完結し、`nvm`・`n`・`fnm` のような別のバージョンマネージャ
は一切不要。本リポジトリの `scripts/install.sh`(pnpmインストール)→
`scripts/toolchains.sh`(`check_node` が `pnpm env use --global lts` を
呼ぶ)は既にこの順序で実装済み。

複数のNode.jsバージョンをプロジェクトごとに切り替えたくなった場合のみ、
`pnpm env use --global <version>` を都度実行するか、後述のmiseをプロジェ
クトスコープで導入する。

### 注意: `pnpm env` は非推奨化が進行中

調査時点で `pnpm env` サブコマンドは非推奨になりつつあり、将来的には
`pnpm runtime set node lts -g` に置き換わる見込み。現時点では `pnpm env`
はまだ動作するためこのまま利用しているが、`scripts/toolchains.sh` の
`check_node` は将来pnpmのメジャーアップデートで動かなくなる可能性がある
点は認識しておくこと。

## 4. Go/Rust/Java はシステム全体にインストールする必要があるか

### fzf/ripgrepの様な単体CLIユーティリティ

これらはプロジェクトに依存せず常時使うツールであり、footprint も小さいた
め**システム全体(apt)で問題ない**。ここは元々の認識通り。

### Go: システム全体に「1つだけ」で足りる

Go 1.21以降は `go.mod` の `go` ディレクティブと `GOTOOLCHAIN=auto`(デフォ
ルト)により、**プロジェクトが要求するGoツールチェインのバージョンを実行
時に自動ダウンロードして使う**仕組みが標準搭載されている。つまり:

- システム全体には最新の `go` バイナリを1つ入れておけば良い(現状の
  `scripts/toolchains.sh` の方針のままでOK)
- 各プロジェクトが古い/新しいGoバージョンを要求しても、`go build` 実行
  時に該当バージョンが自動取得されるため、手動でバージョンマネージャを
  用意する必要はない

### Rust: システム全体に「1つ」+ プロジェクトごとの `rust-toolchain.toml`

`rustup` は `rust-toolchain.toml` をプロジェクトルートに置くだけで、その
ディレクトリ内では自動的に指定バージョンのツールチェインに切り替わる
(`rustup` 自体がこれを解決する)。したがって:

- システム全体には `rustup` + デフォルトツールチェインを1つ入れておけば
  良い(現状の方針のままでOK)
- プロジェクトごとの固定は `rust-toolchain.toml` で十分。追加のバージョ
  ンマネージャは不要

### Java: やや事情が異なる。プロジェクト単位が必要なら mise を併用

Go/Rustと異なり、JDKはビルドツール自体を動かすために「最低1つのJVM」が
システムに要ることが多く、かつプロジェクトごとに要求JDKバージョンが大き
く異なるケース(8/11/17/21…)がGo/Rustより頻繁に起こる。選択肢は2つ:

1. **Gradle/Maven の toolchains機能**を使い、ビルド定義内でプロジェクト
   固有のJDKバージョンを宣言し、ビルドツールに自動ダウンロードさせる
   (システムのJAVA_HOMEはビルドツール起動用の最低限のJDKのままでよい)。
2. 案件によってJDKを頻繁に切り替える場合は、**プロジェクトディレクトリ
   に `.mise.toml` を置いてそのプロジェクトだけmise管理下のJDKを使う**
   (システム全体の `JAVA_HOME`/`home/.zshrc` は変更しない)。

いずれの場合も、**システム全体(`home/.zshrc` の `JAVA_HOME`)には現状通
りJDK 17のような「無難なデフォルト」を1つ置いておく**方針を推奨する
(`scripts/toolchains.sh` の現行実装のまま)。mise はそれを置き換えるので
はなく、必要なプロジェクトにだけ局所的に足すツールと位置づける。

### まとめ

| 言語 | システム全体への導入 | プロジェクト単位の切り替え |
|---|---|---|
| Go | 必要(最新1つ) | 不要(`GOTOOLCHAIN=auto` が自動対応) |
| Rust | 必要(最新1つ) | `rust-toolchain.toml` で十分(追加ツール不要) |
| Java | 必要(デフォルト1つ、例: JDK17) | Gradle/Maven toolchains、または必要な場合のみプロジェクト単位で `mise` を併用 |
