filter Remove-HashtableEntry {
    <#
        .SYNOPSIS
        Removes specific entries from a hashtable based on value, type, or name.

        .DESCRIPTION
        This version applies keep filters with the highest precedence. If a key
        qualifies based on the provided Keep parameters (KeepTypes and/or KeepKeys),
        it is preserved no matter what removal conditions might say.

        If no keep filters are provided, the function applies removal conditions:
        - NullOrEmptyValues: Remove keys with null or empty values.
        - RemoveTypes: Remove keys whose values are of the specified type(s).
        - RemoveKeys: Remove keys with the specified name(s).

        When Keep filters are provided, only keys that match ALL specified keep criteria
        will be preserved; keys that do not match are removed regardless of removal settings.

        At the end, the original hashtable is cleared and repopulated with the filtered results.

        .EXAMPLE
        $ht = @{
            KeepThis   = 'Value1'
            RemoveThis = 'Delete'
            Other      = 42
        }
        $ht | Remove-HashtableEntry -KeepKeys 'KeepThis' -RemoveKeys 'RemoveThis'

        This will keep only the key "KeepThis", regardless of other removal flags.

        .OUTPUTS
        hashtable

        .NOTES
        The function modifies the input hashtable in place.
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
