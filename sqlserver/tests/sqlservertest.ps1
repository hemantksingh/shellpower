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
    
    Add-DbUser -name "bar" -password "test-passw0rd!" `
        -serverRoles @("dbcreator", "bulkadmin", "sysadmin") `
        -dbRoles @("db_datareader", "db_datawriter", "db_ddladmin", "db_owner")
}

function Test-SqlUserCanBeRemoved {
    Add-DbUser "lol" "test-passw0rd!"
    Remove-DbUser "lol"
}

function Test-WindowsUserCanBeAddedWithRoles {
    Add-DbUser -name "example\win-user" `
        -serverRoles @("dbcreator", "bulkadmin", "sysadmin") `
        -dbRoles @("db_datareader", "db_datawriter", "db_ddladmin", "db_owner")
}

function Test-WindowsUserCanBeRemoved {
    Add-DbUser "example\win-user"
    Remove-DbUser "example\win-user"
}

# Test-WindowsUserCanBeAddedWithRoles
# Test-WindowsUserCanBeRemoved
Test-SqlUserCanBeConfiguredWithRoles
Test-SqlUserCanBeRemoved
