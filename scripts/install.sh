#!/bin/bash
# Main entry point. Orchestrates: essential-command check, OS check,
# backup, apt packages, third-party tools, symlink restore, and the
# WSL/desktop/server profile scripts.
#
# Usage: scripts/install.sh --profile <desktop|server> [--dry-run]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source-path=SCRIPTDIR source=./lib.sh
source "$SCRIPT_DIR/lib.sh"

PROFILE=""
DRY_RUN=0

usage() {
	cat <<EOF
Usage: $(basename "$0") --profile <desktop|server> [--dry-run]

  --profile desktop   Ubuntu Desktop / WSL-with-a-GUI-terminal: also
                       installs packages/desktop.txt and Nerd Fonts.
  --profile server    Headless Ubuntu Server (accessed over SSH):
                       skips fonts and GUI-terminal extras.
  --dry-run           Print planned actions only; change nothing.
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--profile)
		PROFILE="${2:-}"
		shift 2
		;;
	--dry-run)
		DRY_RUN=1
		shift
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		error "Unknown argument: $1"
		usage
		exit 1
		;;
	esac
done

case "$PROFILE" in
desktop | server) ;;
*)
	error "Missing or invalid --profile (must be 'desktop' or 'server')"
	usage
	exit 1
	;;
esac

extra_args=()
((DRY_RUN)) && extra_args+=(--dry-run)

essential_commands=(zip unzip curl gzip wget chattr chsh tar sudo)
check_essential_commands() {
	local missing_count=0
	local cmd
	for cmd in "${essential_commands[@]}"; do
		if ! has "${cmd}"; then
			warn "Not found: ${cmd} (essential command)"
			missing_count=$((missing_count + 1))
		fi
	done
	if ((missing_count > 0)); then
		error "Missing essential command(s). Please install them before running this script."
		exit 1
	fi
}

install_packages() {
	local profile="$1"
	local pkgs=()

	mapfile -t pkgs < <(read_package_list "$ROOT/packages/common.txt")
	if [[ "$profile" == "desktop" ]]; then
		mapfile -t -O "${#pkgs[@]}" pkgs < <(read_package_list "$ROOT/packages/desktop.txt")
	fi
	if is_wsl; then
		mapfile -t -O "${#pkgs[@]}" pkgs < <(read_package_list "$ROOT/packages/wsl.txt")
	fi

	if ((DRY_RUN)); then
		info "[dry-run] would run: sudo apt-get update && sudo apt-get install -y ${pkgs[*]}"
		return 0
	fi

	sudo apt-get update
	sudo apt-get install -y "${pkgs[@]}"
}

install_third_party_tools() {
	if ((DRY_RUN)); then
		info "[dry-run] would install zoxide, starship, mise, neovim (latest), pnpm"
		return 0
	fi

	info "Installing zoxide"
	curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

	info "Installing starship"
	curl -sS https://starship.rs/install.sh | sh -s -- -y

	info "Installing mise"
	curl https://mise.run | sh

	info "Installing neovim (latest stable)"
	local nvim_tarball="nvim-linux-x86_64.tar.gz"
	local nvim_dir="/opt/nvim-linux-x86_64" # matches NVIM_HOME in home/.zshrc
	(
		cd /tmp
		curl -LO "https://github.com/neovim/neovim/releases/latest/download/${nvim_tarball}"
		sudo rm -rf "$nvim_dir"
		sudo tar -C /opt -xzf "$nvim_tarball"
		rm -f "$nvim_tarball"
	)

	info "Installing pnpm"
	curl -fsSL https://get.pnpm.io/install.sh | sh -
}

modify_python3_path_in_nvim_option() {
	local python3_path target_file
	python3_path="$(command -v python3 || true)"
	target_file="$HOME/.config/nvim/plugin/option.lua"

	if [[ -z "$python3_path" ]]; then
		warn "python3 not found; skipping python3_host_prog update"
		return 0
	fi
	if [[ ! -f "$target_file" ]]; then
		warn "Not installed yet (missing $target_file); skipping python3_host_prog update"
		return 0
	fi
	if ((DRY_RUN)); then
		info "[dry-run] would set vim.g.python3_host_prog to '$python3_path' in $target_file"
		return 0
	fi

	sed -i -E "s|(vim\.g\.python3_host_prog = \").*\"|\1${python3_path}\"|" "$target_file"
	info "Set python3_host_prog to $python3_path"
}

main() {
	check_essential_commands
	require_os_ubuntu_debian

	"$SCRIPT_DIR/backup.sh" "${extra_args[@]}"

	install_packages "$PROFILE"
	install_third_party_tools

	"$SCRIPT_DIR/restore.sh" "${extra_args[@]}"

	if is_wsl; then
		info "WSL detected; applying profiles/wsl.sh"
		"$ROOT/profiles/wsl.sh" "${extra_args[@]}"
	fi

	info "Applying profiles/${PROFILE}.sh"
	"$ROOT/profiles/${PROFILE}.sh" "${extra_args[@]}"

	modify_python3_path_in_nvim_option

	completed "Completed install of dev tools and dotfiles (profile: ${PROFILE})"
}

main "$@"
