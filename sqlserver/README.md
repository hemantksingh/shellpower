# shellpower.sqlserver

Provides powershell cmdlets for managing and configuring sql server in a repeatable manner, ideal for continuous integration/deployment scenarios.

## Usage

* Install nuget package

    ```sh
    nuget install shellpower.sqlserver -outputdirectory packages
    ```

* Create new file `getting-started.ps1` with the following content

    ```powershell

    # dot source the script
    . packages\bin\sqlserver.ps1 -dbServer "localhost" -dbName "foo"

    # Create sql user and assign it to db "foo"
    Add-SqlUser -sqlUser (Create-SqlUser "bar" "test-passw0rd!")

    # Remove sql user from db "foo" and sql logins
    Remove-SqlUser -sqlUser "bar"
    ```

* Run `.\getting-started.ps1`

Refer to the [tests](./tests) in the source code for more examples.