filter Format-Hashtable {
    <#
        .SYNOPSIS
        Converts a hashtable to its PowerShell code representation.

        .DESCRIPTION
        Recursively converts a hashtable to its PowerShell code representation.
        This function is useful for exporting hashtables to `.psd1` files,
        making it easier to store and retrieve structured data.

        .EXAMPLE
        $hashtable = @{
            Key1 = 'Value1'
            Key2 = @{
                NestedKey1 = 'NestedValue1'
                NestedKey2 = 'NestedValue2'
            }
            Key3 = @(1, 2, 3)
            Key4 = $true
        }
        Format-Hashtable -Hashtable $hashtable

        Output:
        ```powershell
        @{
            Key1       = 'Value1'
            Key2       = @{
                NestedKey1 = 'NestedValue1'
                NestedKey2 = 'NestedValue2'
            }
            Key3       = @(
                1
                2
                3
            )
            Key4       = $true
        }
        ```

        .OUTPUTS
        string

        .NOTES
        A string representation of the given hashtable.
        Useful for serialization and exporting hashtables to files.

        .LINK
        https://psmodule.io/Hashtable/Functions/Format-Hashtable
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        # The hashtable to convert to a PowerShell code representation.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [System.Collections.IDictionary] $Hashtable,

        # The indentation level for formatting nested structures.
        [Parameter()]
        [int] $IndentLevel = 1
    )

    # If the hashtable is empty, return '@{}' immediately.
    if ($Hashtable.Count -eq 0) {
        return '@{}'
    }

    $indent = '    '
    $lines = @()
    $lines += '@{'
    $levelIndent = $indent * $IndentLevel

    # Compute maximum key length at this level to align the '=' characters
    $maxKeyLength = ($Hashtable.Keys | ForEach-Object { $_.ToString().Length } | Measure-Object -Maximum).Maximum

    foreach ($key in $Hashtable.Keys) {
        # Pad each key to the maximum length so the '=' lines up.
        $paddedKey = $key.ToString().PadRight($maxKeyLength)
        Write-Verbose "Processing key: [$key]"
        $value = $Hashtable[$key]
        Write-Verbose "Processing value: [$value]"
        if ($null -eq $value) {
            Write-Verbose "Value type: `$null"
            $lines += "$levelIndent$paddedKey = `$null"
            continue
        }
        Write-Verbose "Value type: [$($value.GetType().Name)]"
        if ($value -is [System.Collections.IDictionary]) {
            # Nested hashtable
            $nestedString = Format-Hashtable -Hashtable $value -IndentLevel ($IndentLevel + 1)
            $lines += "$levelIndent$paddedKey = $nestedString"
        } elseif ($value -is [System.Management.Automation.PSCustomObject]) {
            # PSCustomObject => Convert to hashtable & recurse
            $nestedString = $value | ConvertTo-Hashtable | Format-Hashtable -IndentLevel ($IndentLevel + 1)
            $lines += "$levelIndent$paddedKey = $nestedString"
        } elseif ( $value -is [bool] -or $value -is [System.Management.Automation.SwitchParameter] ) {
            $boolValue = [bool]$value
            $lines += "$levelIndent$paddedKey = `$$($boolValue.ToString().ToLower())"
        } elseif ($value -is [int] -or $value -is [long] -or $value -is [double] -or $value -is [decimal]) {
            $lines += "$levelIndent$paddedKey = $value"
        } elseif ($value -is [System.Collections.IList]) {
            # This covers normal arrays, ArrayList, List<T>, etc.
            if ($value.Count -eq 0) {
                $lines += "$levelIndent$paddedKey = @()"
            } else {
                $lines += "$levelIndent$paddedKey = @("
                $arrayIndent = $levelIndent + $indent

                foreach ($nestedValue in $value) {
                    Write-Verbose "Processing array element: [$nestedValue]"
                    Write-Verbose "Element type: [$($nestedValue.GetType().Name)]"

                    if (($nestedValue -is [System.Collections.IDictionary])) {
                        # Nested hashtable
                        $nestedString = Format-Hashtable -Hashtable $nestedValue -IndentLevel ($IndentLevel + 2)
                        $lines += "$arrayIndent$nestedString"
                    } elseif ($nestedValue -is [System.Management.Automation.PSCustomObject]) {
                        # PSCustomObject => Convert to hashtable & recurse
                        $nestedString = $nestedValue | ConvertTo-Hashtable | Format-Hashtable -IndentLevel ($IndentLevel + 2)
                        $lines += "$arrayIndent$nestedString"
                    } elseif ( $nestedValue -is [bool] -or $nestedValue -is [System.Management.Automation.SwitchParameter] ) {
                        $boolValue = [bool]$nestedValue
                        $lines += "$arrayIndent`$$($boolValue.ToString().ToLower())"
                    } elseif ($nestedValue -is [int] -or $nestedValue -is [long] -or $nestedValue -is [double] -or $nestedValue -is [decimal]) {
                        $lines += "$arrayIndent$nestedValue"
                    } else {
                        # Fallback => treat as string (escape single-quotes)
                        $escapedElement = $nestedValue -replace "('+)", "''"
                        $lines += "$arrayIndent'$escapedElement'"
                    }
                }

                $lines += ($levelIndent + ')')
            }
        } else {
            # Fallback: treat as string (escaping single-quotes)
            $escapedValue = $value -replace "('+)", "''"
            $lines += "$levelIndent$paddedKey = '$escapedValue'"
        }
    }

    $levelIndent = $indent * ($IndentLevel - 1)
    $lines += "$levelIndent}"

    return $lines -join [Environment]::NewLine
}
