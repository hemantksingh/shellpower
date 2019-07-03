# Shellpower

Provides powershell cmdlets for performing windows based operations in a repeatable manner for continuous integration/deployment scenarios.

## Supported packages

* [shellpower.iisconfig](./iisconfig/README.md)
* [shellpower.sqlserver](./sqlserver/README.md)

## Test a package

* Create an application package, install it and run tests against it
    e.g. `make test-package APPLICATION=iisconfig NUGET_SOURCE=$PWD`

## Appveyor

![Build Status](https://ci.appveyor.com/api/projects/status/github/hemantksingh/shellpower?branch=master&svg=true)