#!/usr/bin/env bash

get_host_os() {
	if [[ -f /etc/os-release ]]; then
		echo "Not exist os-release file"
		exit 1
	fi
	os=$(grep -E "^ID=" /etc/os-release | cut -d= -f2)
	if [[ $(uname --kernel-release) = *WSL* ]]; then
		echo "WSL"
	else
		echo "${os}"
	fi
}

place_dotfiles() {
	repo_url="https://github.com/PiaScot/dotfiles"
	git clone $repo_url "$HOME"
	cp -f "$HOME/dotfiles/dot_zsh" "$HOME/.zshrc"

	test -d "$HOME/config" || mkdir -p "$HOME/config"
	cp -fR "$HOME/dotfiles/dot_config/nvim" "$HOME/.config"
}

install_need_bin() {
	host=$(get_host_os)
	case "$host" in
	"WSL" | "ubuntu")
		init
		;;
	*)
		echo "Not supported your host: $host" && exit 1
		;;
	esac
}

init_build_essential_on_ubuntu() {
	sudo apt update && sudo upgrade && sudo apt-get install build-essential procps curl file git
}

install_misc_bin() {
	brew install go gh neovim unzip tldr zoxide gd go fzf ripgrep zellij npm direnv mold
}

install_linuxbrew_and_change_zsh() {
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	test -d ~/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
	test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

	brew install zsh

	if [ -f /etc/shells ]; then
		echo 'Not found /etc/shells.'
		echo 'Can not add homebrew zsh to /etc/shells.'
		exit 1
	fi

	echo "/home/linuxbrew/.linuxbrew/bin/zsh" | sudo tee -a /etc/shells
	echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >>~/.bashrc
	chsh -s "/home/linuxbrew/.linuxbrew/bin/zsh"
}

init() {
	init_build_essential_on_ubuntu
	install_linuxbrew_and_change_zsh
	install_prezto
	install_misc_bin
	place_dotfiles
	zsh -c 'nvim'
}

main() {
	init
}

main
