filter ConvertFrom-Hashtable {
    <#
        .SYNOPSIS
        Converts a hashtable to a PSCustomObject.

        .DESCRIPTION
        Recursively converts a hashtable to a PSCustomObject.
        This function is useful for converting structured data to objects,
        making it easier to work with and manipulate.

        .EXAMPLE
        $hashtable = @{
            Name        = 'John Doe'
            Age         = 30
            Address     = @{
                Street  = '123 Main St'
                City    = 'Somewhere'
                ZipCode = '12345'
            }
            Occupations = @(
                @{
                    Title   = 'Developer'
                    Company = 'TechCorp'
                },
                @{
                    Title   = 'Consultant'
                    Company = 'ConsultCorp'
                }
            )
        }
        ConvertFrom-Hashtable -InputHash $hashtable

        Output:
        ```powershell
        Name                           Value
        ----                           -----
        Age                            30
        Address                        @{ZipCode=12345; City=Somewhere; Street=123 Main St}
        Name                           John Doe
        Occupations                    {@{Title=Developer; Company=TechCorp}, @{Title=Consultant; Company=ConsultCorp}}
        ```

        Converts the provided hashtable into a PSCustomObject.

        .OUTPUTS
        PSCustomObject

        .NOTES
        A custom object representation of the provided hashtable.
        The returned object preserves the original structure of the input.

        .LINK
        https://psmodule.io/Hashtable/Functions/ConvertFrom-Hashtable
    #>
    [CmdletBinding()]
    param(
        # The hashtable to convert to a PSCustomObject.
        [Parameter(Mandatory, ValueFromPipeline)]
        [hashtable] $InputHash
    )

    # Prepare a hashtable to hold properties for the PSCustomObject.
    $props = @{}

    foreach ($key in $InputHash.Keys) {
        $value = $InputHash[$key]

        if ($value -is [hashtable]) {
            # Recursively convert nested hashtables.
            $props[$key] = ConvertFrom-Hashtable -InputHash $value
        } elseif ($value -is [array]) {
            # Check each element: if it's a hashtable, convert it; otherwise, leave it as is.
            $props[$key] = $value | ForEach-Object {
                if ($_ -is [hashtable]) {
                    ConvertFrom-Hashtable -InputHash $_
                } else {
                    $_
                }
            }
        } else {
            # For other types, assign directly.
            $props[$key] = $value
        }
    }

    # Return a new PSCustomObject built from the processed properties.
    return [pscustomobject]$props
}
