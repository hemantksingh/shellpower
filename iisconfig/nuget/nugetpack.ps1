param(
    [Parameter(Mandatory=$true)][string] $application,
    [Parameter(Mandatory=$true)][string] $version,
    [Parameter(Mandatory=$true)][string] $publishDir,
    [Parameter(Mandatory=$true)][string] $gitCommit
)

$currentDir = $PSScriptRoot
$nuspec = "$currentDir\$application.nuspec"
$artifactDir = "$currentDir\bin"

$ErrorActionPreference = "Stop"

function Add-DirIfDoesNotExist( [Parameter(Mandatory = $true)][string] $dir) {
    if (!(test-path $dir)) {
        Write-Host "Creating dir '$dir'"
        New-Item -ItemType Directory -Force -Path $dir
    }
    else {
        Write-Host "Directory '$dir' already exists, removing its contents"
        Remove-Item -Path "$dir\*" -Recurse
    }
}

Add-DirIfDoesNotExist $artifactDir

Write-Host "Copying contents $publishDir to $artifactDir"
Copy-Item $publishDir\* -Destination $artifactDir -Recurse -Force

Write-Host "Updating '$nuspec' version to '$version' and git commit to '$gitCommit'"
(Get-Content $nuspec) `
    -replace "<version>.*</version>", "<version>$($version)</version>" `
    -replace 'commit=".*"', "commit=""$gitCommit""" |
    Set-Content $nuspec

nuget pack $nuspec -exclude "*.nupkg;*.nuspec;nugetpack.ps1"