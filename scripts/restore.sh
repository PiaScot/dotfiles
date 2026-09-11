#!/bin/bash
# Symlinks home/ into $HOME. Never copies: editing ~/.zshrc after this
# runs is the same as editing home/.zshrc in this repo. See
# docs/symlink-workflow.md for the day-to-day workflow this implies.
#
# Usage: scripts/restore.sh [--dry-run]
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

ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Protect anything real that's currently sitting where a symlink is
# about to go.
if ((DRY_RUN)); then
	"$SCRIPT_DIR/backup.sh" --dry-run
else
	"$SCRIPT_DIR/backup.sh"
fi

while IFS=$'\t' read -r src dest; do
	parent="$(dirname "$dest")"
	if ((DRY_RUN)); then
		info "[dry-run] would ensure directory '$parent' exists"
		info "[dry-run] would symlink '$dest' -> '$src'"
		continue
	fi
	mkdir -p "$parent"
	ln -sfn "$src" "$dest"
	info "Linked '$dest' -> '$src'"
done < <(managed_targets "$ROOT")

((DRY_RUN)) || completed "Restored dotfiles into \$HOME via symlink"
