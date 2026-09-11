# Copies this repo's Windows-host files into place: wezterm (which
# launches into WSL/SSH) and the PowerShell profile. These are not
# Linux dotfiles -- they belong to the Windows machine you connect
# from, independent of which Ubuntu profile (wsl/desktop/server) is
# running on the other end.
#
# Run from a PowerShell prompt on Windows:
#   powershell -ExecutionPolicy Bypass -File .\install.ps1
#
# Not verified on a real Windows machine as part of this change.

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$weztermSrc = Join-Path $repoRoot ".wezterm.lua"
$weztermDest = Join-Path $HOME ".wezterm.lua"
Copy-Item -Path $weztermSrc -Destination $weztermDest -Force
Write-Host "Copied $weztermSrc -> $weztermDest"

$profileSrc = Join-Path $repoRoot "Microsoft.PowerShell_profile.ps1"
$profileDest = $PROFILE
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $profileDest) | Out-Null
Copy-Item -Path $profileSrc -Destination $profileDest -Force
Write-Host "Copied $profileSrc -> $profileDest"
