param (
  [Parameter(mandatory=$true)][string] $source,
  [Parameter(Mandatory = $true)][string] $dbServer,
  $dbName="testdb"
)

$ErrorActionPreference = "Stop"

$source = (Get-Item -Path $source -Verbose).FullName

Write-Host "Importing from source $source"
. $source/sqlserver.ps1

function Test-SqlUserCanBeConfiguredWithRoles {
    $user = Create-SqlUser "bar" "test-passw0rd!" `
        -serverRoles @("dbcreator", "bulkadmin", "sysadmin") `
        -dbRoles @("db_datareader", "db_datawriter", "db_ddladmin", "db_owner")
  
    Add-SqlUser $dbServer -dbName "foo" $user
    Add-SqlUser $dbServer -dbName "foo" $user
}

function Test-SqlUserCanBeRemoved {
    Add-SqlUser $dbServer -dbName "foo" (Create-SqlUser "pod" "test-passw0rd!")
    Remove-SqlUser $dbServer -dbName "foo" -sqlUser "pod"
}

Test-SqlUserCanBeConfiguredWithRoles
Test-SqlUserCanBeRemoved