# dotfiles 再構成設計: Ubuntu 26.04 Server 対応 + WSL/非WSL・Desktop/Server分岐

- Status: Approved (design), pending implementation plan
- Date: 2026-09-12
- Scope owner: PiaScot (crcrunchypp0215@gmail.com)

## 背景・目的

このリポジトリは chezmoi 等の外部パッケージに頼らず、自作の backup & restore
の仕組みで異なる Linux 環境(WSL を含む)でも同じお気に入りの CLI 環境を再現
することを目的としている。

現状は Ubuntu(主に WSL2 上の Ubuntu)のみを想定した構成になっており、以下の
課題がある。

- Ubuntu 26.04 Server(非デスクトップ、SSH 接続前提のヘッドレス環境)への
  対応がない。
- WSL 固有の処理(`/etc/wsl.conf`、win32yank によるクリップボード連携)と、
  Windows ホスト側でしか使わないファイル(`.wezterm.lua`,
  PowerShell プロファイル)が区別されずリポジトリ直下に混在している。
- 唯一のインストーラである `setup.sh` が未完成・バグを含んだ状態で放置され
  ている(詳細は「既存 setup.sh の既知バグと対処」参照)。
- `$HOME` 全体を対象にした backup の仕組みがない。

なお、現在の開発機は WSL2 上の Arch Linux であり、本リポジトリが対象とする
Ubuntu 環境ではない。そのため今回のスコープは **リポジトリの再設計とスクリプ
ト実装まで** とし、実機(Ubuntu Desktop/Server/WSL)への適用検証はスコープ外
とする。検証は `shellcheck` / `bash -n` / `--dry-run` に留める。

## 用語・分岐軸

サポート対象を決める軸は独立した3つがある。混同しないこと。

1. **WSL か 非WSL(bare-metal/VM)か**
   Linux カーネルが WSL2 かどうか。`wsl.conf` 編集、win32yank 配置、
   resolv.conf 制御など、WSL というレイヤーに起因する処理が対象。
2. **Desktop(GUI) か Server(headless) か**
   そのマシン自身が GUI ターミナル/フォント描画を必要とするか。
   Server は基本的に他マシンから SSH で接続して使うため、フォントや
   GUI 系ツールは不要(SSH 接続元でレンダリングされるため)。
   この軸は自動判定せず、`install.sh --profile desktop|server` として
   明示的に指定する(GUI有無のヒューリスティック判定は誤検出リスクが高い
   ため)。
3. **Windows ホスト側**
   `.wezterm.lua` と PowerShell プロファイルは、そもそも Linux 側の
   dotfiles ではなく **Windows 上で動くアプリの設定** である
   (`.wezterm.lua` は `default_prog = {"wsl", "--cd", "~"}` のように
   WSL を呼び出す Windows 側の設定)。Ubuntu/WSL/Server いずれのプロファイル
   にも属さない独立カテゴリとして扱う。

`.config/nvim/plugin/option.lua` は既に `vim.fn.has("wsl")` で実行時分岐して
おり、これは理想的なパターン(dotfiles 本体を環境ごとに分岐させず、ランタイム
判定に寄せる)。今回の再構成でもこの方針を踏襲し、**インストール時にしか吸収
できないもの(バイナリ配置・/etc 編集・パッケージ一覧・フォント導入)だけ**
を profile スクリプト側に分岐させる。dotfiles 本体(home/ 以下)は環境間で
分岐させない。

## 採用アプローチ

検討した2案のうち、案A(フラット共有ツリー + プロファイル分岐はスクリプト
側のみ)を採用する。

- **案A(採用)**: dotfiles 本体は `home/` に一本化し、環境差分は
  `profiles/*.sh` と `packages/*.txt` に閉じ込める。現状の分岐量(数個の
  インストール手順の違い)に対して過不足がない、YAGNI に沿った選択。
- **案B(見送り、将来の拡張余地として記録)**: `layers/base/`,
  `layers/wsl/`, `layers/desktop/` のようにレイヤーを重ねて同一相対パスの
  ファイルを後勝ちでマージする自作オーバーレイ方式。dotfiles 本体まで環境
  ごとに分岐させる必要が生じた場合に検討する。現時点では過剰設計。

## ディレクトリ構成(最終形)

