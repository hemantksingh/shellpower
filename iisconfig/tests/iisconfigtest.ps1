$ErrorActionPreference = "Stop"

$source = (Get-Item -Path ".\iisconfig\src\" -Verbose).FullName
$currentDir = Split-Path $script:MyInvocation.MyCommand.Path

Write-Host "Importing from source $source"
. $source\iisconfig.ps1
. $currentDir\testutil.ps1

function Setup-Website(
    [Parameter(mandatory=$true)][string] $username,
    [Parameter(mandatory=$true)][string] $password) {

    $root = "C:\inetpub"
    $shellpowerSite = "shellpower"
    $shellpowerApi = "api"
    
    $appPoolName = $shellpowerSite
    Create-AppPool -name $appPoolName
    Create-Website -name $shellpowerSite -port 80 -appPool $appPoolName -physicalPath "$root\$shellpowerSite"
  
    $appPoolName = "{0}_{1}" -f $shellpowerSite, $shellpowerApi
    Create-AppPoolWithIdentity -name $appPoolName -username $username -password $password
    Create-WebApplication -name $shellpowerApi -siteName $shellpowerSite -appPool $appPoolName -physicalPath "$root\$shellpowerApi"
}

function Test-WebApplicationCanBeCreatedForValidWebSite {
    Setup-Website -username "sample-user" -password "apassword"
    Setup-Website -username "sample-user" -password "apassword"    
}

function Test-WebApplicationCannotBeCreatedForInvalidWebSite  {
    $root = "C:\inetpub"
    $shellpowerApi = "api2"
    try {
        Create-WebApplication -name $shellpowerApi `
            -siteName "invalidwebsitte" `
            -appPool $shellpowerApi `
            -physicalPath "$root\$shellpowerApi"
    } catch {
        AssertEqual "Failed to create web application 'api2', web site 'invalidwebsitte' was not found" $_.Exception.Message
    }
}

Test-WebApplicationCanBeCreatedForValidWebSite
Test-WebApplicationCannotBeCreatedForInvalidWebSite