param (
  [Parameter(mandatory=$true)][string] $source,
  [Parameter(Mandatory = $true)][string] $dbServer,
  $dbName="testdb"
)

$ErrorActionPreference = "Stop"

$source = (Get-Item -Path $source -Verbose).FullName

Write-Host "Importing from source $source"
. $source/sqlserver.ps1

function Configure-User (
    [Parameter(mandatory=$true)][string] $dbServer,
    [Parameter(mandatory=$true)][string] $dbName,
    [Parameter(mandatory=$true)][string] $dbUser,
    [Parameter(Mandatory = $true)][System.Array] $dbRoles) {
    
    [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
    $server = new-object Microsoft.SqlServer.Management.Smo.Server($dbServer)
    
    $userLogin = Create-Login $server $dbUser "test-passw0rd!"
    Add-LoginToServerRole $server $userLogin.Name "dbcreator"

    $db = Create-Db $server $dbName
    Add-UserToDb $db $dbUser                                                         
    Add-UserToDbRoles $db $dbUser $dbRoles
}

function Test-DbConfigurationCanBeRepeated {
    Configure-User $dbServer "foo" "bar" @("db_datareader", "db_datawriter")
    Configure-User $dbServer "foo" "bar" @("db_ddladmin", "db_owner")
}

Test-DbConfigurationCanBeRepeated