#!/bin/bash
# Server-only setup. Intentionally empty: Ubuntu Server is accessed over
# SSH from another machine, which renders its own terminal and fonts, so
# there is nothing GUI-related to install here. Kept as an explicit stub
# so future server-specific steps have an obvious home.
#
# Usage: profiles/server.sh [--dry-run]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source-path=SCRIPTDIR source=../scripts/lib.sh
source "$ROOT/scripts/lib.sh"

for arg in "$@"; do
	case "$arg" in
	--dry-run) ;;
	*)
		error "Unknown argument: $arg"
		exit 1
		;;
	esac
done

info "No server-specific setup steps (headless: no fonts, no GUI-terminal extras)."
