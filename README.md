# dotfiles

chezmoi 等の外部パッケージに頼らず、自作の backup & restore の仕組みで
異なる Linux 環境(WSL を含む)でも同じ CLI 環境を再現するためのリポジトリ。

対応環境: Ubuntu(Desktop / Server)、WSL2 上の Ubuntu。

設計の背景・意図は
[docs/superpowers/specs/2026-09-12-ubuntu-multi-env-restructure-design.md](docs/superpowers/specs/2026-09-12-ubuntu-multi-env-restructure-design.md)
を参照。

## ディレクトリ構成

```
home/           # $HOMEへそのままミラー配置される実体(zsh, tmux, nvim, fish, htop, zellij, cargo)
windows-host/   # Windows側で使うもの(.wezterm.lua, PowerShellプロファイル)。Linux restoreの対象外
packages/       # apt パッケージ一覧(common / desktop / wsl)
profiles/       # インストール時にのみ分岐する処理(wsl / desktop / server)
scripts/        # lib.sh, backup.sh, restore.sh, install.sh, toolchains.sh
```

`home/` 以下は **symlink** で `$HOME` に配置される(コピーではない)。
つまり `~/.zshrc` を編集する = `home/.zshrc` を直接編集することになり、
`git diff` がそのまま「今の変更点」になる。運用方法(破壊的な変更を安全に
試す方法など)は [docs/symlink-workflow.md](docs/symlink-workflow.md) を参照。

## 使い方

```sh
./setup.sh --profile desktop   # GUI/フォントを使うUbuntu Desktop向け
./setup.sh --profile server    # ヘッドレスなUbuntu Server向け(SSH接続前提)
./setup.sh --profile desktop --dry-run   # 実際には変更せず実行計画のみ表示
```

WSL2 上で実行した場合は `is_wsl` の自動検出により `profiles/wsl.sh` が
追加で実行され、`/etc/wsl.conf` の設定と win32yank の配置
(`/mnt/c/Tools/win32yank.exe`)が自動化される。

`home/.zshrc` は [zsh4humans (z4h)](https://github.com/romkatv/zsh4humans)
を前提としており、`home/.zshenv` がその自己ブートストラップ用ファイル。
両方が symlink されて初めて `.zshrc` は動く。

## 言語ツールチェイン(scripts/toolchains.sh)

`home/.zshrc` の `path=(...)` と `*_HOME` 環境変数(`JAVA_HOME`,
`/usr/local/go`, `$HOME/.cargo`, `$HOME/flutter`, `$PNPM_HOME`)は、対応する
ツールが実際にインストールされていることを前提にしている。symlink するだけ
ではこれらは入らないため、`scripts/install.sh` は最後に
`scripts/toolchains.sh` を実行し、各ツールを**検証し、無ければ公式手順で導
入**する。

| ツール | 検証パス | 導入方法 |
|---|---|---|
| JDK 17 | `/usr/lib/jvm/java-17-openjdk-amd64` | `apt-get install openjdk-17-jdk` |
| Go | `/usr/local/go` | 公式tarballを取得し `/usr/local` に展開 |
| Rust | `~/.cargo/bin/cargo` | rustup公式インストーラ |
| Flutter | `~/flutter/bin/flutter` | `git clone -b stable` |
| Node.js | `node` コマンド | pnpm経由 (`pnpm env use --global lts`) |

単体実行/確認のみ: `./scripts/toolchains.sh --dry-run`

**Android SDK は自動導入しない。** ダウンロード時間とライセンス同意等が複雑
なため、`$ANDROID_HOME` の有無を検出して警告するだけに留めている。必要な場
合は手動でセットアップすること。

`mise` は以前バイナリだけ導入されて実際には未使用だったため削除した。上記
の通り、各ツールはハードコードされたパス(`.zshrc`側)に合わせて公式インス
トーラで個別導入する方式を採用している(Flutterのmiseプラグインは
archive済みで非推奨のため)。

## Windows Terminal / wezterm

- ColorScheme
  - [Kanagawa](https://github.com/rebelot/kanagawa.nvim/blob/master/extras/windows_terminal.json)
  - [Tokyonight](https://github.com/folke/tokyonight.nvim/tree/main/extras/windows_terminal)
  - [List](https://github.com/rjcarneiro/windows-terminals)

`windows-host/install.ps1` を Windows 側で実行すると、
`windows-host/.wezterm.lua` と `Microsoft.PowerShell_profile.ps1` が
Windows のプロファイル配置先へコピーされる(参考実装。Windows実機での動作
検証は未実施)。

## フォント(Desktop profile)

`./setup.sh --profile desktop` を実行すると、以下の Nerd Fonts が
`~/.local/share/fonts` に自動導入される(`profiles/desktop.sh`)。

- [GoMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Go-Mono.zip)
- [IosevkaTerm Slab Font](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/IosevkaTermSlab.zip)
- [UDEV Gothic](https://github.com/yuru7/udev-gothic/releases/latest)(リリースファイル名がバージョン付きのため自動導入対象外。手動で導入)

Server profile ではフォント導入は行わない(SSH 接続元の端末でレンダリング
されるため不要)。

## WSL2 Config

`profiles/wsl.sh` が以下を自動化する。

- Windows Path の無効化 (`appendWindowsPath=false`)
- `resolv.conf` の自動生成無効化 (`generateResolvConf=false`)
- win32yank による Windows クリップボード連携の配置
