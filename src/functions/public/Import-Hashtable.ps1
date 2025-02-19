function Import-Hashtable {
    <#
        .SYNOPSIS
        Imports a hashtable from a specified file.

        .DESCRIPTION
        This function reads a file and imports its contents as a hashtable. It supports `.psd1`, `.ps1`, and `.json` files.
        - `.psd1` files are imported using `Import-PowerShellDataFile`. This process is safe and does not execute any code.
        - `.ps1` scripts are executed, and their output must be a hashtable. If the script does not return a hashtable, an error is thrown.
        - `.json` files are read and converted to a hashtable using `ConvertFrom-Json -AsHashtable`.
        This process is safe and does not execute any code.

        If the specified file does not exist or has an unsupported format, an error is thrown.

        .EXAMPLE
        Import-Hashtable -Path 'C:\config.psd1'

        Output:
        ```powershell
        Name       Value
        ----       -----
        Setting1   Enabled
        Setting2   42
        ```

        Imports a hashtable from a `.psd1` file.

        .EXAMPLE
        Import-Hashtable -Path 'C:\script.ps1'

        Output:
        ```powershell
        Name       Value
        ----       -----
        Key1       Value1
        Key2       Value2
        ```

        Executes the script and imports the hashtable returned by the `.ps1` file.

        .EXAMPLE
        Import-Hashtable -Path 'C:\data.json'

        Output:
        ```powershell
        Name       Value
        ----       -----
        username   johndoe
        roles      {Admin, User}
        ```

        Reads a JSON file and converts its content into a hashtable.

        .OUTPUTS
        hashtable

        .NOTES
        A hashtable containing the data from the imported file.
        The hashtable structure depends on the contents of the imported file.

        .LINK
        https://psmodule.io/Hashtable/Functions/Import-Hashtable
    #>
    [CmdletBinding()]
    param(
        # Path to the file containing the hashtable.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Path
    )

    if (-not (Test-Path -Path $Path)) {
        throw "File '$Path' does not exist."
    }

    $extension = [System.IO.Path]::GetExtension($Path).ToLower()

    switch ($extension) {
        '.psd1' {
            try {
                $hashtable = Import-PowerShellDataFile -Path $Path
            } catch {
                throw "Failed to import hashtable from PSD1 file '$Path'. Error details: $_"
            }
        }
        '.ps1' {
            try {
                $hashtable = & $Path
                if (-not ($hashtable -is [hashtable])) {
                    throw 'The PS1 script did not return a hashtable. Verify its content.'
                }
            } catch {
                throw "Failed to import hashtable from PS1 file '$Path'. Error details: $_"
            }
        }
        '.json' {
            try {
                # Read the entire JSON file and convert it to a hashtable.
                $jsonContent = Get-Content -Path $Path -Raw
                $hashtable = $jsonContent | ConvertFrom-Json -AsHashtable
            } catch {
                throw "Failed to import hashtable from JSON file '$Path'. Error details: $_"
            }
        }
        default {
            throw "Unsupported file extension '$extension'. Only .psd1, .ps1, and .json files are supported."
        }
    }

    return $hashtable
}
