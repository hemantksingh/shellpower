$ErrorActionPreference = 'Stop';

$currentDir = Split-Path $script:MyInvocation.MyCommand.Path
. $currentDir\apppool.ps1
. $currentDir\certificate.ps1
. $currentDir\webbinding.ps1

function Create-Website (
    [Parameter(mandatory = $true)][string] $name,
    [Parameter(mandatory = $true)][int] $port,
    [Parameter(mandatory = $true)][string] $appPool,
    [Parameter(mandatory = $true)][string] $physicalPath,
    [string] $hostName,
    [string] $protocol = 'https',
    [string] $username,
    [string] $password) {

    Write-Host "Creating website '$name' with appPool '$appPool' on port '$port' and path '$physicalPath'"
    Create-AppPool -name $appPool -username $username -password $password
    
    New-Website `
        -Name $name `
        -Port $port  `
        -PhysicalPath $physicalPath `
        -ApplicationPool $appPool `
        -Force
    
    if ([string]::IsNullOrWhiteSpace($hostName)) { return }
    
    $webBinding = Add-WebBinding -siteName $name -port $port -protocol $protocol -hostName $hostName
    Add-InstalledCertificateToBinding $hostName $webBinding

    Write-Host "Starting website '$name' ..."
    Start-Website -Name $name
}
function Delete-Website(
    [Parameter(mandatory = $true)]
    [string] $name) {

    $exists = (Get-Website -Name $name).Name -eq $name

    if ($exists) {
        Write-Warning "Website '$name' already exists, deleting it"
        Remove-WebSite -Name $name
    }
    else {
        Write-Host "Website '$name' not found, nothing deleted"
    }
}


function Ensure-SiteExists([Parameter(mandatory = $true)][string] $siteName) {
  
    if ((Get-Website -Name $siteName).Name -ne $siteName) {
        $message = "Website '$siteName' was not found"
        throw [System.InvalidOperationException] $message
    }
}

function Parse-SitePath( 
    [Parameter(mandatory = $true)][string] $sitePath,
    [Parameter(mandatory = $true)][string] $webappName) {
    
    $siteParts = $sitePath.Split("/"); $site = $siteParts[0]; $virDir = $siteParts[1]
    if ($siteParts.Length -gt 0) {
        @{
            site   = $site
            webapp = "{0}/{1}" -f $virDir, $webappName
        }
    }
    else {
        @{
            site   = $sitePath
            webapp = $webappName
        }
    }
}