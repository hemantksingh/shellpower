param(
    [Parameter(Mandatory=$true)][string] $application,
    [Parameter(Mandatory=$true)][string] $version,
    [Parameter(Mandatory=$true)][string] $publishDir
)

$currentDir = $PSScriptRoot
$nuspec = "$currentDir\$application.nuspec"
$artifactDir = "$currentDir\bin"

$ErrorActionPreference = "Stop"

Write-Host "Copying contents $publishDir to $artifactDir"
Copy-Item $publishDir -Filter "*.ps1" -Destination $artifactDir -Recurse -Force

(Get-Content $nuspec) -replace "<version>.*</version>", "<version>$($version)</version>" | Set-Content $nuspec

nuget pack $nuspec -exclude "*.nupkg;*.nuspec;nugetpack.ps1"