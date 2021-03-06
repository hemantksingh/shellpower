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
    $configDir = "{0}\shellpower\{1}\tests" `
        -f $env:TEMP, $application
    if (!(Test-Path $configDir)) {
        # PS returns multiple items (in an array), capture result 
        # in var to stop returning an array
        $dir = New-Item -ItemType Directory -Force -Path $configDir
    }
    return "$configDir\web.config"
}