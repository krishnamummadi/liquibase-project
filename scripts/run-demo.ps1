<#
Simple demo runner for the Liquibase POC.
This script is intentionally conservative: it prefers existing helper scripts when available.
#>

$ErrorActionPreference = 'Stop'
$root = Resolve-Path "$PSScriptRoot\.."
Set-Location $root

Write-Host "Starting Liquibase POC demo..."

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "docker not found on PATH. Ensure Docker Desktop is running." -ForegroundColor Yellow
    exit 1
}

Write-Host "Bringing up containers (docker compose up -d)..."
docker compose up -d

Write-Host "Waiting for SQL Server to accept connections..."
$max = 60
for ($i=0; $i -lt $max; $i++) {
    try {
        & sqlcmd -S localhost,1433 -U sa -P 'YourStrong!Passw0rd' -Q 'SELECT 1' -b -C -h -1 > $null 2>&1
        if ($LASTEXITCODE -eq 0) { break }
    } catch { }
    Start-Sleep -Seconds 3
}
if ($i -ge $max) { Write-Host "SQL Server did not become available in time." -ForegroundColor Red; exit 1 }

Write-Host "Creating databases..."
& sqlcmd -S localhost,1433 -U sa -P 'YourStrong!Passw0rd' -i .\scripts\init-databases.sql -C

if (Test-Path .\scripts\run-poc.ps1) {
    Write-Host "Found run-poc.ps1 — delegating full end-to-end run to it..."
    & .\scripts\run-poc.ps1
} else {
    Write-Host "Running individual steps: applying changelogs and promoting to test..."
    if (Test-Path .\scripts\run-liquibase.ps1) {
        & .\scripts\run-liquibase.ps1 -Env dev
        & .\scripts\run-liquibase.ps1 -Env stage
    } else {
        Write-Host "run-liquibase.ps1 not found — please run Liquibase steps manually." -ForegroundColor Yellow
    }
    if (Test-Path .\scripts\promote-to-test.ps1) {
        & .\scripts\promote-to-test.ps1 -SeedFromStage
    } else {
        Write-Host "promote-to-test.ps1 not found — please promote manually." -ForegroundColor Yellow
    }
}

Write-Host "Running validation..."
if (Test-Path .\scripts\validate-promotion.ps1) {
    & .\scripts\validate-promotion.ps1
} else {
    Write-Host "validate-promotion.ps1 not found — please run validation manually." -ForegroundColor Yellow
}

Write-Host "Demo finished."
