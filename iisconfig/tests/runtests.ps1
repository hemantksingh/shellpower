param (
  [string] $source = (Get-Item -Path ".\iisconfig\src" -Verbose).FullName
)

Get-ChildItem -Path '.\iisconfig\tests' -Filter test*.ps1 | 
Where-Object { $_.FullName -ne $PSCommandPath } | 
ForEach-Object {
    Write-Host "$([Environment]::NewLine)Running $($_.FullName)$([Environment]::NewLine)"
    . $_.FullName -source $source
}