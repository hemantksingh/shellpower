param (
  [string] $source = (Get-Item -Path ".\iisconfig\src" -Verbose).FullName
)

$ErrorActionPreference = "Stop"

$tests =  (Get-Item -Path ".\iisconfig\tests\" -Verbose).FullName

Write-Host "Importing from source '$source'"
$testData = (Get-Item -Path ".\iisconfig\tests\testdata" -Verbose).FullName
. $source\lib\webconfig.ps1
. $tests\util.ps1

$testConfigFile = Get-TestConfigFile 'iisconfig'
(Get-Content $testData\testweb.config) | Out-File $testConfigFile

$rule = Get-RewriteRule -configFile $testConfigFile -ruleName 'HTTP to HTTPS redirect'
Write-Host $rule.OuterXml

Remove-RewriteRule `
  -configFile  $testConfigFile `
  -ruleName 'HTTP to HTTPS redirect1'

Remove-RewriteRule `
  -configFile  $testConfigFile `
  -ruleName 'HTTP to HTTPS redirect'