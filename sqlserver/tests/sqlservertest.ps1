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
    [Parameter(mandatory=$true)][PSObject]$sqlUser) {
    
    [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
    $server = new-object Microsoft.SqlServer.Management.Smo.Server($dbServer)
    
    $userLogin = Create-Login $server $sqlUser.name $sqlUser.password
    Add-LoginToServerRoles $server $userLogin.Name $sqlUser.serverRoles

    $db = Create-Db $server $dbName
    Add-UserToDb $db $sqlUser.name
    Add-UserToDbRoles $db $sqlUser.name $sqlUser.dbRoles
}

function Create-SqlUser (
    [Parameter(mandatory=$true)][string] $name,
    [Parameter(mandatory=$true)][string] $password,
    [System.Array] $serverRoles,
    [System.Array] $dbRoles) {
    
    if(!$serverRoles) { 
        Write-Host "No server role(s) specified" 
        $serverRoles = @("dbcreator")
    }
    if(!$dbRoles) { 
        Write-Host "No db role(s) specified" 
        $dbRoles = @("db_datareader")
    }

    $sqlUser = New-Object -TypeName PSObject
    $sqlUser | Add-Member -Name 'name' -MemberType Noteproperty -Value $name
    $sqlUser | Add-Member -Name 'password' -MemberType Noteproperty -Value $password
    $sqlUser | Add-Member -Name 'serverRoles' -MemberType Noteproperty -Value $serverRoles
    $sqlUser | Add-Member -Name 'dbRoles' -MemberType Noteproperty -Value $dbRoles
    
    return $sqlUser
}

function Test-SqlUserCanBeConfiguredWithRoles {
    $user = Create-SqlUser "bar" "test-passw0rd!" `
        -serverRoles @("dbcreator", "bulkadmin", "sysadmin") `
        -dbRoles @("db_datareader", "db_datawriter", "db_ddladmin", "db_owner")
  
    Configure-SqlUser $dbServer -dbName "foo" $user
    Configure-SqlUser $dbServer -dbName "foo" $user
}

function Test-SqlUserCanBeConfiguredWithoutSpecifyingRoles {
    $user = Create-SqlUser "pod" "test-passw0rd!"
    Configure-SqlUser $dbServer -dbName "foo" $user
}

Test-SqlUserCanBeConfiguredWithRoles
Test-SqlUserCanBeConfiguredWithoutSpecifyingRoles