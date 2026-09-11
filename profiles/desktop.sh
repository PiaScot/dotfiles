#!/bin/bash
# Desktop-only setup: Nerd Fonts for the local GUI terminal. Server
# profile skips this entirely (fonts render on the SSH client, not here).
#
# Usage: profiles/desktop.sh [--dry-run]
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

# "name|url" pairs. Only fonts with a stable, version-free release URL
# are auto-installed. UDEV Gothic's release assets are versioned in the
# filename (e.g. UDEVGothicNF_x.y.z.zip), so it stays a documented
# manual step below instead of a guessed regex that could silently
# start downloading the wrong file.
fonts=(
	"GoMono Nerd Font|https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Go-Mono.zip"
	"IosevkaTerm Slab Nerd Font|https://github.com/ryanoasis/nerd-fonts/releases/latest/download/IosevkaTermSlab.zip"
)

install_nerd_fonts() {
	local fonts_dir="$HOME/.local/share/fonts"

	if ((DRY_RUN)); then
		info "[dry-run] would install fonts to $fonts_dir:"
		local entry
		for entry in "${fonts[@]}"; do
			info "[dry-run]   ${entry%%|*}"
		done
		info "[dry-run] would run: fc-cache -f"
		return 0
	fi

	mkdir -p "$fonts_dir"

	local entry name url tmp_dir
	for entry in "${fonts[@]}"; do
		name="${entry%%|*}"
		url="${entry#*|}"
		tmp_dir="$(mktemp -d)"

		if ! curl -sSfL -o "$tmp_dir/font.zip" "$url"; then
			warn "Failed to download font '$name'; skipping"
			rm -rf "$tmp_dir"
			continue
		fi

		unzip -o -q "$tmp_dir/font.zip" -d "$fonts_dir"
		rm -rf "$tmp_dir"
		info "Installed font: $name"
	done

	fc-cache -f >/dev/null
	completed "Fonts installed to $fonts_dir"
}

install_nerd_fonts

info "UDEV Gothic is not auto-installed (versioned release filename)."
info "Install manually from: https://github.com/yuru7/udev-gothic/releases/latest"
