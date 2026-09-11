# symlink運用ガイド

`scripts/restore.sh` は `home/` 以下の内容を `$HOME` へ **symlink** で配置する
(コピーではない)。つまり `~/.zshrc` を編集する = このリポジトリの
`home/.zshrc` を直接編集するのと同じことになる。このドキュメントは、
以前「dotfiles projectと現行のものを対比して、破壊的変更をlocalで試す」と
いう運用をしていた人向けに、symlink構成でも同じ安全性を git の機能で再現す
る方法をまとめる。nvim に限らず `home/` 以下のすべての設定(zsh, tmux,
fish, htop, zellij, cargo)に同じ考え方が使える。

## なぜ symlink なのか

- `~/.zshrc` を編集 → その場で `git diff` が「今の変更点」になる。
  コピー運用のように「repoへ反映し忘れる」ドリフトが起きない。
- `git checkout <branch>` するだけで `$HOME` の中身が即座に切り替わる。
- 過去バージョンとの比較は `diff` で2ファイルを見比べるのではなく、
  `git log` / `git diff` / `git blame` という正規の手段で行える。

トレードオフとして、live編集がそのままrepoの変更になるため、
「壊れるかもしれない変更を気軽に試す」には一手間必要になる。それを以下の
方法で解決する。

## 日常の小さな変更

そのまま編集してよい。気に入らなければ即座に戻せる。

```sh
cd ~/project/dotfiles
git diff                      # 今の変更点を確認(symlink経由でliveの変更がそのまま見える)
git checkout -- home/.zshrc   # 気に入らなければ即ロールバック(liveの~/.zshrcも同時に元に戻る)
git add -A && git commit      # 気に入ったら確定
```

## 「試してから決めたい」変更(stashで一時退避)

編集を始める前に一度 stash しておくと、いつでも編集前の状態に戻せる。

```sh
cd ~/project/dotfiles
git stash push -m "before trying new tmux binding"
# ここで ~/.tmux.conf (symlink先) を自由に編集して試す
tmux source-file ~/.tmux.conf

# 気に入った場合: そのままcommit
git add -A && git commit -m "tmux: new prefix binding"

# 気に入らなかった場合: 編集を破棄してstashを戻す
git checkout -- home/.tmux.conf
git stash pop
```

## 大きめ・破壊的な変更(nvim設定の全面変更など)を「普段使いを壊さずに」試す

`git worktree` を使うと、**普段使いのsymlink先(masterブランチ)を一切変えず
に**、別ブランチの内容を別ディレクトリに展開して試せる。nvimなら
`NVIM_APPNAME` 環境変数で完全に別インスタンスとして起動できるので、
既存のnvimと実験用nvimを同時に併存させられる。

```sh
cd ~/project/dotfiles

# 実験用ブランチを別ディレクトリに展開(masterのworktree/symlinkには影響しない)
git worktree add ../dotfiles-nvim-experiment -b nvim-experiment

# 実験用のnvim設定ディレクトリだけを指すよう、別appnameで起動
# (普段使いの ~/.config/nvim = home/.config/nvim(master)にはノータッチ)
mkdir -p ~/.config/nvim-experiment
ln -sfn ~/project/dotfiles-nvim-experiment/home/.config/nvim ~/.config/nvim-experiment
NVIM_APPNAME=nvim-experiment nvim

# 気に入ったら実験用worktree内でcommitし、masterへマージ
cd ~/project/dotfiles-nvim-experiment
git add -A && git commit -m "nvim: try new plugin manager config"
cd ~/project/dotfiles
git merge nvim-experiment

# 不要になったworktreeの後片付け
git worktree remove ../dotfiles-nvim-experiment
rm -rf ~/.config/nvim-experiment
```

同じ手順は zsh(`ZDOTDIR`を実験用ディレクトリに向ける)や fish
(`XDG_CONFIG_HOME`を切り替える)など、環境変数でconfig探索先を差し替えられ
るツールであれば同様に使える。

## 初回導入時のバックアップからの復元

`scripts/restore.sh` は symlink 化する直前に、既存の実体
(symlinkでないファイル/ディレクトリ)を `scripts/backup.sh` 経由で
`backups/<timestamp>/` に退避する。導入直後に「前の設定に戻したい」場合は
該当ファイルを `backups/<timestamp>/` からコピーし戻せばよい。

## 事故に関する注意

symlinkになった `~/.config/nvim` などに対して、末尾スラッシュ付きで
`rm -rf ~/.config/nvim/` を実行すると、symlink自体ではなく**リンク先(=
このリポジトリの中身)が削除される**。ディレクトリを丸ごと消したいときは、
まず `readlink -f ~/.config/nvim` で実体を確認する習慣をつけること。
