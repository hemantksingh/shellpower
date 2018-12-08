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
    $user = Create-DbUser "bar" "test-passw0rd!" `
            -serverRoles @("dbcreator", "bulkadmin", "sysadmin") `
            -dbRoles @("db_datareader", "db_datawriter", "db_ddladmin", "db_owner")
  
    Add-DbUser -dbUser $user
    Add-DbUser -dbUser $user
}

function Test-SqlUserCanBeRemoved {
    Add-DbUser -dbUser (Create-DbUser "lol" "test-passw0rd!")
    Remove-DbUser -dbUser "lol"
}

function Test-WindowsUserCanBeAddedWithRoles {
    $user = Create-DbUser `
            -name "example\win-user" `
            -serverRoles @("dbcreator", "bulkadmin", "sysadmin") `
            -dbRoles @("db_datareader", "db_datawriter", "db_ddladmin", "db_owner")
  
    Add-DbUser -dbUser $user
}

function Test-WindowsUserCanBeRemoved {
    Add-DbUser -dbUser (Create-DbUser "example\win-user")
    Remove-DbUser -dbUser "example\win-user"
}

# Test-WindowsUserCanBeAddedWithRoles
# Test-WindowsUserCanBeRemoved
Test-SqlUserCanBeConfiguredWithRoles
Test-SqlUserCanBeRemoved
