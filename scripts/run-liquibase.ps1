param(
    [Parameter(Mandatory=$true)]
    [string]$ConfigFile,
    [string]$Contexts = ""
)

$ErrorActionPreference = "Stop"

$javaHome = $env:JAVA_HOME
if (-not $javaHome -or -not (Test-Path (Join-Path $javaHome 'bin\java.exe'))) {
    $javaHome = 'C:\jdk17\jdk-17.0.20+8'
}
$javaExe = Join-Path $javaHome 'bin\java.exe'
if (-not (Test-Path $javaExe)) {
    throw "Java 17 runtime not found. Set JAVA_HOME to a valid JDK 17 installation."
}
$env:JAVA_HOME = $javaHome
$env:Path = "$($javaExe | Split-Path -Parent);$env:Path"

$liquibase = Get-Command liquibase -ErrorAction SilentlyContinue
if (-not $liquibase) {
    throw "Liquibase CLI is not installed or not available on PATH."
}

$cmd = @('update','--defaultsFile', $ConfigFile)
if ($Contexts) {
    $cmd += @('--contexts', $Contexts)
}

& liquibase @cmd
