$ErrorActionPreference = "Stop"

$source = (Get-Item -Path ".\iisconfig\src\" -Verbose).FullName
$currentDir = Split-Path $script:MyInvocation.MyCommand.Path

Write-Host "Importing from source $source"
. $source\iisconfig.ps1
. $currentDir\testutil.ps1

$_root = "$env:TEMP\shellpower" # This is ususally 'C:\inetpub'

function Test-WebApplicationCanBeCreatedForValidWebSite {
    $siteName = "shellpower1"
    $sitePath = "$_root\$siteName"; Ensure-PathExists $sitePath
    $webappPath = "$_root\$siteName\$webappName"; Ensure-PathExists $webappPath

    Add-WebApplicationToWebSite -siteName $siteName `
        -sitePath $sitePath `
        -webappName "api" `
        -webappPath $webappPath

    # Assert-Equal "api" (Get-WebApplication -Name "api" -Site "shellpower1").Name
}

function Test-WebApplicationWithIdentityCanBeCreatedForValidWebSite {
    $siteName = "shellpower1"
    $sitePath = "$_root\$siteName"; Ensure-PathExists $sitePath
    $webappPath = "$_root\$siteName\$webappName"; Ensure-PathExists $webappPath

    Add-WebApplicationToWebSite -siteName $siteName `
        -sitePath $sitePath `
        -webappName "api" `
        -webappPath $webappPath `
        -webappUsername "sample-user" `
        -webappPassword "apassword"

    Assert-Equal $siteName (Get-Website -Name $siteName).Name
}

function Test-WebApplicationCannotBeCreatedForInvalidWebSiteIfCreateWebsiteIsNotSpecified  {

    $siteName = "invalidsite"
    $sitePath = "$_root\$siteName"; Ensure-PathExists $sitePath
    $webappPath = "$_root\$siteName\$webappName"; Ensure-PathExists $webappPath
    try {
        Add-WebApplicationToWebSite -siteName $siteName `
            -webappName "api2" `
            -webappPath $webappPath
    } catch {
        Assert-Equal "Failed to create web application 'api2', web site '$siteName' was not found" $_.Exception.Message
    }
}

function Test-WebApplicationCanBeCreatedForValidVirtualDirectory {
    
    $siteName = "shellpower2"

    $appPoolName = $siteName
    $path = "$_root\$siteName"; Ensure-PathExists $path
    
    Create-AppPool -name $appPoolName
    Create-Website -name $siteName -port 80 -appPool $appPoolName -physicalPath $path

    $virDir = "vir"
    $path = "$_root\$virDir"; Ensure-PathExists $path
    Create-WebVirtualDirectory `
            -name $virDir `
            -siteName $siteName `
            -physicalPath $path

    $webappName = "api"            
    $appPoolName = "{0}_{1}_{2}" -f $siteName.Replace(' ', ''), $virDir, $webappName
    $path = "$_root\$virDir\$webappName"; Ensure-PathExists $path
    Create-AppPoolWithIdentity -name $appPoolName -username "sample-user" -password "apassword"
    Create-WebApplication `
        -name $webappName `
        -siteName "$siteName\$virDir" `
        -appPool $appPoolName `
        -physicalPath $path         

}

function Remove-Setup {
    Remove-Website -Name "shellpower1"; Remove-WebAppPool -Name "shellpower1"; 
    Remove-WebAppPool -Name "shellpower1_api"
    Remove-Website -Name "shellpower2"; Remove-WebAppPool -Name "shellpower2";
    Remove-WebAppPool -Name "shellpower2_vir_api"
    Remove-Item -Path $_root -Recurse -Force
}

# Remove-Setup
Test-WebApplicationCanBeCreatedForValidWebSite
Test-WebApplicationCannotBeCreatedForInvalidWebSiteIfCreateWebsiteIsNotSpecified
Test-WebApplicationCanBeCreatedForValidVirtualDirectory