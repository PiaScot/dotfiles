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
z4h install ohmyzsh/ohmyzsh || return

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return


# Export environment variables.
export GPG_TTY=$TTY
export XDG_CONFIG_HOME="$HOME/.config"
export HISTFILE="$HOME/.zhistory"
export HISTSIZE=10000
export LESS='-g -i -M -R -S -w -X -z-4 -j5'
export VISUAL='nvim'
export EDITOR='nvim'
export NVIM_HOME='/opt/nvim-linux-x86_64'
export PNPM_HOME="/home/plum/.local/share/pnpm"
export ANDROID_HOME=$HOME/Android/SDK
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
# Source additional local files if they exist.
z4h source ~/.env.zsh

path=(
  "$JAVA_HOME/bin"
  "$NVIM_HOME/bin"
  "$HOME/flutter/bin"
  "$HOME/.local/bin"
  "$PNPM_HOME"
  "/usr/local/go/bin"
  $path
  "$ANDROID_HOME/cmdline-tools/latest/bin"
  "$ANDROID_HOME/platform-tools"
  "$$HOME/.cargo/bin"
)
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
alias toml='cd ~/.config/nvim/lua/ && nvim ~/.config/nvim/lua/lazy_nvim.lua'
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

autoload -Uz zmv
# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu

open() { /mnt/c/Windows/system32/cmd.exe /c start $(wslpath -w $1) 2> /dev/null }
md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

bindkey -s '^f' 'zi\n'

pypro() {
    if [[ $# -ne 1 ]]; then
        echo "Specify name you wanna make go project"
        return 1
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
eval "$(zoxide init zsh)"
eval "$(~/.local/bin/mise activate zsh)"
eval "$(gh completion -s zsh)"
