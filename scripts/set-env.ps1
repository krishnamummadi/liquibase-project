param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('dev','test','stage')]
    [string]$Environment,

    [Parameter(Mandatory=$true)]
    [string]$Server,

    [Parameter(Mandatory=$true)]
    [string]$Database,

    [string]$Username = 'sa',
    [string]$Password = 'YourStrong!Passw0rd'
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $projectRoot "config/$Environment.properties"

if (-not (Test-Path $configPath)) {
    throw "Configuration file not found: $configPath"
}

$content = Get-Content $configPath -Raw
$content = $content -replace 'url=.*', "url=jdbc:sqlserver://$Server;databaseName=$Database;encrypt=true;trustServerCertificate=true"
$content = $content -replace 'username=.*', "username=$Username"
$content = $content -replace 'password=.*', "password=$Password"

Set-Content -Path $configPath -Value $content -NoNewline
Write-Host "Updated $configPath"
Write-Host "Server=$Server Database=$Database"
