# MedGlobal Network - PostgreSQL setup for Windows (no Docker)
# Run in PowerShell (as Administrator recommended for first-time install)

param(
    [string]$DbUser = "mgn_user",
    [string]$DbPassword = "mgn_password",
    [string]$DbName = "medglobalnetwork",
    [int]$Port = 5432
)

$ErrorActionPreference = "Stop"

function Find-Psql {
    $cmd = Get-Command psql -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $paths = @(
        "C:\Program Files\PostgreSQL\17\bin\psql.exe",
        "C:\Program Files\PostgreSQL\16\bin\psql.exe",
        "C:\Program Files\PostgreSQL\15\bin\psql.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

Write-Host "=== MedGlobal Network DB Setup ===" -ForegroundColor Cyan

$psql = Find-Psql
if (-not $psql) {
    Write-Host ""
    Write-Host "PostgreSQL not found." -ForegroundColor Yellow
    Write-Host "Install it with (run PowerShell as Administrator):" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  winget install PostgreSQL.PostgreSQL.17 --accept-package-agreements --accept-source-agreements" -ForegroundColor White
    Write-Host ""
    Write-Host "During install, set superuser (postgres) password and remember it."
    Write-Host "Then close and reopen PowerShell, and run this script again."
    Write-Host ""
    exit 1
}

Write-Host "Found psql: $psql" -ForegroundColor Green

$pgPassword = $env:PGPASSWORD
if (-not $pgPassword) {
    Write-Host "Tip: set password first to skip prompt:" -ForegroundColor DarkGray
    Write-Host '  $env:PGPASSWORD = "your_postgres_password"' -ForegroundColor DarkGray
    Write-Host "Forgot password? Run as Admin: .\reset-postgres-password.ps1" -ForegroundColor DarkGray
    Write-Host ""
    $secure = Read-Host "Enter PostgreSQL superuser (postgres) password" -AsSecureString
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    $pgPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto($ptr)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
}

$env:PGPASSWORD = $pgPassword
$psqlArgs = @("-h", "localhost", "-p", "$Port", "-U", "postgres", "-v", "ON_ERROR_STOP=1")

Write-Host "Creating role and database..." -ForegroundColor Cyan

$sql = @"
DO `$`$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$DbUser') THEN
    CREATE ROLE $DbUser WITH LOGIN PASSWORD '$DbPassword';
  END IF;
END
`$`$;

SELECT 'CREATE DATABASE $DbName OWNER $DbUser'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DbName')\gexec

GRANT ALL PRIVILEGES ON DATABASE $DbName TO $DbUser;
"@

$sql | & $psql @psqlArgs 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to create role/database. Check postgres password and that PostgreSQL service is running." -ForegroundColor Red
    Write-Host "Start service:  Start-Service postgresql-x64-17  (version number may differ)" -ForegroundColor Yellow
    exit 1
}

$migrationFile = Join-Path $PSScriptRoot "..\backend\migrations\001_create_users.sql"
if (Test-Path $migrationFile) {
    Write-Host "Running migrations..." -ForegroundColor Cyan
    $env:PGPASSWORD = $DbPassword
    & $psql @("-h", "localhost", "-p", "$Port", "-U", $DbUser, "-d", $DbName, "-v", "ON_ERROR_STOP=1", "-f", $migrationFile)
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Migration failed." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Database ready!" -ForegroundColor Green
Write-Host "Connection string:" -ForegroundColor Cyan
Write-Host "  postgres://${DbUser}:${DbPassword}@localhost:${Port}/${DbName}"
Write-Host ""
Write-Host "Start backend:" -ForegroundColor Cyan
Write-Host "  cd d:\mgn\backend"
Write-Host "  cargo run"
