Add-Type -AssemblyName System.Drawing

$vscodeExe   = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"
$scriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$launcherPs1 = Join-Path $scriptDir "Launch-VSCode.ps1"
$iconPath    = Join-Path $scriptDir "vscode_desktop.ico"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcut    = "$desktopPath\VS Code (Virtual Desktop).lnk"

if (-not (Test-Path $launcherPs1)) {
	throw "Launcher script not found: $launcherPs1"
}

# ── Extract VS Code icon and save as .ico ─────────────────────────────────────
if (Test-Path $vscodeExe) {
	$srcIcon = [System.Drawing.Icon]::ExtractAssociatedIcon($vscodeExe)

	# Rebuild at 256x256 for a crisp shortcut icon
	$bmp = New-Object System.Drawing.Bitmap 256, 256
	$g   = [System.Drawing.Graphics]::FromImage($bmp)
	$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
	$g.DrawImage($srcIcon.ToBitmap(), 0, 0, 256, 256)
	$g.Dispose()

	$resized = [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
	$fs = [System.IO.File]::OpenWrite($iconPath)
	$resized.Save($fs)
	$fs.Close()
	$bmp.Dispose()

	Write-Host "Icon saved : $iconPath" -ForegroundColor Green
}
else {
	Write-Warning "VS Code executable not found at '$vscodeExe'. Shortcut will use the default PowerShell icon."
}

# ── Create desktop shortcut (.lnk) ───────────────────────────────────────────
$wsh  = New-Object -ComObject WScript.Shell
$lnk  = $wsh.CreateShortcut($shortcut)

$lnk.TargetPath       = "powershell.exe"
$lnk.Arguments        = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$launcherPs1`""
$lnk.WorkingDirectory = $scriptDir
if (Test-Path $iconPath) {
	$lnk.IconLocation = "$iconPath,0"
}
$lnk.Description      = "Open VS Code for the current virtual desktop"
$lnk.Save()

Write-Host "Shortcut   : $shortcut" -ForegroundColor Green
