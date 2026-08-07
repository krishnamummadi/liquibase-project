param()

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$server = 'localhost,1433'
$user = 'sa'
$pw = 'YourStrong!Passw0rd'
$db = 'liquibase_test'

function Run-Sql {
    param($Query)
    $raw = & sqlcmd -S $server -U $user -P $pw -d $db -Q $Query -b -h -1 -C 2>&1
    # Extract the first numeric-only line (sqlcmd adds spacing and rows affected)
    $numeric = $raw | Where-Object { $_ -match '^\s*\d+\s*$' } | Select-Object -First 1
    if ($numeric) { return $numeric.Trim() } else { return ($raw -join "`n") }
}

Write-Host "Validating test database schema and data..."

# Check tables exist
$tables = @(
    'dbo.Customers',
    'dbo.Orders'
)

foreach ($t in $tables) {
    $q = "IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = '$($t.Split('.')[1])') SELECT 1 ELSE SELECT 0"
    $res = Run-Sql $q
    if ($res -ne '1') {
        Write-Error "Table $t not found in liquibase_test"
        exit 2
    } else {
        Write-Host "Found table: $t"
    }
}

# Check row counts
$checks = @(
    @{Sql="SELECT COUNT(*) FROM liquibase_test.dbo.Customers"; Name='Customers'},
    @{Sql="SELECT COUNT(*) FROM liquibase_test.dbo.Orders"; Name='Orders'}
)

$allOk = $true
foreach ($c in $checks) {
    $count = Run-Sql $c.Sql
    if ([int]$count -gt 0) {
        Write-Host "$($c.Name): $count rows"
    } else {
        Write-Warning "$($c.Name) has 0 rows"
        $allOk = $false
    }
}

if ($allOk) {
    Write-Host "Validation passed: schema and data present in test."
    exit 0
} else {
    Write-Error "Validation found missing data."
    exit 3
}
