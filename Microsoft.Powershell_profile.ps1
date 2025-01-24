Import-Module PSReadLine

Set-PSReadlineOption -EditMode Emacs
Set-PSReadLineKeyHandler -Key Ctrl+i -Function Complete
Set-PSReadLineKeyHandler -Key Ctrl+j -Function AcceptLine
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteChar

function nvim_ps_profile() { nvim $PROFILE }
function source_reload_ps_profile() { . $profile }
function print_verbose_command() {
  param(
      [string]$arg
      )
    Get-Command $arg | Format-List
}

function Open-Files {
  [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Files
        )
      foreach ($file in $Files) {
        $extension = [System.IO.Path]::GetExtension($file)
          switch ($extension) {
            { $_ -in (".txt", ".ps1", ".psm1", ".csv", ".xml") } { nvim $file }
            { $_ -in (".exe", ".dll", ".bat", ".ps1") }
            { Write-Warning "Trying to open binary file $file. Are you sure?" }
            default {
              Invoke-Item $file
            }
          }
      }
}

function Move_Upper_Directory { Set-Location -Path .. }
function Invoke-As-Admin() {
  if ($args.count -eq 0) {
    gsudo
      return
  }
  $cmd = $args -join ' '
    gsudo "pwsh.exe -Login -Command { $cmd }"
}

Set-Alias -Name: "sudo" -Value: "Invoke-As-Admin"
Set-Alias which print_verbose_command
Set-Alias psrc nvim_ps_profile
Set-Alias sor source_reload_ps_profile
Set-Alias cdnvim change_directory_neovim
Set-Alias ea ls
Set-Alias la ls
Set-Alias -Name: "open" -Value: "Open-Files"
Set-Alias -Name: ".." -Value: "Move_Upper_Directory"
Set-Alias v nvim

Set-PSReadlineKeyHandler -Chord Ctrl+f -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('zi')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
 }

# Install-Module -Name Terminal-Icons
Import-Module -Name Terminal-Icons

# https://github.com/uutils/coreutils
@"
  arch, base32, base64, basename, cat, cksum, comm, cp, cut, date, df, dircolors, dirname,
  echo, env, expand, expr, factor, false, fmt, fold, hashsum, head, hostname, join, link, ln,
  md5sum, mkdir, mktemp, more, mv, nl, nproc, od, paste, printenv, printf, ptx, pwd,
  readlink, realpath, relpath, rm, rmdir, seq, sha1sum, sha224sum, sha256sum, sha3-224sum,
  sha3-256sum, sha3-384sum, sha3-512sum, sha384sum, sha3sum, sha512sum, shake128sum,
  shake256sum, shred, shuf, sleep, sort, split, sum, sync, tac, tail, tee, test, touch, tr,
  true, truncate, tsort, unexpand, uniq, wc, whoami, yes
"@ -split ',' |
ForEach-Object { $_.trim() } |
Where-Object { ! @('tee', 'sort', 'sleep').Contains($_) } |
ForEach-Object {
    $cmd = $_
    if (Test-Path Alias:$cmd) { Remove-Item -Path Alias:$cmd }
    $fn = '$input | coreutils ' + $cmd + ' $args'
    Invoke-Expression "function global:$cmd { $fn }" 
}

# https://github.com/starship/starship
# https://github.com/ajeetdsouza/zoxide
Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })
