function Fail ($message) {
    Write-Error $message
    throw [System.Exception] $message
}
  
function Assert-Equal ($expected, $actual, $message) {
    if($expected -ne $actual) {
        Fail "$message Expected '$expected' Actual '$actual'"
    }
}

function Assert-NotEqual ($expected, $actual, $message) {
    if($expected -eq $actual) {
        Fail "$message Expected '$expected' to be not equal to '$actual'"
    }
}

function Ensure-PathExists([Parameter(mandatory=$true)][string] $path) {
    if(-Not (Test-Path $path)) {
      Write-Warning "'$path' does not exist. Creating it"
      mkdir -Force $path
    } else {
        Write-Warning "'$path' already exists"
    }
  }