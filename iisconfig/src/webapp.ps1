Import-Module WebAdministration

function Delete-App([Parameter(mandatory=$true)]
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

function Create-App (
        [Parameter(mandatory=$true)]
        [string] $name,
        [Parameter(mandatory=$true)]
        [int] $port,
        [Parameter(mandatory=$true)]
        [string] $appPool,
        [Parameter(mandatory=$true)]
        [string] $physicalPath,
        [bool] $deleteDefaultSite=$false ) {

      if($deleteDefaultSite) {
        Delete-App 'Default Web Site'
      }

      Write-Host "Checking path '$physicalPath'"
      if(-Not (Test-Path -Path $physicalPath)) {
        Write-Warning "'$physicalPath' does not exist. Creating it"
        md -Force $physicalPath
      }

      Delete-App $name

      New-Website `
        -Name $name `
        -Port $port  `
        -PhysicalPath $physicalPath `
        -ApplicationPool $appPool `
}

function Create-VirtualApp (
        [Parameter(mandatory=$true)]
        [string] $name,
        [Parameter(mandatory=$true)]
        [string] $siteName,
        [Parameter(mandatory=$true)]
        [string] $appPool,
        [Parameter(mandatory=$true)]
        [string] $physicalPath) {

      if(-Not (Test-Path $physicalPath)) {
        Write-Warning "'$physicalPath' does not exist. Creating it"
        md -Force $physicalPath
      }

      New-WebApplication `
        -Site $siteName `
        -Name $name `
        -PhysicalPath $physicalPath `
        -ApplicationPool $appPool `
        -Force
}