```
dotfiles/
├── README.md
├── .gitignore
├── home/                        # $HOMEへそのままミラー配置する実体(ドット付きのまま)
│   ├── .zshrc
│   ├── .tmux.conf
│   ├── .config/
│   │   ├── nvim/
│   │   ├── fish/
│   │   ├── htop/
│   │   └── zellij/
│   └── .cargo/
│       └── config.toml
├── windows-host/                # Windows側で使うもの。Linux restoreの対象外
│   ├── .wezterm.lua
│   ├── Microsoft.PowerShell_profile.ps1   # 既存のファイル名タイポ(Powershell→PowerShell)を修正
│   └── install.ps1              # Windows側にコピーする参考インストーラ(Windows実機では未検証)
├── packages/
│   ├── common.txt               # 全Ubuntu共通のaptパッケージ
│   ├── desktop.txt               # Desktopでのみ追加するパッケージ
│   └── wsl.txt                   # WSL専用パッケージ(wslu等)
├── profiles/
│   ├── wsl.sh                    # wsl.conf/resolv.conf編集、win32yank配置
│   ├── desktop.sh                 # Nerd Fontsダウンロード&インストール
│   └── server.sh                  # 現状スタブ(将来用)
├── scripts/
│   ├── lib.sh                     # log/has/detect_wsl等の共通関数
│   ├── backup.sh                  # $HOME上の管理対象をtimestamp付きでスナップショット
│   ├── restore.sh                 # home/の中身を$HOMEへsymlink配置(事前にbackup.sh呼び出し)
│   └── install.sh                 # 上記を統括するメインエントリ
├── setup.sh                       # scripts/install.shを呼ぶ薄いラッパー
└── docs/superpowers/specs/2026-09-12-ubuntu-multi-env-restructure-design.md
```

### 現状ファイルの移行マッピング

| 現在のパス | 新しいパス | 備考 |
|---|---|---|
| `.zshrc` | `home/.zshrc` | |
| `.tmux.conf` | `home/.tmux.conf` | |
| `.config/nvim`, `.config/fish`, `.config/htop`, `.config/zellij` | `home/.config/<同名>` | |
| `.cargo/config.toml` | `home/.cargo/config.toml` | |
| `.wezterm.lua` | `windows-host/.wezterm.lua` | Windows側専用と明記 |
| `Microsoft.Powershell_profile.ps1` | `windows-host/Microsoft.PowerShell_profile.ps1` | ファイル名タイポ修正(Powershell→PowerShell) |
| `setup.sh` | `scripts/install.sh` 他へ分割。ルートには薄いラッパーを残す | 下記バグをすべて修正 |
| `.gitignore` | 更新 | `dot_config/nvim/lazy-lock.json` → `home/.config/nvim/lazy-lock.json`、`backups/` を追加 |

## `$HOME/.config` の扱い

`~/.config` には本リポジトリが管理しないアプリ設定(npm, gradle, dart 等)が
大量に存在しうるため、**`.config` 全体を1個の symlink にはしない**。

`restore.sh` は次のルールで symlink する。

- `home/` 直下のトップレベルエントリ(`.zshrc`, `.tmux.conf`)→
  `$HOME/<同名>` に直接symlink
- `home/.config/*` の各サブディレクトリ(nvim, fish, htop, zellij)→
  `$HOME/.config` を実ディレクトリとして用意した上で、
  `$HOME/.config/<同名>` に個別symlink
- `home/.cargo/*` も同様に `$HOME/.cargo` を実ディレクトリとして用意し、
  `$HOME/.cargo/config.toml` を個別symlink

## スクリプト設計

### `scripts/lib.sh`
共通関数: `info/warn/error/completed`(ログ)、`has()`、`is_wsl()`、
`get_os_id()`(/etc/os-release の `ID` を返す)、`require_os_ubuntu_debian()`。

### `scripts/backup.sh`
`restore.sh` が上書きする対象パス一覧を受け取り、既存の実体(symlink でない
ファイル/ディレクトリ)を `backups/<timestamp>/<相対パス>` へ退避する。単体
実行も可能(`./scripts/backup.sh` で $HOME 上の管理対象を今すぐスナップ
ショット)。`--dry-run` で退避予定一覧のみ表示。

### `scripts/restore.sh`
上記「`$HOME/.config` の扱い」のルールに従い `home/` の内容を symlink す
る。実行前に対象パスを `backup.sh` に渡して退避してから symlink を張る。
`--dry-run` で実行計画のみ表示。

### `scripts/install.sh`(メインエントリ)

フロー:

1. 引数パース: `--profile desktop|server`(必須)、`--dry-run`(任意)。
   WSL は `is_wsl()` で自動検出。
2. `check_essential_commands`(既存ロジック踏襲)
3. `/etc/os-release` の `ID` が `ubuntu`/`debian` 以外なら明確なエラーで
   中断(このスクリプトは Ubuntu/Debian 系専用)
4. `scripts/backup.sh` 実行
5. `packages/common.txt` + (`--profile desktop` なら `packages/desktop.txt`)
   + (WSL 検出なら `packages/wsl.txt`) を `apt-get install -y` でまとめて
   導入
6. サードパーティツール導入(zoxide, starship, mise, neovim, pnpm)
7. `scripts/restore.sh` 実行
8. WSL 検出時: `profiles/wsl.sh` 実行
9. `profiles/${PROFILE}.sh` 実行(desktop または server)
10. nvim の `option.lua` 内 python3 パスを実行環境に合わせて書き換え
11. 完了メッセージ

