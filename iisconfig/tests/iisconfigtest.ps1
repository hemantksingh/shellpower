$ErrorActionPreference = "Stop"

$source = (Get-Item -Path ".\iisconfig\src\" -Verbose).FullName
$currentDir = Split-Path $script:MyInvocation.MyCommand.Path

Write-Host "Importing from source $source"
. $source\iisconfig.ps1
. $currentDir\testutil.ps1

$_root = "C:\inetpub"

function Setup-Website(
    [Parameter(mandatory=$true)][string] $siteName,
    [Parameter(mandatory=$true)][string] $webappName,
    [Parameter(mandatory=$true)][string] $username,
    [Parameter(mandatory=$true)][string] $password) {
   
    $appPoolName = $siteName
    Create-AppPool -name $appPoolName
    Create-Website -name $siteName -port 80 -appPool $appPoolName -physicalPath "$_root\$siteName"
  
    $appPoolName = "{0}_{1}" -f $siteName, $webappName
    Create-AppPoolWithIdentity -name $appPoolName -username $username -password $password
    Create-WebApplication `
        -name $webappName `
        -siteName $siteName `
        -appPool $webappName `
        -physicalPath "$_root\$webappName"
}

function Test-WebApplicationCanBeCreatedForValidWebSite {
    Setup-Website -siteName "shellpower" -webappName "api" -username "sample-user" -password "apassword"
    Setup-Website -siteName "shellpower" -webappName "api" -username "sample-user" -password "apassword"
}

function Test-WebApplicationCannotBeCreatedForInvalidWebSite  {
    $webappName = "api2"
    $siteName = "invalidsite"
    try {
        Create-WebApplication `
            -name $webappName `
            -siteName $siteName `
            -appPool $webappName `
            -physicalPath "$_root\$webappName"
    } catch {
        AssertEqual "Failed to create web application 'api2', web site '$siteName' was not found" $_.Exception.Message
    }
}

Test-WebApplicationCanBeCreatedForValidWebSite
Test-WebApplicationCannotBeCreatedForInvalidWebSite