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

# Only tools genuinely needed before apt can install anything else.
# zip/unzip are deliberately NOT here: they're apt-installed by this
# same script (packages/common.txt) rather than assumed pre-existing --
# a minimal Ubuntu Server image doesn't ship them.
essential_commands=(curl gzip wget chattr chsh tar sudo)
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

# On WSL, a leaked Windows PATH (npm.exe, node.exe, git.exe, ... via
# interop) silently corrupts this install: apt/toolchain steps would
# still work, but anything shelling out to `npm`/`node`/etc. later
# (mason.nvim being the concrete case that broke) can pick up the
# Windows binary instead of the Linux one, and it fails in confusing
# ways operating on a Linux path. So on WSL this install refuses to
# proceed until appendWindowsPath=false is both configured AND has
# actually taken effect (WSL only applies wsl.conf on restart, not
# live -- writing the file is not enough by itself).
ensure_wsl_windows_path_disabled() {
	is_wsl || return 0

	local wsl_conf="/etc/wsl.conf"
	local configured=0
	if [[ -f "$wsl_conf" ]] && grep -q "appendWindowsPath=false" "$wsl_conf" 2>/dev/null; then
		configured=1
	fi

	if ((!configured)); then
		if ((DRY_RUN)); then
			info "[dry-run] would write $wsl_conf with appendWindowsPath=false"
		else
			wsl_conf_content | sudo tee "$wsl_conf" >/dev/null
			info "Wrote $wsl_conf (appendWindowsPath=false)"
		fi
	fi

	if ((configured)) && ! path_has_windows_entries; then
		info "WSL check OK: appendWindowsPath=false is active and \$PATH has no Windows entries"
		return 0
	fi

	cat >&2 <<EOF

################################################################################
#  WSL restart required before this can continue                             #
################################################################################

  Windows' PATH (npm.exe, node.exe, git.exe, ...) is still visible from
  inside this WSL distro. Installing with it present has caused broken
  installs before (e.g. mason.nvim silently running Windows' npm.exe
  instead of Linux's, which fails in confusing ways on a Linux path).

  $(if ((configured)); then
		echo "/etc/wsl.conf already has appendWindowsPath=false, but WSL only"
		echo "  applies wsl.conf changes after a restart -- it hasn't taken"
		echo "  effect in this session yet."
	else
		echo "/etc/wsl.conf has just been written with appendWindowsPath=false."
	fi)

  Next steps:
    1. From a Windows PowerShell prompt (NOT inside WSL), run:

         wsl.exe --shutdown

    2. Reopen this Ubuntu terminal.
    3. Re-run this exact command:

         ./setup.sh --profile ${PROFILE}

################################################################################

EOF

	if ((DRY_RUN)); then
		warn "[dry-run] would stop here and require a WSL restart before continuing"
		return 0
	fi
	exit 1
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
		info "[dry-run] would install starship, neovim (latest), pnpm"
		info "[dry-run] (zoxide now comes from packages/common.txt via apt)"
		return 0
	fi

	info "Installing starship"
	curl -sS https://starship.rs/install.sh | sh -s -- -y

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

# When this install is happening over SSH with no display to fall back
# on, home/.config/nvim/plugin/option.lua switches Neovim's clipboard
# paste ("+p / plain p) to a small TCP bridge instead of OSC52 (OSC52
# read is refused by Windows Terminal/WezTerm, and not relayed by tmux
# either -- see docs/clipboard-bridge-design.md for the full story).
# That bridge's other half has to be set up by hand on the machine this
# SSH connection is coming FROM, which this script has no access to, so
# the best it can do is print what's needed and point at the file to
# copy over. Purely informational -- never blocks the install.
print_ssh_clipboard_bridge_notice() {
	is_ssh_no_display || return 0

	cat <<'EOF'

################################################################################
#  Clipboard paste ("+p / plain p) needs a one-time setup on the               #
#  Windows machine you're SSHing in from                                       #
################################################################################

  This is an SSH session with no display, so Neovim's clipboard here uses
  a small TCP bridge for paste (copy already works over OSC52 with no
  extra setup). The bridge has two halves; this script only installed
  the Linux side (home/.config/nvim/lua/clipboard_bridge.lua). The
  Windows side needs to be set up by hand, once, on the machine you
  connect FROM:

  1. Copy windows-host/clipboard-bridge.ps1 AND
     windows-host/clipboard-bridge-silent.vbs from this repo to $HOME
     on that Windows machine.

  2. Register the .vbs (not pwsh.exe directly -- WindowStyle Hidden is
     a documented no-op under Task Scheduler and leaves a visible
     window, which on god77's Windows box also broke Ctrl+Shift IME
     toggling in the actual SSH terminal for as long as it stayed
     open) to start at every logon (PowerShell, admin not required in
     testing so far -- if "Access is denied", retry from an elevated
     PowerShell):

       $action = New-ScheduledTaskAction -Execute "wscript.exe" `
           -Argument "`"$HOME\clipboard-bridge-silent.vbs`""
       $trigger = New-ScheduledTaskTrigger -AtLogOn
       Register-ScheduledTask -TaskName "ClipboardBridge" -Action $action -Trigger $trigger

  3. Add a RemoteForward for this host to that machine's SSH config
     (%USERPROFILE%\.ssh\config), so the tunnel is set up automatically
     on every connection:

       Host <this host's alias>
           RemoteForward 127.0.0.1:52599 127.0.0.1:52599

  Full design, rationale, security notes, and troubleshooting:
  docs/clipboard-bridge-design.md

################################################################################

EOF
}

modify_python3_path_in_nvim_option() {
	local python3_path target_file
	python3_path="$(command -v python3 || true)"
	target_file="$HOME/.config/nvim/plugin/option.lua"

	if [[ -z "$python3_path" ]]; then
		warn "python3 not found; skipping python3_host_prog update"
		return 0
	fi

	if ((DRY_RUN)); then
		info "[dry-run] would set vim.g.python3_host_prog to '$python3_path' in $target_file (once restore.sh has actually symlinked it)"
		return 0
	fi

	if [[ ! -f "$target_file" ]]; then
		warn "Not installed yet (missing $target_file); skipping python3_host_prog update"
		return 0
	fi

	sed -i -E "s|(vim\.g\.python3_host_prog = \").*\"|\1${python3_path}\"|" "$target_file"
	info "Set python3_host_prog to $python3_path"
}

main() {
	check_essential_commands
	require_os_ubuntu_debian
	ensure_wsl_windows_path_disabled

	"$SCRIPT_DIR/backup.sh" "${extra_args[@]}"

	install_packages "$PROFILE"
	install_third_party_tools
	"$SCRIPT_DIR/toolchains.sh" "${extra_args[@]}"

	"$SCRIPT_DIR/restore.sh" "${extra_args[@]}"

	if is_wsl; then
		info "WSL detected; applying profiles/wsl.sh"
		"$ROOT/profiles/wsl.sh" "${extra_args[@]}"
	fi

	info "Applying profiles/${PROFILE}.sh"
	"$ROOT/profiles/${PROFILE}.sh" "${extra_args[@]}"

	modify_python3_path_in_nvim_option

	completed "Completed install of dev tools and dotfiles (profile: ${PROFILE})"

	print_ssh_clipboard_bridge_notice

	((DRY_RUN)) && return 0

	info "Starting zsh..."
	exec zsh
}

main "$@"
