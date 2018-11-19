param (
  [Parameter(mandatory=$true)][string] $source,
  [Parameter(Mandatory = $true)][string] $dbServer,
  $dbName="testdb",
  [Parameter(Mandatory = $true)][string] $dbUser,
  [Parameter(Mandatory = $true)][string] $dbPassword
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

$userLogin = Create-Login $server $dbUser $dbPassword
Add-LoginToServerRole $server $userLogin.Name "dbcreator"

function Test-DbConfigurationCanBeRepeated {
    $db = Create-Db $server $dbName
    Configure-User $db $dbUser

    $db = Create-Db $server $dbName
    Configure-User $db $dbUser
}
                                                                                           