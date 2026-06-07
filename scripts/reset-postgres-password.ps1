# Reset forgotten PostgreSQL "postgres" superuser password (Windows)
# MUST run PowerShell as Administrator

#Requires -RunAsAdministrator

param(
    [string]$NewPassword = "mgn_admin_2026",
    [string]$PgVersion = "17"
)

$ErrorActionPreference = "Stop"

$pgDir = "C:\Program Files\PostgreSQL\$PgVersion"
$psql = Join-Path $pgDir "bin\psql.exe"
$pgHba = Join-Path $pgDir "data\pg_hba.conf"
$serviceName = "postgresql-x64-$PgVersion"
$backup = "$pgHba.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

if (-not (Test-Path $psql)) {
    Write-Host "PostgreSQL $PgVersion not found at $pgDir" -ForegroundColor Red
    exit 1
}

Write-Host "=== PostgreSQL Password Reset ===" -ForegroundColor Cyan
Write-Host "New password will be: $NewPassword" -ForegroundColor Yellow
Write-Host ""

# 1. Backup pg_hba.conf
Copy-Item $pgHba $backup -Force
Write-Host "Backup: $backup" -ForegroundColor Green

# 2. Temporarily allow login without password (localhost only)
$content = Get-Content $pgHba -Raw
$temp = $content -replace 'scram-sha-256', 'trust' -replace 'md5', 'trust'
Set-Content -Path $pgHba -Value $temp -NoNewline

# 3. Restart PostgreSQL
Write-Host "Restarting PostgreSQL service..." -ForegroundColor Cyan
Restart-Service $serviceName -Force
Start-Sleep -Seconds 3

# 4. Set new password
Write-Host "Setting new password..." -ForegroundColor Cyan
$sql = "ALTER USER postgres WITH PASSWORD '$NewPassword';"
& $psql -U postgres -h localhost -d postgres -c $sql
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to set password. Restoring pg_hba.conf..." -ForegroundColor Red
    Copy-Item $backup $pgHba -Force
    Restart-Service $serviceName -Force
    exit 1
}

# 5. Restore original pg_hba.conf
Copy-Item $backup $pgHba -Force
Restart-Service $serviceName -Force

Write-Host ""
Write-Host "Password reset successful!" -ForegroundColor Green
Write-Host ""
Write-Host "postgres password: $NewPassword" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next, run database setup:" -ForegroundColor Cyan
Write-Host "  cd d:\mgn\scripts" -ForegroundColor White
Write-Host "  `$env:PGPASSWORD = '$NewPassword'" -ForegroundColor White
Write-Host "  .\setup-postgres-windows.ps1" -ForegroundColor White
