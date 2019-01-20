Import-Module WebAdministration

function Create-Website (
    [Parameter(mandatory=$true)][string] $name,
    [Parameter(mandatory=$true)][int] $port,
    [Parameter(mandatory=$true)][string] $appPool,
    [Parameter(mandatory=$true)][string] $physicalPath) {

    Write-Host "Creating website '$name'"
    Delete-Website $name

    New-Website `
      -Name $name `
      -Port $port  `
      -PhysicalPath $physicalPath `
      -ApplicationPool $appPool `
}

function Delete-Website(
    [Parameter(mandatory=$true)]
    [string] $name) {

  $exists = (Get-Website -Name $name).Name -eq $name

  if($exists) {
    Write-Warning "Website '$name' already exists, deleting it"
    Remove-WebSite -Name $name
  } else {
    Write-Host "Website '$name' not found, nothing deleted"
  }
}

function AppPool-Exists([Parameter(mandatory=$true)]
                        [string] $name) {
    return (Test-Path IIS:\AppPools\$name)
}

function Create-AppPool(
    [Parameter(mandatory=$true)][string] $name,
    [string] $runtimeVersion) {

    Write-Host "Creating new AppPool '$name'"
    if((AppPool-Exists $name)) {
        Write-Warning "AppPool '$name' already exists, removing it"
        Remove-WebAppPool $name
    }

    $appPool = New-WebAppPool "$name" -Force
    $appPool.processModel.identityType = "ApplicationPoolIdentity"
    $appPool | Set-Item

    if($runtimeVersion -eq "No Managed Code") {
      Write-Host "Updating runtime for AppPool '$name'"
      # Default runtime assigned is v4.0
      $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value ""
    }
    return $appPool
}

function Create-AppPoolWithIdentity(
    [Parameter(mandatory=$true)][string] $name,
    [Parameter(mandatory=$true)][string] $username,
    [Parameter(mandatory=$true)][string] $password,
    [string] $runtimeVersion) {

    Write-Host "Creating new AppPool '$name' with identity"
    $appPool = Create-AppPool $name $runtimeVersion
    $appPool.processModel.userName = $username
    $appPool.processModel.password = $password
    $appPool.processModel.identityType = "SpecificUser"
    $appPool | Set-Item
}

function Ensure-SiteExists([Parameter(mandatory=$true)][string] $siteName) {
  
  if((Get-Website -Name $siteName).Name -ne $siteName) {
    $message = "Failed to create web application '$name', web site '$siteName' was not found"
    throw [System.InvalidOperationException] $message
  }
}
function Create-WebApplication (
    [Parameter(mandatory=$true)][string] $name,
    [Parameter(mandatory=$true)][string] $siteName,
    [Parameter(mandatory=$true)][string] $appPool,
    [Parameter(mandatory=$true)][string] $physicalPath) {
      
    Write-Host "Creating web application '$name' for web site '$siteName' with app pool '$appPool' and path '$physicalPath'"

    $siteParts = $siteName.Split("\")
    if($siteParts.Length -gt 0) {
      Ensure-SiteExists $siteParts[0]
    } else {
      Ensure-SiteExists $siteName
    }

    New-WebApplication `
      -Site $siteName `
      -Name $name `
      -PhysicalPath $physicalPath `
      -ApplicationPool $appPool `
      -Force
}

function Create-WebVirtualDirectory (
    [Parameter(mandatory=$true)][string] $name,
    [Parameter(mandatory=$true)][string] $siteName,
    [Parameter(mandatory=$true)][string] $physicalPath) {

    Write-Host "Creating web vir dir '$name' for web site '$siteName' with path '$physicalPath'"
    New-WebVirtualDirectory `
      -Site $siteName `
      -Name $name `
      -PhysicalPath $physicalPath `
      -Force
}

function Add-WebApplicationToWebSite( 
    [Parameter(mandatory=$true)][string] $siteName,
    [string] $sitePath,
    [Parameter(mandatory=$true)][string] $webappName,
    [Parameter(mandatory=$true)][string] $webappPath,
    [string] $webappUsername,
    [string] $webappPassword) {

  $appPoolName = $siteName.Replace(' ', '')
  
  Create-AppPool -name $appPoolName
  Create-Website -name $siteName -port 80 -appPool $appPoolName -physicalPath $sitePath

  $appPoolName = "{0}_{1}" -f $siteName.Replace(' ', ''), $webappName.Replace(' ', '')

  if(![string]::IsNullOrEmpty($webappUsername) -and ![string]::IsNullOrEmpty($webappPassword)) {
    Create-AppPoolWithIdentity `
      -name $appPoolName `
      -username $webappUsername `
      -password $webappPassword
  } else {
    Create-AppPool -name $appPoolName
  }

  Create-WebApplication `
      -name $webappName `
      -siteName $siteName `
      -appPool $appPoolName `
      -physicalPath $webappPath
}
