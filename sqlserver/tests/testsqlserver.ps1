param (
  [Parameter(mandatory=$true)][string] $source,
  [Parameter(Mandatory = $true)][string] $dbServer,
  $dbName="testdb"
)

$ErrorActionPreference = "Stop"

$source = (Get-Item -Path $source -Verbose).FullName

Write-Host "Importing from source $source"
. $source/sqlserver.ps1

function Configure-User(                                                                   
    [Parameter(mandatory = $true)][Microsoft.SqlServer.Management.Smo.Database]$database,  
    [Parameter(mandatory = $true)][string] $dbUser) {                                      
                                                                                           
    Add-UserToDb $database $dbUser                                                         
    Add-UserToDbRole $database $dbUser "db_datareader"                                     
    Add-UserToDbRole $database $dbUser "db_datawriter"                                     
    Add-UserToDbRole $database $dbUser "db_ddladmin"                                       
    Add-UserToDbRole $database $dbUser "db_owner"                                          
}                                                                                          
                                                                                           
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
$server = new-object Microsoft.SqlServer.Management.Smo.Server($dbServer)

function Test-DbConfigurationCanBeRepeated {
    $userLogin = Create-Login $server "test-user" "test-passw0rd!"
    Add-LoginToServerRole $server $userLogin.Name "dbcreator"

    $db = Create-Db $server $dbName
    Configure-User $db $dbUser

    $db = Create-Db $server $dbName
    Configure-User $db $dbUser
}

Test-DbConfigurationCanBeRepeated
                                                                                           