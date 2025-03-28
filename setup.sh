#!/bin/bash
set -eu
printf '\n'

BOLD="$(tput bold 2>/dev/null || printf '')"
GREY="$(tput setaf 0 2>/dev/null || printf '')"
UNDERLINE="$(tput smul 2>/dev/null || printf '')"
RED="$(tput setaf 1 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
BLUE="$(tput setaf 4 2>/dev/null || printf '')"
MAGENTA="$(tput setaf 5 2>/dev/null || printf '')"
NO_COLOR="$(tput sgr0 2>/dev/null || printf '')"

info() {
	printf '%s\n' "${BOLD}${GREY}>${NO_COLOR} $*"
}

warn() {
	printf '%s\n' "${YELLOW}! $*${NO_COLOR}"
}

error() {
	printf '%s\n' "${RED}x $*${NO_COLOR}" >&2
}

completed() {
	printf '%s\n' "${GREEN}✓${NO_COLOR} $*"
}

has() {
	command -v "$1" 1>/dev/null 2>&1
}

is_wsl() {
	uname -r | grep -iq "wsl"
}

essential_commands=(zip unzip curl gzip wget chattr chsh tar sudo)
check_essential_commands() {
	local missing_count=0
	for cmd in "${essential_commands[@]}"; do
		if ! has "${cmd}"; then
			warn "Not found ${cmd} (essential command)"
			missing_count=$((missing_count + 1))
		fi
	done

	if ((missing_count > 0)); then
		error "Missing essential command. Please install them before runnnig script"
		exit 1
	fi
}

configure_wsl() {
	sudo rm -rf /etc/wsl.conf
	echo "[interop]\nappendWindowsPath=false\n[network]\ngenerateResolvConf=false" | sudo tee /etc/wsl.conf >/dev/null 2>&1
	sudo rm -rf /etc/resolv.conf
	echo "nameserver 8.8.8.8\nnameserver8.8.4.4"
	sudo chattr +i /etc/resolv.conf
}

install_pkg() {
	if [[ -f /etc/os-release ]]; then
		. /etc/os-release
		case "$ID" in
		ubuntu | debian)
			apt_install_packages
			;;
		almalinux | rocky | centos | rhel | fedora)
			echo "dnf"
			;;
		opensuse | suse)
			echo "zypper"
			;;
		arch | manjaro)
			echo "pacman"
			;;
		alpine)
			echo "apk"
			;;
		gentoo)
			echo "emerge"
			;;
		void)
			echo "xbps"
			;;
		clear-linux-os)
			echo "swupd"
			;;
		*)
			echo "Unknown package manager for distribution: $ID"
			;;
		esac
	else
		echo "Cannot determine the distribution: /etc/os-release not found"
	fi
}

apt_install_packages() {
	pkgs=(
		"build-essential" "zsh" "fd-find" "ripgrep" "eza"
		"zip" "rar" "jq" "fzf" "gh" "cmake" "mold" "libssl-dev"
		"direnv" "python3-pip" "python3-venv" "wslu" "sqlite3"
	)
	# can use latest version vi-mise use registory
	# fd, jq, fzf, gh, direnv, jq, neovim, mold, mysql, pandoc,
	# pnpm, python, ripgrep, rga, starship, tokei, tmux,
	# zoxide
}

install_third_paty_tools() {
	# zoxide
	curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
	# starship
	curl -sS https://starship.rs/install.sh | sh
	# mise
	curl https://mise.run | sh
	# neovim latest stable package
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
	sudo rm -rf /opt/nvim && sudo tar -C /opt -xzf nvim-linux64.tar.gz && rm -rf ./nvim-linux64.tar.gz
	# pnpm instead of npm
	curl -fsSL https://get.pnpm.io/install.sh | sh -

}

install_dotfiles() {
	mv ./dot_zshrc ~/.zshrc
	mv ./dot_tmux.conf ~/.tmux.conf
	mv -R ./dot_config ~/.config
	mv -R ./dot_cargo ~/.cargo
}

modify_python3_path_in_nvim_option() {
	local python3_path=$(which python3)
	local target_file = "$HOME/.config/nvim/lua/option.lua"
	if [[ ! -f $target_file ]]; then
		error "Not Installed dotfiles"
		exit 1
	fi

	sed -i -E "s|(vim\.g\.python3_host_prog = \").*\"|\1${python3_path}\"|" "$target_file"
	info "Modified python3 path in nvim option.lua"
}

main() {
	check_essential_commands
	if is_wsl; then
		configure_wsl
		info "modify /etc/wsl.conf and modify and /etc/resolv.conf"
	fi

	install_pkg
	install_third_paty_tools
	install_dotfiles

	modify_python3_path_in_nvim_option

	completed "Completed install dev tools and dotfiles"
}
