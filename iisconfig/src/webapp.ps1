Import-Module WebAdministration

function Delete-Website([Parameter(mandatory=$true)]
                    [string] $name) {

  $exists = (Get-Website -Name $name).Name -eq $name

  if($exists) {
    Write-Warning "App '$name' exists, removing it"
    Remove-WebSite -Name $name
  } else {
    Write-Warning "'$name' not found, nothing deleted"
  }
}

function AppPool-Exists([Parameter(mandatory=$true)]
                        [string] $name) {
    return (Test-Path IIS:\AppPools\$name)
}

function Create-AppPool([Parameter(mandatory=$true)]
                        [string] $name,
                        [string] $runtimeVersion) {

  if((AppPool-Exists $name)) {
      Write-Warning "AppPool '$name' already exists, removing it"
      Remove-WebAppPool $name
  }
  Write-Host "Creating new AppPool '$name'"
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

function Create-AppPoolWithIdentity([Parameter(mandatory=$true)]
                                    [string] $name,
                                    [Parameter(mandatory=$true)]
                                    [string] $username,
                                    [Parameter(mandatory=$true)]
                                    [string] $password,
                                    [string] $runtimeVersion) {

      $appPool = Create-AppPool $name $runtimeVersion
      if( -not $appPool) {
        return
      }
      $appPool.processModel.userName = $username
      $appPool.processModel.password = $password
      $appPool.processModel.identityType = "SpecificUser"
      $appPool | Set-Item
}

function Create-Website (
        [Parameter(mandatory=$true)]
        [string] $name,
        [Parameter(mandatory=$true)]
        [int] $port,
        [Parameter(mandatory=$true)]
        [string] $appPool,
        [Parameter(mandatory=$true)]
        [string] $physicalPath) {

    Ensure-PathExists $physicalPath
    Delete-Website $name

    New-Website `
      -Name $name `
      -Port $port  `
      -PhysicalPath $physicalPath `
      -ApplicationPool $appPool `
}

function Ensure-PathExists([Parameter(mandatory=$true)][string] $path) {  
  if(-Not (Test-Path $path)) {
    Write-Warning "'$path' does not exist. Creating it"
    mkdir -Force $path
  }
}

function Create-WebApplication (
        [Parameter(mandatory=$true)]
        [string] $name,
        [Parameter(mandatory=$true)]
        [string] $siteName,
        [Parameter(mandatory=$true)]
        [string] $appPool,
        [Parameter(mandatory=$true)]
        [string] $physicalPath) {
      
      Write-Host "Creating virtial app '$name'"

      Ensure-PathExists $physicalPath

      New-WebApplication `
        -Site $siteName `
        -Name $name `
        -PhysicalPath $physicalPath `
        -ApplicationPool $appPool `
        -Force
}
