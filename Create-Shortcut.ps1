$vscodeExe   = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"
$scriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$launcherPs1 = Join-Path $scriptDir "Launch-VSCode.ps1"
$iconPath    = Join-Path $scriptDir "vscode_desktop.ico"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcut    = "$desktopPath\VS Code (Virtual Desktop).lnk"

if (-not (Test-Path $launcherPs1)) {
	throw "Launcher script not found: $launcherPs1"
}

function Get-ShortcutIconLocation {
	if (Test-Path $vscodeExe) {
		return "$vscodeExe,0"
	}

	if (Test-Path $iconPath) {
		return "$iconPath,0"
	}

	Write-Warning "VS Code icon source not found. Shortcut will use the default PowerShell icon."
	return $null
}

# ── Create desktop shortcut (.lnk) ───────────────────────────────────────────
$wsh  = New-Object -ComObject WScript.Shell
$lnk  = $wsh.CreateShortcut($shortcut)
$iconLocation = Get-ShortcutIconLocation

$lnk.TargetPath       = "powershell.exe"
$lnk.Arguments        = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$launcherPs1`""
$lnk.WorkingDirectory = $scriptDir
if ($iconLocation) {
	$lnk.IconLocation = $iconLocation
}
$lnk.Description      = "Open VS Code for the current virtual desktop"
$lnk.Save()

Write-Host "Shortcut   : $shortcut" -ForegroundColor Green
