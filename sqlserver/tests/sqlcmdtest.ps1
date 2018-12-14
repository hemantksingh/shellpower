param (
  [Parameter(Mandatory = $true)][string] $dbServer,
  [string]$dbName="foo"
)

$ErrorActionPreference = "Stop"

$source = (Get-Item -Path ".\sqlserver\src\" -Verbose).FullName

Write-Host "Importing from source $source"
. $source\sqlserver.ps1 -dbServer $dbServer -dbName $dbName
. $source\sqlcmd.ps1 -dbServer $dbServer -dbName $dbName

$dbUser="hero"
$dbPassword="Passw0rd1"

Add-DbUser $dbUser $dbPassword
Invoke-InlineSql "SELECT name FROM master.dbo.sysdatabases" -dbUser $dbUser -dbPassword $dbPassword
Remove-DbUser $dbUser

