function Get-RewriteRule(
    [Parameter(mandatory = $true)][string]$configFile,
    [Parameter(mandatory = $true)][string]$ruleName) {

    Write-Host "Loading '$configFile'"
    [xml]$config = Get-Content -Path $configFile
    $config.configuration.'system.webServer'.'rewrite'.'rules' | foreach-object { 
        $child = $_.SelectSingleNode("rule[@name=""$ruleName""]")
        if ($null -ne $child) {
            return $child
        }
    }
}

    function Remove-RewriteRule(
        [Parameter(mandatory = $true)][string]$configFile,
        [Parameter(mandatory = $true)][string]$ruleName) {
    
        Write-Host "Loading '$configFile'"
        [xml]$config = Get-Content -Path $configFile
        $config.configuration.'system.webServer'.'rewrite'.'rules' | foreach-object { 
            $child = $_.SelectSingleNode("rule[@name=""$ruleName""]")
            if($null -ne $child) {
                $_.RemoveChild($child) | Out-Null 
            } else {
                Write-Warning "Rule '$ruleName' not found"
            }
        }
    
        $config.OuterXml | Out-File $configFile
        Write-Host "Saved '$configFile'"
    }

