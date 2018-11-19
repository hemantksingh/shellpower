# shellpower.iisconfig

Provides powershell cmdlets for setting up and configuring web applications in IIS. This package includes the powershell cmdlets, which can be referenced by your powershell scripts for performing common iis configuration operations in a repeatable manner, ideal for continuous integration/deployment scenarios.

## Usage

* Install nuget package

    ```sh
    nuget install shellpower.iisconfig -outputdirectory packages
    ```

* Create new file `getting-started.ps1` with the following content

    ```powershell

    # dot source the script
    . packages\bin\iisconfig.ps1

    Create-AppPoolWithIdentity -name "testappPool" -username "test-user" -password "test-password"
    ```

* Run `.\getting-started.ps1`

Refer to the [tests](./tests) in the source code for more examples.