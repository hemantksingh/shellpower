param (
  [string] $source = (Get-Item -Path ".\iisconfig\src\lib" -Verbose).FullName
)

$ErrorActionPreference = "Stop"

$tests =  (Get-Item -Path ".\iisconfig\tests\" -Verbose).FullName

Write-Host "Importing from source '$source'"
$testData = (Get-Item -Path ".\iisconfig\tests\testdata" -Verbose).FullName
. $source\host.ps1 -hostFile $testData\test_hosts
. $tests\testutil.ps1

Add-HostMapping '127.0.0.3' 'dev3.local.com'

Assert-Equal '127.0.0.3' (Get-HostMapping 'dev3.local.com').ip
Assert-Equal 'dev3.local.com' (Get-HostMapping 'dev3.local.com').host
Assert-Equal $null (Get-HostMapping 'dev.local.com').ip
Assert-Equal $null (Get-HostMapping 'dev.local.com').host