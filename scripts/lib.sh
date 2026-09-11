#!/bin/bash
# Shared helpers sourced by scripts/install.sh, scripts/backup.sh,
# scripts/restore.sh and profiles/*.sh. Not meant to be executed directly.

BOLD="$(tput bold 2>/dev/null || printf '')"
GREY="$(tput setaf 0 2>/dev/null || printf '')"
RED="$(tput setaf 1 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
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
	command -v "$1" >/dev/null 2>&1
}

# True when the running kernel is WSL2 (or WSL1).
is_wsl() {
	uname -r | grep -iq "wsl"
}

# Prints the distro ID from /etc/os-release (e.g. "ubuntu", "debian"),
# or nothing if the file is missing.
get_os_id() {
	if [[ -f /etc/os-release ]]; then
		# shellcheck disable=SC1091
		. /etc/os-release
		printf '%s' "${ID:-}"
	fi
}

# Aborts with an error unless the current OS is Ubuntu or Debian.
# This repo's install/profile scripts only target apt-based systems.
require_os_ubuntu_debian() {
	local os_id
	os_id="$(get_os_id)"
	case "$os_id" in
	ubuntu | debian) ;;
	*)
		error "Unsupported OS: '${os_id:-unknown}'. This installer targets Ubuntu/Debian only."
		exit 1
		;;
	esac
}

# Prints "src<TAB>dest" lines for every path scripts/backup.sh and
# scripts/restore.sh manage. $1 is the repo root.
#
# Top-level entries of home/ (.zshrc, .tmux.conf) map straight to
# $HOME, while home/.config/* and home/.cargo/* are listed one level
# down so unrelated files already inside ~/.config or ~/.cargo (npm,
# gradle, etc.) are never touched.
managed_targets() {
	local root="$1"
	printf '%s\t%s\n' "$root/home/.zshrc" "$HOME/.zshrc"
	printf '%s\t%s\n' "$root/home/.tmux.conf" "$HOME/.tmux.conf"

	local entry name
	if [[ -d "$root/home/.config" ]]; then
		for entry in "$root/home/.config"/*; do
			[[ -e "$entry" ]] || continue
			name="$(basename "$entry")"
			printf '%s\t%s\n' "$entry" "$HOME/.config/$name"
		done
	fi
	if [[ -d "$root/home/.cargo" ]]; then
		for entry in "$root/home/.cargo"/*; do
			[[ -e "$entry" ]] || continue
			name="$(basename "$entry")"
			printf '%s\t%s\n' "$entry" "$HOME/.cargo/$name"
		done
	fi
}

# Reads a packages/*.txt file (one package per line, '#' comments and
# blank lines skipped) and prints the package names, one per line.
read_package_list() {
	local file="$1"
	if [[ ! -f "$file" ]]; then
		return 0
	fi
	grep -vE '^\s*(#|$)' "$file"
}
