param (
  [Parameter(mandatory=$true)][string] $packages
)

$ErrorActionPreference = "Stop"

. $packages/lib/webapp.ps1

Write-Host "Imported"
