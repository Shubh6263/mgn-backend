# Fix flutterfire not found + run Firebase configure
# Run from: d:\mgn\medglobalnetwork (or any folder)

$pubBin = "$env:LOCALAPPDATA\Pub\Cache\bin"

if (-not (Test-Path "$pubBin\flutterfire.bat")) {
    Write-Host "flutterfire not installed. Run first:" -ForegroundColor Yellow
    Write-Host "  dart pub global activate flutterfire_cli"
    exit 1
}

# Add to PATH for this PowerShell session
if ($env:Path -notlike "*$pubBin*") {
    $env:Path = "$pubBin;$env:Path"
    Write-Host "Added to PATH (this session): $pubBin" -ForegroundColor Green
}

# Optionally persist for future terminals (User PATH only)
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$pubBin*") {
    $add = Read-Host "Add Pub bin to permanent User PATH? (y/n)"
    if ($add -eq "y") {
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$pubBin", "User")
        Write-Host "Permanent PATH updated. Restart PowerShell after this." -ForegroundColor Green
    }
}

Set-Location (Join-Path $PSScriptRoot "..\medglobalnetwork")

Write-Host ""
Write-Host "Running flutterfire configure..." -ForegroundColor Cyan
Write-Host "Login with your Google account and select/create Firebase project." -ForegroundColor Cyan
Write-Host ""

& "$pubBin\flutterfire.bat" configure
