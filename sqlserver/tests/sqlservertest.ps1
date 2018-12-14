param (
  [Parameter(Mandatory = $true)][string] $dbServer,
  [string]$dbName="foo",
  [string]$winUser
)

$ErrorActionPreference = "Stop"

$source = (Get-Item -Path ".\sqlserver\src\" -Verbose).FullName

Write-Host "Importing from source $source"
. $source\sqlserver.ps1 -dbServer $dbServer -dbName $dbName

function Test-SqlUserCanBeConfiguredWithRoles {
    
    Add-DbUser -name "bar" -password "test-passw0rd!" `
        -serverRoles @("dbcreator", "bulkadmin", "sysadmin") `
        -dbRoles @("db_datareader", "db_datawriter", "db_ddladmin", "db_owner")
}

function Test-SqlUserCanBeRemoved {
    Add-DbUser "lol" "test-passw0rd!"
    Remove-DbUser "lol"
}

function Test-WindowsUserCanBeAddedWithRoles (
    [Parameter(Mandatory = $true)][string] $winUser) {
    
    Add-DbUser -name $winUser `
        -serverRoles @("dbcreator", "bulkadmin", "sysadmin") `
        -dbRoles @("db_datareader", "db_datawriter", "db_ddladmin", "db_owner")
}

function Test-WindowsUserCanBeRemoved {
    Add-DbUser $winUser
    Remove-DbUser $winUser
}

if(![string]::IsNullOrEmpty($winUser)) {
    Test-WindowsUserCanBeAddedWithRoles $winUser
    Test-WindowsUserCanBeRemoved $winUser
}

Test-SqlUserCanBeConfiguredWithRoles
Test-SqlUserCanBeRemoved
