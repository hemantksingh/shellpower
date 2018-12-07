param (
  [Parameter(mandatory=$true)][string] $source,
  [Parameter(Mandatory = $true)][string] $dbServer,
  $dbName="testdb"
)

$ErrorActionPreference = "Stop"

$source = (Get-Item -Path $source -Verbose).FullName

Write-Host "Importing from source $source"
. $source/sqlserver.ps1

function Configure-SqlUser (
    [Parameter(mandatory=$true)][string] $dbServer,
    [Parameter(mandatory=$true)][string] $dbName,
    [Parameter(mandatory=$true)][string] $dbUser,
    [Parameter(Mandatory=$true)][System.Array] $serverRoles,
    [Parameter(Mandatory=$true)][System.Array] $dbRoles) {
    
    [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
    $server = new-object Microsoft.SqlServer.Management.Smo.Server($dbServer)
    
    $userLogin = Create-Login $server $dbUser "test-passw0rd!"
    Add-LoginToServerRoles $server $userLogin.Name $serverRoles

    $db = Create-Db $server $dbName
    Add-UserToDb $db $dbUser                                                         
    Add-UserToDbRoles $db $dbUser $dbRoles
}

function Test-DbConfigurationCanBeRepeated {
    Configure-SqlUser $dbServer "foo" "bar" `
        -serverRoles @("dbcreator", "bulkadmin", "sysadmin") `
        -dbRoles @("db_datareader", "db_datawriter")
    
    Configure-SqlUser $dbServer "foo" "bar" `
        -serverRoles @("dbcreator", "bulkadmin", "sysadmin") `
        -dbRoles @("db_ddladmin", "db_owner")
}

Test-DbConfigurationCanBeRepeated