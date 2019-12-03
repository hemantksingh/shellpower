function Fail ($message) {
    Write-Error $message
    throw [System.Exception] $message
}
  
function Assert-Equal ($expected, $actual, $message) {
    if ($expected -ne $actual) {
        Fail "$message Expected '$expected' Actual '$actual'"
    }
}

function Assert-NotEqual ($expected, $actual, $message) {
    if ($expected -eq $actual) {
        Fail "$message Expected '$expected' to be not equal to '$actual'"
    }
}

function Ensure-PathExists([Parameter(mandatory = $true)][string] $path) {
    if (-Not (Test-Path $path)) {
        Write-Host "'$path' does not exist. Creating it"
        mkdir -Force $path
    }
    else {
        Write-Host "'$path' already exists"
    }
}

function Get-TestConfigFile ($application) {
    $testConfigFile = "{0}\shellpower\{1}\tests\web.config" `
        -f $env:TEMP, $application
    $configDir = Split-Path -Path $testConfigFile
    if (!(Test-Path $configDir)) {
        New-Item -ItemType Directory -Force -Path $configDir
    }
    return $testConfigFile
}