$_fileName = 'C:\Windows\System32\drivers\etc\hosts'
function Add-HostMapping(
    [Parameter(mandatory = $true)][string]$ip, 
    [Parameter(mandatory = $true)][string]$hostname) {
    
    Remove-HostMapping $hostname
    $ip + "`t`t" + $hostname | Out-File -encoding ASCII -append $_fileName
}

function Remove-HostMapping([Parameter(mandatory = $true)][string]$hostname) {
    $content = Get-Content $_fileName
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
    Clear-Content $_fileName
    foreach ($line in $existingLines) {
        $line | Out-File -encoding ASCII -append $_fileName
    }
}

function Print-Hosts() {
    $content = Get-Content $_fileName

    foreach ($line in $content) {
        $bits = [regex]::Split($line, "\t+")
        if ($bits.count -eq 2) {
            Write-Host $bits[0] `t`t $bits[1]
        }
    }
}