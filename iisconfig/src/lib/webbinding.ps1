function Add-WebBinding ( 
    [Parameter(mandatory = $true)][string] $siteName,
    [Parameter(mandatory = $true)][string] $port,
    [Parameter(mandatory = $true)][string] $protocol,
    [Parameter(mandatory = $true)][string] $hostName,
    [string] $ipAddress = '*') {
    
    Get-WebBinding -Name $siteName -Port $port | Remove-WebBinding
    Write-Host "Adding web binding to site '$siteName' with protocol '$protocol', port '$port' and host name '$hostName' "
    New-WebBinding -Name $siteName -IPAddress "*" -Port $port -Protocol $protocol -HostHeader $hostName
    Write-Host "Waiting for 2 seconds for the web binding to take effect"; Start-Sleep 2 
    # MS recommends waiting after adding a new web binding
    # https://docs.microsoft.com/en-us/powershell/module/webadminstration/remove-webbinding?view=winserver2012-ps

    return (Get-WebBinding -Name $siteName -Port $port)
}