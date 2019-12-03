param (
  [string] $hostFile = 'C:\Windows\System32\drivers\etc\hosts'
)

Write-Host "Using host file '$hostFile'"
function Add-HostMapping(
    [Parameter(mandatory = $true)][string]$ip, 
    [Parameter(mandatory = $true)][string]$hostname) {
    
    Remove-HostMapping $hostname
    $ip + "`t`t" + $hostname | Out-File -encoding ASCII -append $hostFile
}

function Remove-HostMapping([Parameter(mandatory = $true)][string]$hostname) {
    $content = Get-Content $hostFile
    $existingLines = @()

    foreach ($line in $content) {
        $bits = [regex]::Split($line, "\t+")
        if ($bits.count -eq 2) {
            if ($bits[1] -ne $hostname) {
                $existingLines += $line
            }
        }
        else {
            $existingLines += $line
        }
    }

    # Write file
    Clear-Content $hostFile
    foreach ($line in $existingLines) {
        $line | Out-File -encoding ASCII -append $hostFile
    }
}

function Get-HostMapping([Parameter(mandatory = $true)][string]$hostname) {
    $content = Get-Content $hostFile
    $mappings = @()

    foreach ($line in $content) {
        $bits = [regex]::Split($line, "\t+")
        if ($bits.count -eq 2 -and ($bits[1] -eq $hostname)) {
            Write-Host "Host mapping found for '$($bits[1])'"
            $mappings +=  @{
                ip = $bits[0]
                host = $bits[1]
            }
        }
    }
    return $mappings
}

function Print-Hosts() {
    $content = Get-Content $hostFile

    foreach ($line in $content) {
        $bits = [regex]::Split($line, "\t+")
        if ($bits.count -eq 2) {
            Write-Host $bits[0] `t`t $bits[1]
        }
    }
}