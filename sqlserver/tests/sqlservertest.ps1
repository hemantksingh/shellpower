param (
  [Parameter(mandatory=$true)][string] $source,
  [Parameter(Mandatory = $true)][string] $dbServer,
  $dbName="foo"
)

$ErrorActionPreference = "Stop"

$source = (Get-Item -Path $source -Verbose).FullName

Write-Host "Importing from source $source"
. $source\sqlserver.ps1 -dbServer $dbServer -dbName $dbName

function Test-SqlUserCanBeConfiguredWithRoles {
    $user = Create-SqlUser "bar" "test-passw0rd!" `
        -serverRoles @("dbcreator", "bulkadmin", "sysadmin") `
        -dbRoles @("db_datareader", "db_datawriter", "db_ddladmin", "db_owner")
  
    Add-SqlUser -sqlUser $user
    Add-SqlUser -sqlUser $user
}

function Test-SqlUserCanBeRemoved {
    Add-SqlUser -sqlUser (Create-SqlUser "lol" "test-passw0rd!")
    Remove-SqlUser -sqlUser "lol"
}

Test-SqlUserCanBeConfiguredWithRoles
Test-SqlUserCanBeRemoved