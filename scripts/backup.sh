#!/bin/bash
# Snapshots any pre-existing (non-symlink, or symlinked-to-something-else)
# files/directories at the paths that scripts/restore.sh is about to
# replace with symlinks, so nothing is silently lost.
#
# Usage: scripts/backup.sh [--dry-run]
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
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$ROOT/backups/$TIMESTAMP"

backed_up_any=0

while IFS=$'\t' read -r src dest; do
	# Nothing there yet: nothing to protect.
	if [[ ! -e "$dest" && ! -L "$dest" ]]; then
		continue
	fi
	# Already the correct symlink: nothing to protect.
	if [[ -L "$dest" ]] && [[ "$(readlink -f "$dest" 2>/dev/null)" == "$(readlink -f "$src" 2>/dev/null)" ]]; then
		continue
	fi

	rel="${dest#"$HOME"/}"
	target="$BACKUP_DIR/$rel"

	if ((DRY_RUN)); then
		info "[dry-run] would back up '$dest' -> '$target'"
		backed_up_any=1
		continue
	fi

	mkdir -p "$(dirname "$target")"
	mv "$dest" "$target"
	info "Backed up '$dest' -> '$target'"
	backed_up_any=1
done < <(managed_targets "$ROOT")

if ((backed_up_any)); then
	if ((DRY_RUN)); then
		info "Dry-run: would create snapshot under $BACKUP_DIR"
	else
		completed "Snapshot saved to $BACKUP_DIR"
	fi
else
	info "Nothing to back up (no pre-existing files at managed paths)."
fi
