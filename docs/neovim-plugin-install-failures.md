# nvim初回起動時のプラグイン導入失敗(hop.nvim / mason.nvim)への対処

Ubuntu 26.04 (WSL) での実機テストで、初回 `nvim` 起動時に2種類の失敗が発生
した。原因を実機で特定した上で、**nvim configを一切いじらない対処法**と
**nvim configを変更する対処法**の両方をまとめる。

## 1. `hop.nvim` の clone 失敗

```
Failed (1)
  ○ hop.nvim
    Cloning into '/home/plum/.local/share/nvim/lazy/hop.nvim'...
    fatal: could not read Username for 'https://github.com': terminal prompts disabled
```

### 原因

lazy.nvim は43個のプラグインをほぼ同時並行で `git clone`(HTTPS)する。
`hop.nvim` は完全に公開リポジトリなので本来認証は不要だが、**同一IPから
の大量の匿名HTTPS clone がGitHub側で瞬間的にレート制限/認証要求扱いにな
ることがある**。43個中1個だけが失敗しているパターンは、この種の一過性の
事象に典型的。

### 対処法A: nvim configをいじらない

単純に**再試行すれば直ることが多い**。

```
:Lazy sync
```

または `nvim` を再起動するだけでも lazy.nvim が失敗分を再試行する。恒常的
に頻発する場合は、システム側のgit設定で全面的にSSH経由に切り替える方法も
ある(nvim configには一切触れない):

```sh
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

これで `https://github.com/...` へのアクセスが自動的に `git@github.com:...`
(SSH)に書き換わり、lazy.nvimの内部URLも含め全てのgit操作がSSH経由にな
る。ただし事前にGitHub側にSSH公開鍵を登録しておく必要がある(`gh` は既に
SSH認証で設定済みなので `ssh -T git@github.com` で確認可能)。

### 対処法B: nvim configを変更する

lazy.nvim の `setup()` オプションで直接SSH化・同時実行数を絞ることもでき
る(`home/.config/nvim/lua/plugins/init.lua` などlazy.setupを呼んでいる箇
所に追加):

```lua
require("lazy").setup(plugins, {
  git = {
    url_format = "git@github.com:%s.git", -- HTTPSではなくSSHでclone
  },
  concurrency = 8, -- デフォルトのCPU数より下げてGitHub側のレート制限を回避
})
```

どちらも一長一短(configをいじる方はSSH鍵前提になる/リポジトリ全体の挙動
が変わる)なので、**まずは対処法Aの再試行で様子を見るのを推奨**する。

## 2. mason.nvim: `pyright` (EPERM) / `eslint_d` (rmrf失敗)

```
✗ pyright
    EPERM: operation not permitted: .../mason/staging/pyright/node_modules/.bin/pyright-langserver
✗ eslint_d
    rmrf: Could not remove directory ".../mason/staging/eslint_d"
```

### 原因(実機で特定済み)

2つの問題が重なっている。

1. **`/etc/wsl.conf` の `appendWindowsPath=false` はWSLの再起動
   (`wsl.exe --shutdown`)をしないと反映されない。** そのため、
   `./setup.sh` 実行直後の初回nvim起動時点ではまだWindows側のPATHが混入
   したままだった。
2. **Ubuntu 26.04 の `nodejs` apt パッケージは `npm` を同梱していない**
   (`node-corepack` はあるが `corepack enable` されるまで `npm` コマンド
   自体が存在しない)。

この2つが重なった結果、mason.nvim が呼び出した `npm` は実際には
**Windowsの scoop でインストールされた `npm.exe`(interop経由)** だった。
Windows側のnpmがLinux(ext4)側のパスに対してPOSIXシンボリックリンクや実
行権限を操作しようとして `EPERM`/`rmrf失敗` になっていた。

実機で確認したコマンドと結果:
```
$ which -a npm
/mnt/c/Users/CrCru/scoop/apps/nodejs-lts/current/npm   # ← Windows側のnpm
$ dpkg -l | grep npm
ii  node-corepack   0.24.0-5build1   ...
                                     # ← npm自体は入っていない
```

### 対処法A: nvim configをいじらない(採用・実装済み)

根本原因はどちらも環境側の問題であり、nvim configには一切関係ない。

1. **WSLを再起動する**(Windows側で): `wsl.exe --shutdown` してから
   Ubuntu-26.04を開き直す。これで `appendWindowsPath=false` が反映され、
   Windows側のnpm/node/git等がPATHから消える。
2. **`scripts/toolchains.sh` に `check_npm` を追加した**(このコミットで
   対応済み)。`npm` が `/mnt/` 配下(Windows側)を指している、または存在
   しない場合、`sudo corepack enable` でネイティブな `npm`/`pnpm`/`yarn`
   を提供する。`./setup.sh` を再実行すれば自動的に直る。
3. 上記の後、nvimを再起動して `:Lazy sync` → mason側は自動的に
   `pyright`/`eslint_d` の再インストールを試みる(またはnvim内で
   `:MasonInstall pyright eslint_d`)。

### 対処法B: nvim configを変更する

環境側を直さずに、Neovim内部だけで確実に正しい`npm`/`node`を使わせる方法
もある。**この方法は今回は採用していないが、参考として記載する。**

`init.lua` の先頭付近で `vim.env.PATH` を明示的に組み立て直し、Windows側
のパスを除外してから通常のPATHを前置する:

```lua
-- WSL環境でWindows側のパスがLinuxツールより優先されるのを防ぐ
if vim.fn.has("wsl") == 1 then
  local paths = vim.split(vim.env.PATH, ":")
  local filtered = vim.tbl_filter(function(p)
    return not p:match("^/mnt/[a-z]/")
  end, paths)
  vim.env.PATH = table.concat(filtered, ":")
end
```

これにより、`appendWindowsPath` の反映待ちやWSL再起動を待たずに、Neovim
から起動される全てのサブプロセス(mason.nvim含む)がWindows側のバイナリ
を拾わなくなる。ただし「本来のPATH設定の問題」を隠すだけで、シェル上で
直接 `npm` を打った場合の問題は解決しない点に注意。恒久的には対処法Aの
方が筋が良い。

## まとめ

| 問題 | 採用した対処 | 変更箇所 |
|---|---|---|
| hop.nvim clone失敗 | 再試行(`:Lazy sync`) | 変更不要 |
| mason EPERM/rmrf | WSL再起動 + `corepack enable`自動化 | `scripts/toolchains.sh` (nvim configは無変更) |
