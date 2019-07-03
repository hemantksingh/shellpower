function AppPool-Exists([Parameter(mandatory=$true)]
                        [string] $name) {
    return (Test-Path IIS:\AppPools\$name)
}

function Create-AppPool(
    [Parameter(mandatory=$true)][string] $name,
    [string] $username,
    [string] $password,
    [string] $runtimeVersion="v4.0") {

    Write-Host "Creating new AppPool '$name'"
    if((AppPool-Exists $name)) {
        Write-Warning "AppPool '$name' already exists, deleting it"
        Remove-WebAppPool $name
    }

    $appPool = New-WebAppPool "$name" -Force
    if(![string]::IsNullOrEmpty($username) -and ![string]::IsNullOrEmpty($password)) {
      Write-Host "Adding user identity to AppPool '$name'"
      $appPool.processModel.userName = $username
      $appPool.processModel.password = $password
      $appPool.processModel.identityType = "SpecificUser"
      $appPool | Set-Item
    } else {
      Write-Host "Adding application identity to AppPool '$name'"
      $appPool.processModel.identityType = "ApplicationPoolIdentity"
      $appPool | Set-Item
    }
    
    if($runtimeVersion -eq "No Managed Code") {
      Write-Host "Updating runtime for AppPool '$name'"
      # Default runtime assigned is v4.0
      $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value ""
    }
}
