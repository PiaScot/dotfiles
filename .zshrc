# Add deno completions to search path
if [[ ":$FPATH:" != *":/home/plum/.zsh/completions:"* ]]; then export FPATH="/home/plum/.zsh/completions:$FPATH"; fi
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
zstyle ':z4h:fzf-complete' recurse-dirs 'yes'

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
z4h install ohmyzsh/ohmyzsh || return

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

# Extend PATH.
path=(~/bin $path)

# Export environment variables.
export GPG_TTY=$TTY

# Source additional local files if they exist.
z4h source ~/.env.zsh

# Use additional Git repositories pulled in with `z4h install`.
#
# This is just an example that you should delete. It does nothing useful.
z4h source ohmyzsh/ohmyzsh/lib/diagnostics.zsh  # source an individual file
z4h load   ohmyzsh/ohmyzsh/plugins/emoji-clock  # load a plugin

# Define key bindings.
z4h bindkey z4h-backward-kill-word  Ctrl+Backspace     Ctrl+H
z4h bindkey z4h-backward-kill-zword Ctrl+Alt+Backspace

z4h bindkey undo Ctrl+/ Shift+Tab  # undo the last command line change
z4h bindkey redo Alt+/             # redo the last undone command line change

z4h bindkey z4h-cd-back    Alt+Left   # cd into the previous directory
z4h bindkey z4h-cd-forward Alt+Right  # cd into the next directory
z4h bindkey z4h-cd-up      Alt+Up     # cd into the parent directory
z4h bindkey z4h-cd-down    Alt+Down   # cd into a child directory

# Autoload functions.

autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home


# installed by manually to be move from open-src
if [[ ! "$PATH" == *$HOME/.local/bin* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/.local/bin"
fi

# use neovim with
if [[ ! "$PATH" == *\/opt/nvim-linux-x86_64/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/nvim-linux-x86_64/bin"
fi

# for mise
if [[ ! "$PATH" == *$HOME/.local/share/mise/shims* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/.local/share/mise/shims:$PATH"
fi

export XDG_CONFIG_HOME="$HOME/.config"
export HISTFILE=${HOME}/.zhistory
export HISTSIZE=10000
export LESS='-g -i -M -R -S -w -X -z-4 -j5'
export VISUAL='vi'
export EDITOR='nvim'

# Define aliases.
alias tree='tree -a -I .git'

# Add flags to existing aliases.
alias ls="${aliases[ls]:-ls} -A"

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu
setopt list_beep

alias tree='tree -a -I .git'
alias sor='exec zsh'
alias zshrc='nvim ~/.zshrc'
alias ea='eza -la'
alias el='eza -l'
alias tk='exit'
# alias tk='zellij k -y'
alias tconf='nvim ~/.tmux.conf'
alias zconf='nvim ~/.config/zellij/config.kdl'
alias nvimrc='nvim ~/.config/nvim/init.lua'
alias nvcacl='rm -rf ~/.local/share/nvim && rm -rf ~/.local/state/nvim && rm -rf ~/.cache/nvim'
alias toml='cd ~/.config/nvim/lua/ && nvim ~/.config/nvim/lua/lazy_nvim.lua'
alias pvenv='python3 -m venv'
alias pdb='python3 -m pdb'
alias pypro='init_python_project'
alias cr='cargo run'
alias cb='cargo build'
alias ct='cargo test'
alias ctp='cargo test -- --nocapture'
alias gmd='go mod tidy'
alias gopro='init_go_project'
alias v='nvim'
alias mr='make run'

eval "$(zoxide init zsh)"
eval "$(gh completion -s zsh)"
eval "$(direnv hook zsh)"

change_history_directory() {
  __zoxide_zi
  zle reset-prompt
}

zle -N change_history_directory
bindkey '^f' change_history_directory

init_python_project() {
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

init_go_project() {
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

open() {
    /mnt/c/Windows/system32/cmd.exe /c start $(wslpath -w $1) 2> /dev/null
}

typeset -gU PATH

# pnpm
export PNPM_HOME="/home/plum/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
. "/home/plum/.deno/env"
# Initialize zsh completions (added by deno install script)
if [ -d "/home/linuxbrew/.linuxbrew/share/zsh/site-functions" ]; then
  fpath=(/home/linuxbrew/.linuxbrew/share/zsh/site-functions $fpath)
fi
autoload -Uz compinit
compinit

# bun completions
[ -s "/home/plum/.bun/_bun" ] && source "/home/plum/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ------------- Android flutter ----------------------
export ANDROID_HOME=$HOME/Android/SDK
if [[ ! "$PATH" == *$ANDROID_HOME/cmdline-tools/latest/bin* ]]; then
  PATH="${PATH:+${PATH}:}$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
fi

if [[ ! "$PATH" == *$ANDROID_HOME/build-tools/35.0.0/* ]]; then
  PATH="${PATH:+${PATH}:}$ANDROID_HOME/build-tools/35.0.0:$PATH"
fi

if [[ ! "$PATH" == *$ANDROID_HOME/platform-tools* ]]; then
  PATH="${PATH:+${PATH}:}$ANDROID_HOME/platform-tools:$PATH"
fi

export FLUTTER_ROOT=$HOME/flutter
if [[ ! "$PATH" == *$FLUTTER_ROOT/bin* ]]; then
  PATH="${PATH:+${PATH}:}$FLUTTER_ROOT/bin:$PATH"
fi

export ANDROID_AVD_HOME="$HOME/.config/.android/avd"

# for java 21
export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"

# -------------------------------------------------------

# for homebrew settings
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
. "$HOME/.turso/env"
