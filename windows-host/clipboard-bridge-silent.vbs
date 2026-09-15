' Launches clipboard-bridge.ps1 with no window at all.
'
' `pwsh.exe -WindowStyle Hidden` on its own is not enough here: it is a
' documented, long-standing bug that -WindowStyle Hidden has no effect
' when the process is launched by Task Scheduler (the window still
' appears, hosted in Windows Terminal on Windows 11) --
' https://learn.microsoft.com/en-us/answers/questions/1655199/powershell-exe-windowstyle-hidden-seems-to-be-brok
'
' That stray window turned out to have a second, worse side effect on
' god77's Windows 11 box: as long as it existed, Ctrl+Shift (the input
' language / IME toggle) stopped working in the actual SSH terminal
' window. Windows' per-window input-language tracking is known to get
' confused by extra windows coming and going; removing the extra window
' fixed it immediately. See docs/clipboard-bridge-design.md.
'
' WScript.Shell.Run's window-style argument (0 = hidden) is honored at
' process-creation time itself, before any window is ever shown -- this
' is the standard, reliable way to launch something with truly no
' window, unlike -WindowStyle Hidden.
'
' Usage: point the ClipboardBridge scheduled task's action at this file
' (via wscript.exe) instead of at pwsh.exe directly. See section 7.5 of
' docs/clipboard-bridge-design.md for the exact registration command.

Set objShell = CreateObject("WScript.Shell")
homeDir = objShell.ExpandEnvironmentStrings("%USERPROFILE%")
scriptPath = homeDir & "\clipboard-bridge.ps1"

' -NoProfile: this is a headless listener, not an interactive shell --
' no reason to pay the cost of (or depend on) loading
' Microsoft.PowerShell_profile.ps1 for it.
command = "pwsh.exe -NoProfile -WindowStyle Hidden -File """ & scriptPath & """"

' 0 = hidden window, False = don't wait for it to exit
objShell.Run command, 0, False
