#!/bin/bash
# Thin wrapper kept at the repo root for muscle memory.
# See scripts/install.sh for the real implementation, and
# docs/superpowers/specs/2026-09-12-ubuntu-multi-env-restructure-design.md
# for the design behind this layout.
set -euo pipefail
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/install.sh" "$@"
