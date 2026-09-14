# ==============================================================================
# 1. zsh4humans Global Settings (Pre-Init)
# ==============================================================================
typeset -U path PATH fpath FPATH

# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environment
# variables such as PATH) in this file or in files sourced from it.
#
# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update      'no'
# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:' auto-update-days '28'
# Keyboard type: 'mac' or 'pc'.
zstyle ':z4h:bindkey' keyboard  'pc'
# Don't start tmux.
zstyle ':z4h:' start-tmux       no
# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'
# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char 'accept'
# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs 'no'
# Enable direnv to automatically source .envrc files.
zstyle ':z4h:direnv'         enable 'yes'
# Show "loading" and "unloading" notifications from direnv.
zstyle ':z4h:direnv:success' notify 'yes'
# Enable ('yes') or disable ('no') automatic teleportation of z4h over
# SSH when connecting to these hosts.
zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
# The default value if none of the overrides above match the hostname.
zstyle ':z4h:ssh:*'                   enable 'no'
# Send these files over to the remote host when connecting over SSH to the
# enabled hosts.
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'
# Start ssh-agent if it's not running yet.
zstyle ':z4h:ssh-agent:' start yes

# Clone additional Git repositories from GitHub.
#
# This doesn't do anything apart from cloning the repository and keeping it
# up-to-date. Cloned files can be used after `z4h init`. This is just an
# example. If you don't plan to use Oh My Zsh, delete this line.
# z4h install ohmyzsh/ohmyzsh || return

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

# ==============================================================================
# 2. User-Settings
# ==============================================================================

# Source additional local files if they exist.
z4h source ~/.zshrc.local
# Use additional Git repositories pulled in with `z4h install`.
#
# This is just an example that you should delete. It does nothing useful.
# z4h source ohmyzsh/ohmyzsh/lib/diagnostics.zsh  # source an individual file
# z4h load   ohmyzsh/ohmyzsh/plugins/emoji-clock  # load a plugin

export GPG_TTY=$TTY
export XDG_CONFIG_HOME="$HOME/.config"
export HISTFILE="$HOME/.zhistory"
export PNPM_HOME="$HOME/.local/share/pnpm"
export HISTSIZE=10000
export LESS='-g -i -M -R -S -w -X -z-4 -j5'
export VISUAL='nvim'
export EDITOR='nvim'
export ANDROID_HOME=/opt/android-sdk
export JAVA_HOME=/usr/lib/jvm/default
export FLUTTER_JAVA_HOME=/usr/lib/jvm/java-17-openjdk

path=(
  "$HOME/.local/share/pnpm/bin"
  "$ANDROID_HOME/cmdline-tools/latest/bin"
  "$ANDROID_HOME/build-tools/36.1.0"
  "$ANDROID_HOME/platform-tools"
  $path
)

# Define key bindings.
z4h bindkey z4h-backward-kill-word  Ctrl+Backspace     Ctrl+H
z4h bindkey z4h-backward-kill-zword Ctrl+Alt+Backspace
z4h bindkey undo Ctrl+/ Shift+Tab  # undo the last command line change
z4h bindkey redo Alt+/             # redo the last undone command line change
z4h bindkey z4h-cd-back    Alt+Left   # cd into the previous directory
z4h bindkey z4h-cd-forward Alt+Right  # cd into the next directory
z4h bindkey z4h-cd-up      Alt+Up     # cd into the parent directory
z4h bindkey z4h-cd-down    Alt+Down   # cd into a child directory

bindkey -s '^f' 'zi\n'

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt auto_cd
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu

# Add flags to existing aliases.
alias ls="${aliases[ls]:-ls} -A"
alias sor='exec zsh'
alias zshrc='nvim ~/.zshrc'
alias ea='eza -la --icons=auto'
alias el='eza -l'
alias tk='exit'
alias tconf='nvim ~/.tmux.conf'
alias zconf='nvim ~/.config/zellij/config.kdl'
alias nvimrc='nvim ~/.config/nvim/init.lua'
alias nvcacl='rm -rf ~/.local/share/nvim && rm -rf ~/.local/state/nvim && rm -rf ~/.cache/nvim'
alias toml='cd "$HOME/.config/nvim" && nvim init.lua'
alias pvenv='python3 -m venv'
alias pdb='python3 -m pdb'
# alias pypro='init_python_project'
alias cr='cargo run'
alias cb='cargo build'
alias ct='cargo test'
alias ctp='cargo test -- --nocapture'
alias gmd='go mod tidy'
# alias gopro='init_go_project'
alias v='nvim'
alias mr='make run'
alias icp='/mnt/c/Tools/win32yank.exe -i'

