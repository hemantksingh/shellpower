# shellpower.iisconfig

Provides powershell cmdlets for setting up and configuring web applications in IIS. This package includes the powersehll cmdlets, which can be referenced by your powersehll scripts for performing common iis configuration operations.

## Usage

* Install nuget package

    ```sh
    nuget install shellpower.iisconfig -outputdirectory packages
    ```

* Create new file `getting-started.ps1` with the following content

    ```powershell

    . packages\webapp.ps1

    Create-AppPoolWithIdentity -name "testappPool" -username "test-user" -password "test-password"
    ```

* Run `.\getting-started.ps1`

Refer to the tests in the source code for more usage examples.
