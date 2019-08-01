$ErrorActionPreference = 'Stop';

$currentDir = Split-Path $script:MyInvocation.MyCommand.Path
. $currentDir\apppool.ps1
. $currentDir\certificate.ps1

function Create-Website (
    [Parameter(mandatory = $true)][string] $name,
    [Parameter(mandatory = $true)][int] $port,
    [Parameter(mandatory = $true)][string] $appPool,
    [Parameter(mandatory = $true)][string] $physicalPath,
    [string] $username,
    [string] $password,
    [string] $protocol = 'http',
    [string] $hostName = "$name.com",
    [string] $certificateThumbprint) {

    Write-Host "Creating website '$name' with appPool '$appPool' on port '$port' and path '$physicalPath'"
    Create-AppPool -name $appPool -username $username -password $password
    
    New-Website `
        -Name $name `
        -Port $port  `
        -PhysicalPath $physicalPath `
        -ApplicationPool $appPool `
        -Force
    
    Get-WebBinding -Name $name -Port $port | Remove-WebBinding
    Write-Host "Adding web binding '$name' with protocol '$protocol', port '$port' and host name '$hostName' "
    $webBinding = New-WebBinding -Name $name -IPAddress "*" -Port $port -Protocol $protocol -HostHeader $hostName
    Write-Host "Waiting for 2 seconds for the web binding to take effect"; Start-Sleep 2 
    # MS recommends waiting after adding a new web binding
    # https://docs.microsoft.com/en-us/powershell/module/webadminstration/remove-webbinding?view=winserver2012-ps

    if (![string]::IsNullOrWhiteSpace($certificateThumbrint)) {
        Add-InstalledCertificateToBinding $certificateThumbrint $webBinding
    }

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
            site    = $site
            webapp = "{0}/{1}" -f $virDir, $webappName
        }
    } else {
        @{
            site   = $sitePath
            webapp = $webappName
        }
    }
}