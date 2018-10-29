param(
    [Parameter(Mandatory=$true)][string] $application,
    [Parameter(Mandatory=$true)][string] $version,
    [Parameter(Mandatory=$true)][string] $publishDir
)

$currentDir = $PSScriptRoot
$nuspec = "$currentDir\$application.nuspec"
$artifactDir = "$currentDir\lib"

$ErrorActionPreference = "Stop"

if (Test-Path $artifactDir) {
    Write-Host "Removing '$artifactDir'"
    Remove-item  -Path $artifactDir -Recurse -ErrorAction SilentlyContinue
}else {
    Write-Host "Creating '$artifactDir'"
    New-Item -ItemType Directory -Force -Path $artifactDir
}

Copy-Item $publishDir\*.ps1 $artifactDir

(Get-Content $nuspec) -replace "<version>.*</version>", "<version>$($version)</version>" | Set-Content $nuspec

nuget pack $nuspec -exclude "*.nupkg" -exclude "*.nuspec"