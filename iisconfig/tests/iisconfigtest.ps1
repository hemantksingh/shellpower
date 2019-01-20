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
    $webappName = "api"
    $sitePath = "$_root\$siteName"; Ensure-PathExists $sitePath
    $webappPath = "$_root\$siteName\$webappName"; Ensure-PathExists $webappPath
    try {
        Add-WebApplicationToWebSite -siteName $siteName `
            -webappName $webappName `
            -webappPath $webappPath
    } catch {
        Assert-Equal "Failed to create web application '$webappName', web site '$siteName' was not found" $_.Exception.Message
    }
}

function Test-WebApplicationCanBeCreatedForValidVirtualDirectory {
    
    $siteName = "shellpower2"
    $virDirName = "vir"
    $webappName = "api"
    $sitePath = "$_root\$siteName"; Ensure-PathExists $sitePath
    $virDirPath = "$_root\$siteName\$virDirName"; Ensure-PathExists $virDirPath
    $webappPath = "$_root\$siteName\$webappName"; Ensure-PathExists $webappPath

    Add-WebApplicationToVirtualDirectory -siteName $siteName `
        -sitePath $sitePath `
        -virDirName $virDirName `
        -virDirPath $virDirPath `
        -webappName $webappName `
        -webappPath $webappPath `
        -webappUsername "sample-user" `
        -webappPassword "apassword"
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