# Autoload functions.
autoload -Uz zmv
# autoload -Uz compinit
# compinit

# Define functions and completions.
open() {
    /mnt/c/Windows/system32/cmd.exe /c start "" "$(wslpath -w "$1")" 2> /dev/null
}
md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

pypro() {
    if [[ $# -ne 1 ]]; then
        echo "Specify name you wanna make go project"
        return i
    fi

    local name=$1
    uv init $name
    cd $name
    uv venv
    echo "source .venv/bin/activate\nunset PS1" > .envrc
    direnv allow .
}

gopro() {
    if [[ $# -ne 1 ]]; then
        echo "Specify name you wanna make go project"
        return i
    fi

    local name=$1
    mkdir $name
    cd $name
    go mod init $name
    cat <<'EOF' > Makefile
GOFILES=$(shell find ./src -name '*.go')

.PHONY: build run debug test

build:
	go build -o main $(GOFILES)

run:
	go build -o main $(GOFILES) && ./main

debug:
	go build -o main -gcflags="-N -l" $(GOFILES)

test:
	go test ./src -v
EOF
  mkdir src
}

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

#!/usr/bin/env zsh
# ============================================================================
#  project-picker.zsh — 説明文つきプロジェクトピッカー
#
#  使い方:
#    source ~/.config/zsh/project-picker.zsh   # .zshrc に追記
#    Ctrl+F               ピッカーを開く
#    project              同上（関数として直接呼ぶ）
#    project-desc "説明"  カレントディレクトリに説明文を設定
#
#  設計方針:
#    - 説明文はサブプロセスを一切起動せず zsh 組み込みだけで取得する
#      （WSL2 は fork が重いため、14 プロジェクトでも体感差が出る）
#    - 説明文の取得元は優先順位つきのフォールバック方式にして、
#      .project を書かなくても既存ファイルから自動で拾えるようにする
# ============================================================================

# ---- 設定 ------------------------------------------------------------------
# 走査対象のルート。複数持ちたい場合は配列にして for を回すよう拡張できる
: ${PROJECT_ROOT:=$HOME/project}
# 手書き説明文のファイル名
: ${PROJECT_DESC_FILE:=.project}

# ---- 説明文の取得 ----------------------------------------------------------
# $1: プロジェクトディレクトリ
# 結果は $REPLY に入る（サブシェルを作らないための zsh 慣習）
__project_describe() {
  emulate -L zsh
  setopt localoptions extendedglob

  local dir=$1 line f
  REPLY=''

  # ① .project ファイルの 1 行目（手書き・最優先）
  if [[ -r $dir/$PROJECT_DESC_FILE ]]; then
    IFS= read -r line < $dir/$PROJECT_DESC_FILE
    line=${line##[[:space:]]#}
    if [[ -n $line ]]; then
      REPLY=$line
      return 0
    fi
  fi

  # ② package.json の "description"
  if [[ -r $dir/package.json ]]; then
    while IFS= read -r line; do
      if [[ $line == *'"description"'*:* ]]; then
        line=${line#*:}                 # : より後ろ
        line=${line##[[:space:]]#}      # 先頭空白を除去
        line=${line%,}                  # 末尾カンマを除去
        line=${${line#\"}%\"}           # 前後のダブルクォートを除去
        if [[ -n $line ]]; then
          REPLY=$line
          return 0
        fi
        break
      fi
    done < $dir/package.json
  fi

  # ③ pyproject.toml の description
  if [[ -r $dir/pyproject.toml ]]; then
    while IFS= read -r line; do
      if [[ $line == description[[:space:]]#=* ]]; then
        line=${line#*=}
        line=${line##[[:space:]]#}
        line=${${line#[\"\']}%[\"\']}
        if [[ -n $line ]]; then
          REPLY=$line
          return 0
        fi
        break
      fi
    done < $dir/pyproject.toml
  fi

  # ④ README の最初の「意味のある行」
  for f in README.md README.markdown README.rst README.txt README; do
    [[ -r $dir/$f ]] || continue
    while IFS= read -r line; do
      line=${line##[[:space:]]#}
      line=${line%%[[:space:]]#}
      [[ -z $line ]]        && continue   # 空行
      [[ $line == '#'* ]]   && continue   # 見出し
      [[ $line == '!['* ]]  && continue   # バッジ画像
      [[ $line == '['* ]]   && continue   # リンク行
      [[ $line == [-=]## ]] && continue   # rst の下線
      [[ $line == '<'* ]]   && continue   # 生 HTML
      REPLY=$line
      return 0
    done < $dir/$f
    break
  done

  return 0
}

# ---- ピッカー本体 ----------------------------------------------------------
project() {
  emulate -L zsh
  setopt localoptions extendedglob null_glob pipe_fail

  if (( ! $+commands[fzf] )); then
    print -u2 "project: fzf が見つかりません"
    return 1
  fi

  local root=${PROJECT_ROOT:A}
  if [[ ! -d $root ]]; then
    print -u2 "project: ディレクトリがありません: $root"
    return 1
  fi

  # 直下のディレクトリのみ。(-/) はディレクトリへのシンボリックリンクも含む
  local -a dirs
  dirs=( $root/*(-/) )
  if (( ! $#dirs )); then
    print -u2 "project: $root 配下にプロジェクトがありません"
    return 1
  fi

  # 名前カラムの幅を揃える
  local -i width=0
  local dir
  for dir in $dirs; do
    (( ${#dir:t} > width )) && width=${#dir:t}
  done

  # 表示行を組み立てる。TAB より後ろは fzf に表示させず、パスの受け渡しに使う
  local -a lines
  local name
  for dir in $dirs; do
    name=${dir:t}
    __project_describe $dir
    lines+=( "${(r:$width:)name}  ${REPLY:-—}"$'\t'"$dir" )
  done

  local selected
  selected=$(
    print -rl -- $lines |
      fzf --delimiter=$'\t' \
          --with-nth=1 \
          --height=70% \
          --reverse \
          --border \
          --prompt='project> ' \
          --header='Enter: cd / Ctrl-C: cancel' \
          --preview='p={2};
                     if [ -r "$p/README.md" ]; then
                       head -n 60 "$p/README.md"
                     else
                       ls -1A "$p" | head -n 60
                     fi' \
          --preview-window='right,55%,border-left'
  )

  # Ctrl-C / ESC で抜けた場合は何もしない
  [[ -n $selected ]] || return 0

  local target=${selected##*$'\t'}
  if [[ ! -d $target ]]; then
    print -u2 "project: 移動先が存在しません: $target"
    return 1
  fi

  cd -- $target
}

# ---- 説明文の設定ヘルパー --------------------------------------------------
# project-desc              現在の説明文を表示
# project-desc "説明文"     現在のディレクトリに設定
# project-desc "説明文" DIR 指定ディレクトリに設定
project-desc() {
  emulate -L zsh
  local text=$1
  local dir=${2:-$PWD}

  if [[ ! -d $dir ]]; then
    print -u2 "project-desc: ディレクトリがありません: $dir"
    return 1
  fi

  if [[ -z $text ]]; then
    if [[ -r $dir/$PROJECT_DESC_FILE ]]; then
      cat -- $dir/$PROJECT_DESC_FILE
    else
      __project_describe $dir
      print -r -- "${REPLY:-(説明なし)}"
    fi
    return 0
  fi

  print -r -- $text > $dir/$PROJECT_DESC_FILE || return 1
  print -r -- "設定しました: $dir/$PROJECT_DESC_FILE"
}

# ---- キーバインド ----------------------------------------------------------
# bindkey -s 方式（キー列の流し込み）はコマンド入力中に文字が混ざるため、
# zle ウィジェットとして登録する
__project_widget() {
  project
  local ret=$?
  zle reset-prompt
  return $ret
}
zle -N __project_widget
bindkey '^T' __project_widget

eval "$(zoxide init zsh)"
eval "$(gh completion -s zsh)"

