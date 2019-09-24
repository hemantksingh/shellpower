param (
  [Parameter(Mandatory = $true)][string] $dbServer,
  [string]$dbName="foo",
  [string]$useTrustedConnection="true",
  [string] $source = (Get-Item -Path ".\sqlserver\src\" -Verbose).FullName
)

$ErrorActionPreference = "Stop"
$_useTrustedConnection = [System.Convert]::ToBoolean($useTrustedConnection)

Write-Host "Importing from source $source"
. $source\sqlserver.ps1 -dbServer $dbServer -dbName $dbName
. $source\sqlcmd.ps1 -dbServer $dbServer

$dbUser="hero"
$dbPassword="Passw0rd1"

function Test-InlineSqlQueryWithDbCreds {
  Add-DbUser $dbUser $dbPassword
  Invoke-InlineSql "USE [$dbName] SELECT name FROM master.dbo.sysdatabases" `
    -dbUser $dbUser `
    -dbPassword $dbPassword

  Remove-DbUser $dbUser
}

function Test-InlineSqlQueryWithTrustedConnection {
  Invoke-InlineSql "USE [$dbName] SELECT name FROM master.dbo.sysdatabases"
}

if($_useTrustedConnection) {
  Test-InlineSqlQueryWithTrustedConnection
} 

Test-InlineSqlQueryWithDbCreds
