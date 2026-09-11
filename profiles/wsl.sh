#!/bin/bash
# WSL-only setup: /etc/wsl.conf, /etc/resolv.conf, and win32yank (used by
# home/.config/nvim/plugin/option.lua's `vim.fn.has("wsl")` clipboard
# integration). Run by scripts/install.sh only when is_wsl() is true.
#
# Usage: profiles/wsl.sh [--dry-run]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source-path=SCRIPTDIR source=../scripts/lib.sh
source "$ROOT/scripts/lib.sh"

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

configure_wsl_conf() {
	local wsl_conf="/etc/wsl.conf"
	local content
	content="$(
		cat <<'EOF'
[interop]
appendWindowsPath=false

[network]
generateResolvConf=false
EOF
	)"

	if ((DRY_RUN)); then
		info "[dry-run] would write $wsl_conf:"
		printf '%s\n' "$content"
		return 0
	fi

	printf '%s\n' "$content" | sudo tee "$wsl_conf" >/dev/null
	info "Wrote $wsl_conf"
}

configure_resolv_conf() {
	local resolv_conf="/etc/resolv.conf"
	local content
	content="$(
		cat <<'EOF'
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
	)"

	if ((DRY_RUN)); then
		info "[dry-run] would write $resolv_conf and mark it immutable (chattr +i):"
		printf '%s\n' "$content"
		return 0
	fi

	# generateResolvConf=false (set above) stops wsl.exe from rewriting
	# this file on every launch, but write it before marking it
	# immutable -- not after, and clear any pre-existing immutable bit
	# first so re-running this script is idempotent.
	sudo chattr -i "$resolv_conf" 2>/dev/null || true
	printf '%s\n' "$content" | sudo tee "$resolv_conf" >/dev/null
	sudo chattr +i "$resolv_conf"
	info "Wrote $resolv_conf and marked it immutable"
}

install_win32yank() {
	local dest_dir="/mnt/c/Tools"
	local dest="$dest_dir/win32yank.exe"

	if ((DRY_RUN)); then
		info "[dry-run] would download win32yank and install it to $dest"
		return 0
	fi

	if [[ ! -d /mnt/c ]]; then
		warn "/mnt/c not found; skipping win32yank install (is the Windows drive mounted?)"
		return 0
	fi

	local tmp_dir
	tmp_dir="$(mktemp -d)"
	# shellcheck disable=SC2064
	trap "rm -rf '$tmp_dir'" RETURN

	if ! curl -sSfL -o "$tmp_dir/win32yank.zip" \
		"https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip"; then
		warn "Failed to download win32yank; skipping (clipboard integration in nvim will not work)"
		return 0
	fi

	mkdir -p "$dest_dir"
	unzip -o -q "$tmp_dir/win32yank.zip" -d "$tmp_dir"
	cp "$tmp_dir/win32yank.exe" "$dest"
	info "Installed win32yank to $dest"
}

configure_wsl_conf
configure_resolv_conf
install_win32yank

((DRY_RUN)) || completed "Applied WSL-specific configuration"
