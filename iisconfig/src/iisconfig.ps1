$ErrorActionPreference = 'Stop';

Import-Module WebAdministration

$libSource = (Get-Item -Path ".\iisconfig\src\lib" -Verbose).FullName
. $libSource\apppool.ps1
. $libSource\website.ps1
. $libSource\webvirtualdir.ps1

function Create-WebApplication (
    [Parameter(mandatory = $true)][string] $name,
    [Parameter(mandatory = $true)][string] $siteName,
    [Parameter(mandatory = $true)][string] $appPool,
    [Parameter(mandatory = $true)][string] $physicalPath,
    [string] $username,
    [string] $password,
    [bool] $isNetCore = $true) {
      
    Write-Host "Creating web application '$name' for website '$siteName' with app pool '$appPool' and path '$physicalPath'"
    
    $result = Parse-SitePath $siteName $name
    Ensure-SiteExists $result.site
    Delete-WebApplication $result.webapp $result.site
    
    if ($isNetCore) { $runtimeVersion = "No Managed Code" } else { $runtimeVersion = "v4.0" }
    Create-AppPool -name $appPool `
        -username $username `
        -password $password `
        -runtimeVersion $runtimeVersion

    New-WebApplication `
        -Site $siteName `
        -Name $name `
        -PhysicalPath $physicalPath `
        -ApplicationPool $appPool `
        -Force
}


function Delete-WebApplication(  
    [Parameter(mandatory = $true)][string] $name,
    [Parameter(mandatory = $true)][string] $siteName) {

    if (Get-WebApplication -Name $name -Site $siteName) {
        Write-Warning "Web application '$name' already exists for website '$siteName', deleteing it"
        Remove-WebApplication -Name $name -Site $siteName
    }
    else {
        Write-Warning "Web application '$name' not found for website '$siteName', nothing deleted"
    }
}

function Add-WebApplicationToWebSite( 
    [Parameter(mandatory = $true)][string] $siteName,
    [string] $sitePath,
    [Parameter(mandatory = $true)][string] $webappName,
    [Parameter(mandatory = $true)][string] $webappPath,
    [string] $webappUsername,
    [string] $webappPassword,
    [bool] $isNetCore = $true) {

    $appPoolName = $siteName.Replace(' ', '')
    if (![string]::IsNullOrEmpty($sitePath)) {  
        Create-Website -name $siteName -port 80 -appPool $appPoolName -physicalPath $sitePath
    }
    else {
        Write-Host "Skipped creating website '$siteName'"
    }

    $appPoolName = "{0}_{1}" -f $siteName.Replace(' ', ''), $webappName.Replace(' ', '')
  
    Create-WebApplication -name $webappName `
        -siteName $siteName `
        -appPool $appPoolName `
        -physicalPath $webappPath `
        -username $webappUsername `
        -password $webappPassword `
        -isNetCore $isNetCore
}

function Add-WebApplicationToVirtualDirectory(
    [Parameter(mandatory = $true)][string] $siteName,
    [string] $sitePath,
    [Parameter(mandatory = $true)][string] $virDirName,
    [string] $virDirPath,
    [Parameter(mandatory = $true)][string] $webappName,
    [Parameter(mandatory = $true)][string] $webappPath,
    [string] $webappUsername,
    [string] $webappPassword,
    [bool] $isNetCore = $true) {
  
    $appPoolName = $siteName.Replace(' ', '')
    if (![string]::IsNullOrEmpty($sitePath)) {  
        Create-Website -name $siteName -port 80 -appPool $appPoolName -physicalPath $sitePath
    }
    else {
        Write-Host "Skipped creating website '$siteName'"
    }

    if (![string]::IsNullOrEmpty($virDirPath)) {
        Create-WebVirtualDirectory -name $virDirName `
            -siteName $siteName `
            -physicalPath $virDirPath
    }
    else {
        Write-Host "Skipped creating virtual directory '$virDirName'"
    }

    $appPoolName = "{0}_{1}_{2}" -f `
        $siteName.Replace(' ', ''), 
    $virDirName.Replace(' ', ''), 
    $webappName.Replace(' ', '')
  
    Create-WebApplication -name $webappName `
        -siteName "$siteName/$virDirName" `
        -appPool $appPoolName `
        -physicalPath $webappPath `
        -username $webappUsername `
        -password $webappPassword `
        -isNetCore $isNetCore
}