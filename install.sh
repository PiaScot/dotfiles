#!/bin/env bash

set -eu

# check installed xxx command
check_install_command() {
	local cmd="$1"
	if ! command -v "$cmd" >/dev/null 2>&1; then
		echo "$cmd not found. Install $cmd with your OS package installer"
		exit 1
	fi
}

install_essential_command() {
	sudo apt update
	sudo apt upgrade
	sudo apt-get install -y zsh build-essential procps curl file jq python3-venv pkg-config libssl-dev gh fd-find ripgrep golang
}

settings_wsl_conf() {
	sudo sh -c "echo '\n[interop]\nappendWindowsPath=false\n\n[network]\ngenerateResolvConf=false' >> /etc/wsl.conf"
	sudo rm -rf "/etc/resolv.conf" && sudo sh -c "echo nameserver 8.8.8.8 > /etc/resolv.conf"
}

settings_dot_config() {
	local cwd=$(pwd)
	cp "$cwd/dot_zshrc" "$HOME/.zshrc" && cp "$cwd/dot_tmux.conf" "$HOME/.tmux.conf"
	cp -R "$cwd/dot_config" "$HOME/.config"
}

check_last_command() {
	local status="$1"
	local msg="$2"

	if ! [ "$status" -eq 0 ]; then
		echo "Failed to '$msg'"
		echo "Finished this progam"
		exit 1
	fi
}

# download command and move to $HOME/.local/bin/
# ARG1 -> https://OWENER/REPO format
# ARG2 -> query string to filter latest assets name
install_cmd_from_github() {
	get_latest_github() {
		check_install_command jq

		local url="${1/github.com/api.github.com\/repos}/releases/latest"
		local query="$2"
		local has_tar=$(curl -s "$url" | jq -r ".assets[] | select(.name | test(\"$query\")) | .browser_download_url")

		if [ -z "$has_tar" ]; then
			echo "Not found tarball $url"
			exit 1
		fi

		echo "$has_tar" | awk 'length($0) < prev_length || NR == 1 { shortest=$0; prev_length=length($0) } END { print shortest }'

	}

	local cmd_url=$(get_latest_github "$1" "$2")
	local fname=$(basename "$cmd_url")
	local dirname=$(echo "$fname" | sed 's/\.tar\.gz$//')
	local cmd_name=$(echo "$fname" | sed 's/-.*//')

	wget "$cmd_url" -P "$HOME/tmp" && tar -xf "$HOME/tmp/$fname" --directory="$HOME/tmp"

	# directory pattern
	if [ -f "$HOME/tmp/$dirname/$cmd_name" ]; then
		mkdir -p "$HOME/.local/bin" && mv "$HOME/tmp/$dirname/$cmd_name" "$HOME/.local/bin"
	fi

	if [ -f "$HOME/tmp/$dirname/bin/$cmd_name" ]; then
		mkdir -p "$HOME/.local/bin" && mv "$HOME/tmp/$dirname/bin/$cmd_name" "$HOME/.local/bin"
	fi

	# file pattern
	if [ -f "$HOME/tmp/$cmd_name" ]; then
		mkdir -p "$HOME/.local/bin/" && mv "$HOME/tmp/$cmd_name" "$HOME/.local/bin"
	fi

}

# want string ex. https://go.dev/dl/go1.22.2.linux-amd64.tar.gz
# so want to check latest version
install_golang() {
	latest_version=$(curl -sL https://godoc.org/golang.org/dl | grep -oP "go\d+\.\d+(\.\d+)?\s" | awk '{$1=$1};1' | sort -V | uniq | tail -n 1)
	wget "https://go.dev/dl/${latest_version}.linux-amd64.tar.gz" -P "$HOME/tmp" && rm -rf /usr/local/go && tar -C /usr/local -xzf "$HOME/tmp/${latest_version}.linux-amd64.tar.gz"
}

install_zoxide() {
	curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
}

install_fzf() {
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
}

install_direnv() {
	curl -sfL https://direnv.net/install.sh | bash
}

install_cmd() {
	install_essential_command
	install_cmd_from_github "https://github.com/eza-community/eza" "x86_64.*?-linux-gnu.tar.gz$"
	install_cmd_from_github "https://github.com/rui314/mold" "x86_64-linux.tar.gz$"
	install_cmd_from_github "https://github.com/mozilla/sccache" "x86_64-unknown-linux-musl.tar.gz$"
	install_golang
	install_zoxide
	install_fzf
	install_direnv
}

conf_setting() {
	settings_wsl_conf
	settings_dot_config
}

main() {
	install_essential_command
	conf_setting
}

clean_tmp() {
	rm -rf "$HOME/tmp" && mkdir "$HOME/tmp"
}

main
