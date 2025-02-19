filter Remove-HashtableEntry {
    <#
        .SYNOPSIS
        Removes specific entries from a hashtable based on given criteria.

        .DESCRIPTION
        This function filters out entries from a hashtable based on different conditions. You can remove keys with
        null or empty values, keys of a specific type, or keys matching certain names. It also allows keeping entries
        based on the opposite criteria. If the `-All` parameter is used, all entries in the hashtable will be removed.

        .EXAMPLE
        $myHashtable = @{ Name = 'John'; Age = 30; Country = $null }
        $myHashtable | Remove-HashtableEntry -NullOrEmptyValues

        Output:
        ```powershell
        @{ Name = 'John'; Age = 30 }
        ```

        Removes entries with null or empty values from the hashtable.

        .EXAMPLE
        $myHashtable = @{ Name = 'John'; Age = 30; Active = $true }
        $myHashtable | Remove-HashtableEntry -Types 'Boolean'

        Output:
        ```powershell
        @{ Name = 'John'; Age = 30 }
        ```

        Removes entries where the value type is Boolean.

        .EXAMPLE
        $myHashtable = @{ Name = 'John'; Age = 30; Country = 'USA' }
        $myHashtable | Remove-HashtableEntry -Keys 'Age'

        Output:
        ```powershell
        @{ Name = 'John'; Country = 'USA' }
        ```

        Removes the key 'Age' from the hashtable.

        .OUTPUTS
        System.Void. The function modifies the input hashtable but does not return output.

        .LINK
        https://psmodule.io/Hashtable/Functions/Remove-HashtableEntry/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Function does not change state.'
    )]
    [OutputType([void])]
    [CmdletBinding()]
    param(
        # The hashtable to remove entries from.
        [Parameter(Mandatory, ValueFromPipeline)]
        [hashtable] $Hashtable,

        # Remove keys with null or empty values.
        [Parameter()]
        [switch] $NullOrEmptyValues,

        # Remove keys of a specified type.
        [Parameter()]
        [string[]] $Types,

        # Remove keys with a specified name.
        [Parameter()]
        [Alias('Names')]
        [string[]] $Keys,

        # Remove keys with null or empty values.
        [Parameter()]
        [Alias('IgnoreNullOrEmptyValues')]
        [switch] $KeepNullOrEmptyValues,

        # Keep only keys of a specified type.
        [Parameter()]
        [Alias('IgnoreTypes')]
        [string[]] $KeepTypes,

        # Keep only keys with a specified name.
        [Parameter()]
        [Alias('IgnoreKey', 'KeepNames')]
        [string[]] $KeepKeys,

        # Remove all entries from the hashtable.
        [Parameter()]
        [switch] $All
    )

    # Copy keys to a static array to prevent modifying the collection during iteration.
    $hashtableKeys = @($Hashtable.Keys)
    foreach ($key in $hashtableKeys) {
        $value = $Hashtable[$key]
        $vaultIsNullOrEmpty = [string]::IsNullOrEmpty($value)
        $valueIsNotNullOrEmpty = -not $vaultIsNullOrEmpty
        $typeName = if ($valueIsNotNullOrEmpty) { $value.GetType().Name } else { $null }

        if ($KeepKeys -and $key -in $KeepKeys) {
            Write-Debug "Keeping [$key] because it is in KeepKeys [$KeepKeys]."
        } elseif ($KeepTypes -and $typeName -in $KeepTypes) {
            Write-Debug "Keeping [$key] because its type [$typeName] is in KeepTypes [$KeepTypes]."
        } elseif ($vaultIsNullOrEmpty -and $KeepNullOrEmptyValues) {
            Write-Debug "Keeping [$key] because its value is null or empty."
        } elseif ($vaultIsNullOrEmpty -and $NullOrEmptyValues) {
            Write-Debug "Removing [$key] because its value is null or empty."
            $Hashtable.Remove($key)
        } elseif ($Types -and $typeName -in $Types) {
            Write-Debug "Removing [$key] because its type [$typeName] is in Types [$Types]."
            $Hashtable.Remove($key)
        } elseif ($Keys -and $key -in $Keys) {
            Write-Debug "Removing [$key] because it is in Keys [$Keys]."
            $Hashtable.Remove($key)
        } elseif ($All) {
            Write-Debug "Removing [$key] because All flag is set."
            $Hashtable.Remove($key)
        } else {
            Write-Debug "Keeping [$key] by default."
        }
    }
}
