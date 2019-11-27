function Remove-RewriteRule(
    [Parameter(mandatory = $true)][string]$configPath,
    [Parameter(mandatory = $true)][string]$ruleName) {
    
    Write-Host "Loading '$configPath'"
    [xml]$config = Get-Content -Path $configPath
    $config.configuration.'system.webServer'.'rewrite'.'rules' | foreach-object { 
        $child = $_.SelectSingleNode("rule[@name=""$ruleName""]")
        $_.RemoveChild($child) | Out-Null 
    }
    
    $config.OuterXml | Out-File $configPath
    Write-Host "After transform: $(Get-Content -Path $configPath)"
}