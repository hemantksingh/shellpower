function Fail ($message) {
    Write-Error $message
    throw [System.Exception] $message
}
  
function AssertEqual ($expected, $actual, $message) {
    if($expected -ne $actual) {
        Fail "$message Expected '$expected' Actual '$actual'"
    }
}