#!/bin/bash
# Verifies (and installs if missing) the language toolchains that
# home/.zshrc's `path=(...)` and exported *_HOME variables assume are
# already present: JAVA_HOME, /usr/local/go, ~/.cargo (rustup),
# $HOME/flutter, and Node.js (via pnpm). Symlinking home/.zshrc alone
# never installs any of these, so this script closes that gap.
#
# $ANDROID_HOME is intentionally NOT installed here (large, complex,
# slow) -- only reported as present/missing.
#
# Common to both --profile desktop and --profile server: every one of
# these is referenced directly in the shared home/.zshrc, not gated by
# profile.
#
# Usage: scripts/toolchains.sh [--dry-run]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source-path=SCRIPTDIR source=./lib.sh
source "$SCRIPT_DIR/lib.sh"

DRY_RUN=0
for arg in "$@"; do
	case "$arg" in
	--dry-run) DRY_RUN=1 ;;
	*)
		error "Unknown argument: $arg"
		exit 1
		;;
	esac
done

# Matches home/.zshrc's `export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64`,
# which is exactly where Ubuntu/Debian's openjdk-17-jdk package puts it.
check_jdk() {
	local java_home="/usr/lib/jvm/java-17-openjdk-amd64"

	if [[ -x "$java_home/bin/java" ]]; then
		info "JDK 17 already installed at $java_home"
		return 0
	fi

	if ((DRY_RUN)); then
		info "[dry-run] would run: sudo apt-get install -y openjdk-17-jdk"
		return 0
	fi

	info "Installing openjdk-17-jdk"
	sudo apt-get update
	sudo apt-get install -y openjdk-17-jdk
}

# Matches home/.zshrc's "/usr/local/go/bin" path entry.
check_go() {
	local go_root="/usr/local/go"

	if [[ -x "$go_root/bin/go" ]]; then
		info "Go already installed at $go_root ($("$go_root/bin/go" version))"
		return 0
	fi

	if ((DRY_RUN)); then
		info "[dry-run] would download the latest Go release and extract it to $go_root"
		return 0
	fi

	local version tarball tmp_dir
	version="$(curl -sSfL "https://go.dev/VERSION?m=text" | head -n1)"
	if [[ -z "$version" ]]; then
		warn "Could not determine the latest Go version; skipping Go install"
		return 0
	fi
	tarball="${version}.linux-amd64.tar.gz"
	tmp_dir="$(mktemp -d)"

	if ! curl -sSfL -o "$tmp_dir/$tarball" "https://go.dev/dl/$tarball"; then
		warn "Failed to download $tarball; skipping Go install"
		rm -rf "$tmp_dir"
		return 0
	fi

	sudo rm -rf "$go_root"
	sudo tar -C /usr/local -xzf "$tmp_dir/$tarball"
	rm -rf "$tmp_dir"
	info "Installed Go ($version) to $go_root"
}

# Matches home/.zshrc's "$HOME/.cargo/bin" path entry.
check_rust() {
	if has cargo || [[ -x "$HOME/.cargo/bin/cargo" ]]; then
		info "Rust/cargo already installed"
		return 0
	fi

	if ((DRY_RUN)); then
		info "[dry-run] would run the official rustup installer (non-interactive)"
		return 0
	fi

	info "Installing Rust via rustup"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}

# Matches home/.zshrc's "$HOME/flutter/bin" path entry. mise's flutter
# plugin is archived/unmaintained, so this uses Flutter's own documented
# install method instead of a version manager.
check_flutter() {
	local flutter_home="$HOME/flutter"

	if [[ -x "$flutter_home/bin/flutter" ]]; then
		info "Flutter already installed at $flutter_home"
		return 0
	fi

	if ((DRY_RUN)); then
		info "[dry-run] would run: git clone -b stable --depth 1 https://github.com/flutter/flutter.git $flutter_home"
		return 0
	fi

	info "Cloning Flutter (stable channel) to $flutter_home"
	git clone -b stable --depth 1 https://github.com/flutter/flutter.git "$flutter_home"
}

# Matches home/.zshrc's "$PNPM_HOME" path entry. pnpm's own `env`
# subcommand manages a Node.js install, so no separate node/nvm/mise
# step is needed once pnpm itself is present.
check_node() {
	if has node; then
		info "Node.js already installed ($(node --version))"
		return 0
	fi

	if ! has pnpm; then
		warn "pnpm not found; run scripts/install.sh (installs pnpm) before this step installs Node.js"
		return 0
	fi

	if ((DRY_RUN)); then
		info "[dry-run] would run: pnpm env use --global lts"
		return 0
	fi

	info "Installing Node.js (LTS) via pnpm"
	pnpm env use --global lts
}

# Ubuntu's `nodejs` apt package does not bundle `npm` (26.04 ships it
# split out into its own `npm` apt package), and on WSL2 a `npm` found
# on PATH can actually be the *Windows* npm leaking in via interop
# before a `wsl.exe --shutdown` picks up profiles/wsl.sh's
# appendWindowsPath=false. A Windows npm.exe operating on a Linux path
# fails in confusing ways (EPERM creating .bin symlinks, "Could not
# remove directory") -- exactly what mason.nvim hits installing LSP
# servers.
#
# NOTE: this used to run `sudo corepack enable` instead of the apt
# install below. That was wrong: corepack does not shim `npm` by
# default (only pnpm/yarn), so it never actually fixed the missing
# npm -- and its pnpm shim ends up earlier on $PATH than the real
# standalone pnpm installed by install_third_party_tools, shadowing
# it with a broken shim (its cached module is never fetched), which
# is exactly the "Cannot find module .../corepack/pnpm/.../pnpm.cjs"
# failure hit live on god77. Confirmed Ubuntu 26.04 has a plain `npm`
# apt package (command-not-found even suggests it), so just install
# that directly instead.
check_npm() {
	local npm_path
	npm_path="$(command -v npm 2>/dev/null || true)"

	if [[ -n "$npm_path" && "$npm_path" != /mnt/* ]]; then
		info "npm already installed ($npm_path, $(npm --version 2>/dev/null))"
		return 0
	fi

	if [[ -n "$npm_path" ]]; then
		warn "npm resolves to '$npm_path' -- that's Windows' npm leaking in via WSL interop (appendWindowsPath=false won't take effect until the WSL instance is restarted: run 'wsl.exe --shutdown' from Windows, then reopen). Installing a native npm via apt in the meantime."
	else
		info "npm not found (this Ubuntu release's nodejs package doesn't bundle it); installing the npm apt package"
	fi

	if ((DRY_RUN)); then
		info "[dry-run] would run: sudo apt-get install -y npm"
		return 0
	fi

	sudo apt-get install -y npm
	info "Installed npm via apt"
}

# Intentionally not installed: large, slow, and requires interactive
# license acceptance. Just reports whether it's already there.
check_android_sdk() {
	local android_home="${ANDROID_HOME:-$HOME/Android/SDK}"

	if [[ -x "$android_home/platform-tools/adb" ]]; then
		info "Android SDK detected at $android_home"
	else
		warn "Android SDK not found at $android_home (not installed automatically -- set it up manually if needed)"
	fi
}

check_jdk
check_go
check_rust
check_flutter
check_node
check_npm
check_android_sdk

((DRY_RUN)) || completed "Toolchain check complete"
