param (
  [Parameter(Mandatory = $true)][string] $dbServer,
  [string]$dbName="foo",
  [string]$useTrustedConnection="true"
)

$ErrorActionPreference = "Stop"
$_useTrustedConnection = [System.Convert]::ToBoolean($useTrustedConnection)

$source = (Get-Item -Path ".\sqlserver\src\" -Verbose).FullName

Write-Host "Importing from source $source"
. $source\sqlserver.ps1 -dbServer $dbServer -dbName $dbName
. $source\sqlcmd.ps1 -dbServer $dbServer -dbName $dbName

$dbUser="hero"
$dbPassword="Passw0rd1"

function Test-InlineSqlQueryWithDbCreds {
  Add-DbUser $dbUser $dbPassword
  Invoke-InlineSql "SELECT name FROM master.dbo.sysdatabases" `
    -dbUser $dbUser `
    -dbPassword $dbPassword

  Remove-DbUser $dbUser
}

function Test-InlineSqlQueryWithTrustedConnection {
  Invoke-InlineSql "SELECT name FROM master.dbo.sysdatabases"
}

if($_useTrustedConnection) {
  Test-InlineSqlQueryWithTrustedConnection
} 

Test-InlineSqlQueryWithDbCreds
