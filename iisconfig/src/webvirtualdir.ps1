
function Create-WebVirtualDirectory (
    [Parameter(mandatory = $true)][string] $name,
    [Parameter(mandatory = $true)][string] $siteName,
    [Parameter(mandatory = $true)][string] $physicalPath) {

    Write-Host "Creating web vir dir '$name' for website '$siteName' with path '$physicalPath'"
    New-WebVirtualDirectory `
        -Site $siteName `
        -Name $name `
        -PhysicalPath $physicalPath `
        -Force
}