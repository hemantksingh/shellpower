# Shellpower

Provides powershell cmdlets for performing windows based operations in a repeatable manner for continuous integration/deployment scenarios.

## Supported packages

* [shellpower.iisconfig](./iisconfig/README.md)
* [shellpower.sqlserver](./sqlserver/README.md)

## Test a package

To ensure the application package is good to be released, you can

* Create an application nuget package, install it locally and run tests against it
* `make test-package APPLICATION=iisconfig NUGET_SOURCE=$PWD`

## Appveyor

![Build Status](https://ci.appveyor.com/api/projects/status/github/hemantksingh/shellpower?branch=master&svg=true)