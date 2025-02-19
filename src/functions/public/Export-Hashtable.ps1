filter Export-Hashtable {
    <#
        .SYNOPSIS
        Exports a hashtable to a specified file in PSD1, PS1, or JSON format.

        .DESCRIPTION
        This function takes a hashtable and exports it to a file in one of the supported formats: PSD1, PS1, or JSON.
        The format is determined based on the file extension provided in the Path parameter. If the extension is not
        recognized, the function throws an error. This function supports pipeline input.

        .EXAMPLE
        $myHashtable = @{ Key = 'Value'; Number = 42 }
        $myHashtable | Export-Hashtable -Path 'C:\config.psd1'

        Exports the hashtable to a PSD1 file.

        .EXAMPLE
        $myHashtable = @{ Key = 'Value'; Number = 42 }
        Export-Hashtable -Hashtable $myHashtable -Path 'C:\script.ps1'

        Exports the hashtable as a PowerShell script that returns the hashtable when executed.

        .EXAMPLE
        $myHashtable = @{ Key = 'Value'; Number = 42 }
        Export-Hashtable -Hashtable $myHashtable -Path 'C:\data.json'

        Exports the hashtable as a JSON file.

        .OUTPUTS
        void

        .NOTES
        This function does not return an output. It writes the exported data to a file.

        .LINK
        https://psmodule.io/Export/Functions/Export-Hashtable/
    #>
    [OutputType([void])]
    [CmdletBinding()]
    param(
        # The hashtable to export.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [hashtable] $Hashtable,

        # The file path where the hashtable will be exported.
        [Parameter(Mandatory)]
        [string] $Path
    )

    # Determine file extension and select export format.
    $extension = [System.IO.Path]::GetExtension($Path).ToLower()

    switch ($extension) {
        '.psd1' {
            try {
                # Use Format-Hashtable to generate a PSD1-like output.
                $formattedHashtable = Format-Hashtable -Hashtable $Hashtable
                Set-Content -Path $Path -Value $formattedHashtable -Force
            } catch {
                throw "Failed to export hashtable to PSD1 file '$Path'. Error details: $_"
            }
        }
        '.ps1' {
            try {
                # Format the hashtable and wrap it in a function so that when the script is run it returns the hashtable.
                $formattedHashtable = Format-Hashtable -Hashtable $Hashtable
                Set-Content -Path $Path -Value $formattedHashtable -Force
            } catch {
                throw "Failed to export hashtable to PS1 file '$Path'. Error details: $_"
            }
        }
        '.json' {
            try {
                # Convert the hashtable to JSON. You might adjust the Depth parameter as needed.
                $jsonContent = $Hashtable | ConvertTo-Json -Depth 10
                Set-Content -Path $Path -Value $jsonContent -Force
            } catch {
                throw "Failed to export hashtable to JSON file '$Path'. Error details: $_"
            }
        }
        default {
            throw "Unsupported file extension '$extension'. Only .psd1, .ps1, and .json files are supported."
        }
    }
}
