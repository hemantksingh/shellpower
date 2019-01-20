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
  
    $appPoolName = "{0}_{1}" -f $siteName.Replace(' ', ''), $webappName
    $path = "$_root\$webappName"; Ensure-PathExists $path
    Create-AppPoolWithIdentity -name $appPoolName -username $username -password $password
    Create-WebApplication `
        -name $webappName `
        -siteName $siteName `
        -appPool $appPoolName `
        -physicalPath $path
}

function Test-WebApplicationCanBeCreatedForValidWebSite {
    Setup-Website -siteName "shellpower1" -webappName "api" -username "sample-user" -password "apassword"
    Setup-Website -siteName "shellpower1" -webappName "api" -username "sample-user" -password "apassword"
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

Test-WebApplicationCanBeCreatedForValidWebSite
Test-WebApplicationCannotBeCreatedForInvalidWebSite
Test-WebApplicationCanBeCreatedForValidVirtualDirectory