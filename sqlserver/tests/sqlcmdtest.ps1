param (
  [Parameter(Mandatory = $true)][string] $dbServer,
  [string]$dbName
)

$ErrorActionPreference = "Stop"

$source = (Get-Item -Path ".\sqlserver\src\" -Verbose).FullName

Write-Host "Importing from source $source"
. $source\sqlcmd.ps1 -dbServer $dbServer -dbName $dbName

Invoke-InlineSql "SELECT name FROM master.dbo.sysdatabases"

