param(
    [switch]$SkipDocker,
    [switch]$SkipSeed
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot

if (-not $SkipDocker) {
    Write-Host 'Starting SQL Server container...'
    & docker compose -f "$projectRoot/docker-compose.yml" up -d
}

Write-Host 'Creating databases...'
& "$projectRoot/scripts/sqlcmd-helper.ps1" -Server 'localhost,1433' -User 'sa' -Password 'YourStrong!Passw0rd' -ScriptPath "$projectRoot/scripts/init-databases.sql"

Write-Host 'Applying Liquibase changes to dev...'
& "$projectRoot/scripts/run-liquibase.ps1" -ConfigFile "$projectRoot/config/dev.properties"

Write-Host 'Promoting to test...'
if ($SkipSeed) {
    & "$projectRoot/scripts/promote-to-test.ps1"
} else {
    & "$projectRoot/scripts/promote-to-test.ps1" -SeedFromStage
}
