filter Merge-Hashtable {
    <#
        .SYNOPSIS
        Merges multiple hashtables, applying overrides in sequence.

        .DESCRIPTION
        This function takes a primary hashtable (`$Main`) and merges it with one or more override hashtables (`$Overrides`).
        Overrides are applied in order, with later values replacing earlier ones if the same key exists.
        If the `-Force` switch is used, values will be overridden even if they are empty or `$null`.
        The resulting hashtable is returned.

        .EXAMPLE
        $Main = @{
            Key1 = 'Value1'
            Key2 = 'Value2'
        }
        $Override1 = @{
            Key2 = 'Override2'
        }
        $Override2 = @{
            Key3 = 'Value3'
        }
        $Main | Merge-Hashtable -Overrides $Override1, $Override2

        Output:
        ```powershell
        Name                           Value
        ----                           -----
        Key1                           Value1
        Key2                           Override2
        Key3                           Value3
        ```

        Merges `$Main` with two override hashtables, applying overrides in order.

        .EXAMPLE
        $Main = @{
            Key1 = 'Value1'
            Key2 = 'Value2'
        }
        $Override = @{
            Key2 = ''
            Key3 = 'Value3'
        }
        $Main | Merge-Hashtable -Overrides $Override -Force

        Output:
        ```powershell
        Name                           Value
        ----                           -----
        Key1                           Value1
        Key2
        Key3                           Value3
        ```

        Forces overriding even if the value is empty.

        .OUTPUTS
        Hashtable

        .NOTES
        A merged hashtable with applied overrides.

        .LINK
        https://psmodule.io/Hashtable/Functions/Merge-Hashtable/
    #>

    [OutputType([Hashtable])]
    [Alias('Join-Hashtable')]
    [CmdletBinding()]
    param (
        # Main hashtable
        [Parameter(Mandatory)]
        [hashtable] $Main,

        # Hashtable with overrides.
        # Providing a list of overrides will apply them in order.
        # Last write wins.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [hashtable[]] $Overrides,

        # When specified, force override even if the value is empty or null.
        [Parameter()]
        [switch] $Force
    )

    begin {
        $Output = $Main.Clone()
    }

    process {
        foreach ($Override in $Overrides) {
            foreach ($Key in $Override.Keys) {
                if (($Output.Keys) -notcontains $Key) {
                    $Output.$Key = $Override.$Key
                }
                if ($Force -or -not [string]::IsNullOrEmpty($Override[$Key])) {
                    $Output[$Key] = $Override[$Key]
                }
            }
        }
    }

    end {
        return $Output
    }
}
