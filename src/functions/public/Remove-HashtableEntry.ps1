filter Remove-HashtableEntry {
    <#
        .SYNOPSIS
        Removes specific entries from a hashtable based on value, type, or name.

        .DESCRIPTION
        The `Remove-HashtableEntry` function filters out keys from a hashtable based on various criteria:
        - Removing keys with null or empty values.
        - Removing keys with specific value types.
        - Removing keys with specific names.
        - Removing keys that do not match a specified type or name.

        The function operates directly on the input hashtable.

        .EXAMPLE
        $Hashtable = @{
            'Key1' = 'Value1'
            'Key2' = 'Value2'
            'Key3' = $null
            'Key4' = 'Value4'
            'Key5' = ''
        }
        $Hashtable | Remove-HashtableEntry -NullOrEmptyValues

        Output:
        ```powershell
        Name                           Value
        ----                           -----
        Key1                           Value1
        Key2                           Value2
        Key4                           Value4
        ```

        Removes all keys with null or empty values from the input hashtable.

        .EXAMPLE
        $Hashtable = @{
            'Key1' = 'Value1'
            'Key2' = 42
            'Key3' = $null
            'Key4' = 'Value4'
            'Key5' = 3.14
        }
        $Hashtable | Remove-HashtableEntry -RemoveTypes 'Int32', 'Double'

        Output:
        ```powershell
        Name                           Value
        ----                           -----
        Key1                           Value1
        Key3
        Key4                           Value4
        ```

        Removes keys where the values are of type `Int32` or `Double`.

        .EXAMPLE
        $Hashtable = @{
            'KeepThis' = 'Value'
            'RemoveThis' = 'Delete'
        }
        $Hashtable | Remove-HashtableEntry -RemoveNames 'RemoveThis'

        Output:
        ```powershell
        Name                           Value
        ----                           -----
        KeepThis                       Value
        ```

        Removes a specific key by name.

        .OUTPUTS
        hashtable

        .NOTES
        The modified hashtable with specified keys removed.

        .LINK
        https://psmodule.io/Hashtable/Functions/Remove-HashtableEntry/
    #>
    [OutputType([hashtable])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Function does not change state.'
    )]
    [CmdletBinding()]
    param(
        # The hashtable to remove entries from.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [hashtable] $Hashtable,

        # Remove keys with null or empty values.
        [Parameter()]
        [switch] $NullOrEmptyValues,

        # Remove keys of a specified type.
        [Parameter()]
        [string[]] $RemoveTypes,

        # Remove keys with a specified name.
        [Parameter()]
        [string[]] $RemoveNames,

        # Remove keys that are NOT of a specified type.
        [Parameter()]
        [string[]] $KeepTypes,

        # Remove keys that are NOT of a specified name.
        [Parameter()]
        [string[]] $KeepNames
    )

    if ($NullOrEmptyValues) {
        Write-Debug 'Remove keys with null or empty values'
        ($Hashtable.GetEnumerator() | Where-Object { [string]::IsNullOrEmpty($_.Value) }) | ForEach-Object {
            Write-Debug " - [$($_.Name)] - Value: [$($_.Value)] - Remove"
            $Hashtable.Remove($_.Name)
        }
    }
    if ($RemoveTypes) {
        Write-Debug "Remove keys of type: [$RemoveTypes]"
        ($Hashtable.GetEnumerator() | Where-Object { ($_.Value.GetType().Name -in $RemoveTypes) }) | ForEach-Object {
            Write-Debug " - [$($_.Name)] - Type: [$($_.Value.GetType().Name)] - Remove"
            $Hashtable.Remove($_.Name)
        }
    }
    if ($KeepTypes) {
        Write-Debug "Remove keys NOT of type: [$KeepTypes]"
        ($Hashtable.GetEnumerator() | Where-Object { ($_.Value.GetType().Name -notin $KeepTypes) }) | ForEach-Object {
            Write-Debug " - [$($_.Name)] - Type: [$($_.Value.GetType().Name)] - Remove"
            $Hashtable.Remove($_.Name)
        }
    }
    if ($RemoveNames) {
        Write-Debug "Remove keys named: [$RemoveNames]"
        ($Hashtable.GetEnumerator() | Where-Object { $_.Name -in $RemoveNames }) | ForEach-Object {
            Write-Debug " - [$($_.Name)] - Remove"
            $Hashtable.Remove($_.Name)
        }
    }
    if ($KeepNames) {
        Write-Debug "Remove keys NOT named: [$KeepNames]"
        ($Hashtable.GetEnumerator() | Where-Object { $_.Name -notin $KeepNames }) | ForEach-Object {
            Write-Debug " - [$($_.Name)] - Remove"
            $Hashtable.Remove($_.Name)
        }
    }
}
