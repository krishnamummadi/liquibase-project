param(
    [switch]$SeedFromStage
)

$ErrorActionPreference = "Stop"

Write-Host "Applying schema to test environment..."
& "$PSScriptRoot/run-liquibase.ps1" -ConfigFile "$PSScriptRoot/../config/test.properties" -Contexts "test"

if ($SeedFromStage) {
    Write-Host "Seeding test from stage..."
    $sqlFile = Join-Path $PSScriptRoot 'seed-test-from-stage.sql'
    if (-not (Test-Path $sqlFile)) {
        throw "Seed script not found: $sqlFile"
    }

    & "$PSScriptRoot/sqlcmd-helper.ps1" -Server 'localhost,1433' -User 'sa' -Password 'YourStrong!Passw0rd' -ScriptPath $sqlFile
}
