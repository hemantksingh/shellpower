# Shellpower

Provides powershell cmdlets for performing windows based operations in a repeatable manner for continuous integration/deployment scenarios.

## Supported packages

* [shellpower.iisconfig](./iisconfig/README.md)
* [shellpower.sqlserver](./sqlserver/README.md)

## Development

You must increment the versions in the nuspec files for each merge to the master branch so that a new package can be pushed to the devops feed
The nuspec files can be found in:
- /iisconfig/nuget
- /sqlserver/nuget

## Appveyor - No longer in use (TODO: remove this)

![Build Status](https://ci.appveyor.com/api/projects/status/github/hemantksingh/shellpower?branch=master&svg=true)