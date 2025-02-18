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
        [string[]] $RemoveTypes,

        # Remove keys with a specified name.
        [Parameter()]
        [Alias('RemoveNames')]
        [string[]] $RemoveKeys,

        # Keep only keys of a specified type.
        [Parameter()]
        [Alias('IgnoreType')]
        [string[]] $KeepTypes,

        # Keep only keys with a specified name.
        [Parameter()]
        [Alias('IgnoreKey', 'KeepNames')]
        [string[]] $KeepKeys
    )

    # Copy keys to a static array to prevent modifying the collection during iteration.
    $keys = @($Hashtable.Keys)
    foreach ($key in $keys) {
        $value = $Hashtable[$key]
        $vaultIsNullOrEmpty = [string]::IsNullOrEmpty($value)
        $valueIsNotNullOrEmpty = -not $vaultIsNullOrEmpty
        $typeName = if ($valueIsNotNullOrEmpty) { $value.GetType().Name } else { $null }

        if ($KeepKeys -and $key -in $KeepKeys) {
            Write-Debug "Keeping [$key] because it is in KeepKeys [$KeepKeys]."
            continue
        } elseif ($KeepTypes -and $typeName -in $KeepTypes) {
            Write-Debug "Keeping [$key] because its type [$typeName] is in KeepTypes [$KeepTypes]."
            continue
        } elseif ($vaultIsNullOrEmpty -and $NullOrEmptyValues) {
            Write-Debug "Removing [$key] because its value is null or empty."
            $Hashtable.Remove($key)
            continue
        } elseif ($RemoveTypes -and $typeName -in $RemoveTypes) {
            Write-Debug "Removing [$key] because its type [$typeName] is in RemoveTypes [$RemoveTypes]."
            $Hashtable.Remove($key)
            continue
        } elseif ($RemoveKeys -and $key -in $RemoveKeys) {
            Write-Debug "Removing [$key] because it is in RemoveKeys [$RemoveKeys]."
            $Hashtable.Remove($key)
            continue
        } else {
            Write-Debug "Keeping [$key] by default."
        }
    }
}
