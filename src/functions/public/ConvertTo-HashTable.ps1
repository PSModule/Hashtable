filter ConvertTo-Hashtable {
    <#
        .SYNOPSIS
        Converts an object to a hashtable.

        .DESCRIPTION
        Recursively converts an object to a hashtable. This function is useful for converting complex objects
        to hashtables for serialization or other purposes.

        .EXAMPLE
        $object = [PSCustomObject]@{
            Name        = 'John Doe'
            Age         = 30
            Address     = [PSCustomObject]@{
                Street  = '123 Main St'
                City    = 'Somewhere'
                ZipCode = '12345'
            }
            Occupations = @(
                [PSCustomObject]@{
                    Title   = 'Developer'
                    Company = 'TechCorp'
                },
                [PSCustomObject]@{
                    Title   = 'Consultant'
                    Company = 'ConsultCorp'
                }
            )
        }
        ConvertTo-Hashtable -InputObject $object

        Output:
        ```powershell
        Name                           Value
        ----                           -----
        Age                            30
        Address                        {[ZipCode, 12345], [City, Somewhere], [Street, 123 Main St]}
        Name                           John Doe
        Occupations                    {@{Title=Developer; Company=TechCorp}, @{Title=Consultant; Company=ConsultCorp}}
        ```

        This returns a hashtable representation of the object.

        .OUTPUTS
        hashtable

        .NOTES
        The function returns a hashtable representation of the input object,
        converting complex nested structures recursively.

        .LINK
        https://psmodule.io/ConvertTo/Functions/ConvertTo-Hashtable
    #>
    [OutputType([hashtable])]
    [CmdletBinding()]
    param (
        # The object to convert to a hashtable.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [PSObject] $InputObject
    )

    $hashtable = @{}

    # Iterate over each property of the object
    $InputObject.PSObject.Properties | ForEach-Object {
        $propertyName = $_.Name
        $propertyValue = $_.Value

        if ($propertyValue -is [PSObject]) {
            if ($propertyValue -is [Array] -or $propertyValue -is [System.Collections.IEnumerable]) {
                # Handle arrays and enumerables
                $hashtable[$propertyName] = @()
                foreach ($item in $propertyValue) {
                    $hashtable[$propertyName] += ConvertTo-Hashtable -InputObject $item
                }
            } elseif ($propertyValue.PSObject.Properties.Count -gt 0) {
                # Handle nested objects
                $hashtable[$propertyName] = ConvertTo-Hashtable -InputObject $propertyValue
            } else {
                # Handle simple properties
                $hashtable[$propertyName] = $propertyValue
            }
        } else {
            $hashtable[$propertyName] = $propertyValue
        }
    }

    $hashtable
}