`main "$@"` を末尾で明示的に呼び出す(現行 `setup.sh` の「`main` が定義され
ているのに呼ばれない」バグを解消)。

### `profiles/wsl.sh`
- `/etc/wsl.conf` を heredoc で正しく生成(`[interop] appendWindowsPath=false`,
  `[network] generateResolvConf=false`)
- `/etc/resolv.conf` は「内容を書き込んでから `chattr +i` で immutable 化」
  という正しい順序に修正(現行は削除後に書き込まず immutable 化しようとして
  壊れている)
- win32yank の最新リリースを GitHub から取得し、`win32yank.exe` を
  `/mnt/c/Tools/win32yank.exe` に配置(ディレクトリが無ければ作成)。
  既に同一バージョンが配置済みならスキップ(冪等)

### `profiles/desktop.sh`
README に記載されている Nerd Fonts(GoMono, IosevkaTermSlab, UDEV Gothic)を
ダウンロードし `~/.local/share/fonts` に配置、`fc-cache` を実行するよう自動
化する(現状は README にリンクがあるだけで手動作業だったものを自動化)。

### `profiles/server.sh`
現時点では特別な処理なし。将来の拡張用にコメント付きスタブとして用意する。

### `windows-host/install.ps1`
`windows-host/.wezterm.lua` を `%USERPROFILE%\.wezterm.lua` に、
`Microsoft.PowerShell_profile.ps1` を `$PROFILE` にコピーする参考スクリプ
ト。Windows 実機が無いため今回は動作検証しない(コードレビューレベルの品質
に留める)。

## 既存 `setup.sh` の既知バグと対処

| バグ | 対処 |
|---|---|
| `main()` が定義されているのに一度も呼ばれず、末尾で無条件に `apt_install_packages` のみ実行される | `install.sh` 末尾で `main "$@"` を明示的に呼ぶ |
| `configure_wsl` の `echo "...\n..."` が `-e` もリダイレクトも無くファイルに書き込まれない。かつ `/etc/resolv.conf` を削除した直後に(書き込まないまま) `chattr +i` しようとしている | `profiles/wsl.sh` で heredoc により正しい順序(書き込み→immutable化)に修正 |
| `sudo apt install $pkgs`(配列を無引用展開、`install`は`apt-get`推奨) | `sudo apt-get install -y "${pkgs[@]}"` |
| `install_dotfiles` 内 `mv -R`(`mv`に`-R`オプションは存在しない) | symlink ベースの `restore.sh` に置き換えて廃止 |
| neovim tarball: ダウンロードファイル名(`nvim-linux-x86_64.tar.gz`)と展開対象ファイル名(`nvim-linux64.tar.gz`)が不一致 | ファイル名を一致させて修正 |
| `local target_file = "$HOME/..."`(bash では `=` の前後にスペースがあると構文エラー) | `local target_file="$HOME/..."` に修正 |
| `.gitignore` が実在しない `dot_config/nvim/lazy-lock.json` を無視指定 | `home/.config/nvim/lazy-lock.json` に修正し、`backups/` を追加 |

## エラーハンドリング方針

- 全スクリプト `set -eu`(既存踏襲)を維持し、`pipefail` も追加する。
- 対応外 OS(Ubuntu/Debian 系以外)を検出したら、`install.sh` は早期に
  明確なエラーメッセージを出して終了する。
- `profiles/wsl.sh` 内のネットワーク取得(win32yank ダウンロード等)は
  失敗時に警告を出しつつ後続処理は継続する(致命的にしない)。

## バックアップ設計

- `scripts/backup.sh` により、`restore.sh` が上書きする直前の実体を
  `backups/<timestamp>/` に退避する。`backups/` は `.gitignore` 対象。
- 今回の作業では、このリポジトリを Arch Linux(対象外OS)の実機に対して
  実際には適用しない。したがって `$HOME` への実適用およびその前段の実バッ
  クアップ取得は行わない。将来 Ubuntu 実機に対して初回適用する際に
  `scripts/backup.sh` 経由で安全スナップショットを取得する運用とする。

## テスト方針

- 全 `.sh` に対し `shellcheck` と `bash -n` を実行し、警告・エラーを解消
  する。
- `install.sh` / `restore.sh` / `backup.sh` に `--dry-run` フラグを実装し、
  実際のファイル操作・パッケージ導入を行わず実行計画を標準出力するのみに
  する。設計レビュー・CI 相当の確認はこの `--dry-run` 出力で行う。
- Ubuntu 実機(Desktop/Server/WSL)での実地検証は本スコープ外(ユーザー
  側で今後実施)。

## スコープ外(今回やらないこと)

- 現在の実機($HOME、WSL2 上 Arch Linux)への実適用・実バックアップ取得
- Ubuntu 実機での動作確認・自動テスト(bats 等)の整備
- 案B(レイヤー型オーバーレイ)の実装
- Windows ホスト側 `.ps1` の実機検証
