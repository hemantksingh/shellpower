$ErrorActionPreference = "Stop"

$source = (Get-Item -Path ".\iisconfig\src\" -Verbose).FullName
$currentDir = Split-Path $script:MyInvocation.MyCommand.Path

Write-Host "Importing from source $source"
. $source\iisconfig.ps1
. $currentDir\testutil.ps1

$_root = "$env:TEMP\shellpower" # This is ususally 'C:\inetpub'

function Setup-Website(
    [Parameter(mandatory=$true)][string] $siteName,
    [Parameter(mandatory=$true)][string] $webappName,
    [Parameter(mandatory=$true)][string] $username,
    [Parameter(mandatory=$true)][string] $password) {
   
    $appPoolName = $siteName
    $path = "$_root\$siteName"; Ensure-PathExists $path
    
    Create-AppPool -name $appPoolName
    Create-Website -name $siteName -port 80 -appPool $appPoolName -physicalPath $path
  
    $appPoolName = "{0}_{1}" -f $siteName, $webappName
    $path = "$_root\$webappName"; Ensure-PathExists $path
    Create-AppPoolWithIdentity -name $appPoolName -username $username -password $password
    Create-WebApplication `
        -name $webappName `
        -siteName $siteName `
        -appPool $webappName `
        -physicalPath $path
}

function Test-WebApplicationCanBeCreatedForValidWebSite {
    Setup-Website -siteName "shellpower" -webappName "api" -username "sample-user" -password "apassword"
    Setup-Website -siteName "shellpower" -webappName "api" -username "sample-user" -password "apassword"
}

function Test-WebApplicationCannotBeCreatedForInvalidWebSite  {
    $webappName = "api2"
    $siteName = "invalidsite"
    $path = "$_root\$webappName"; Ensure-PathExists $path
    try {
        Create-WebApplication `
            -name $webappName `
            -siteName $siteName `
            -appPool $webappName `
            -physicalPath $path
    } catch {
        AssertEqual "Failed to create web application 'api2', web site '$siteName' was not found" $_.Exception.Message
    }
}

function Test-VirtualDirectoryCanBeCreated {
    $virDir = "vir1"
    $siteName = "shellpower"
    $path = "$_root\$virDir"; Ensure-PathExists $path

    Create-WebVirtualDirectory `
            -name $virDir `
            -siteName $siteName `
            -physicalPath $path
}

Test-WebApplicationCanBeCreatedForValidWebSite
Test-WebApplicationCannotBeCreatedForInvalidWebSite
Test-VirtualDirectoryCanBeCreated