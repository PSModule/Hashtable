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
            Key1 = 'Value1'
            Key2 = @{
                NestedKey1 = 'NestedValue1'
                NestedKey2 = 'NestedValue2'
            }
            Key3 = @(
                1
                2
                3
            )
            Key4 = $true
        }
        ```

        Converts the provided hashtable into a PowerShell-formatted string representation.

        .OUTPUTS
        string

        .NOTES
        A string representation of the given hashtable.
        Useful for serialization and exporting hashtables to files.

        .LINK
        https://psmodule.io/Format/Functions/Format-Hashtable
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
        [object] $Hashtable,

        # The indentation level for formatting nested structures.
        [Parameter()]
        [int] $IndentLevel = 1
    )

    # If the hashtable is empty, return '@{}' immediately.
    if ($Hashtable -is [System.Collections.IDictionary] -and $Hashtable.Count -eq 0) {
        return '@{}'
    }

    $indent = '    '
    $lines = @()
    $lines += '@{'
    $levelIndent = $indent * $IndentLevel

    foreach ($key in $Hashtable.Keys) {
        Write-Verbose "Processing key: [$key]"
        $value = $Hashtable[$key]
        Write-Verbose "Processing value: [$value]"
        if ($null -eq $value) {
            Write-Verbose "Value type: `$null"
            $lines += "$levelIndent$key = `$null"
            continue
        }
        Write-Verbose "Value type: [$($value.GetType().Name)]"
        if (($value -is [System.Collections.Hashtable]) -or ($value -is [System.Collections.Specialized.OrderedDictionary])) {
            $nestedString = Format-Hashtable -Hashtable $value -IndentLevel ($IndentLevel + 1)
            $lines += "$levelIndent$key = $nestedString"
        } elseif ($value -is [System.Management.Automation.PSCustomObject]) {
            $nestedString = Format-Hashtable -Hashtable $value -IndentLevel ($IndentLevel + 1)
            $lines += "$levelIndent$key = $nestedString"
        } elseif ($value -is [System.Management.Automation.PSObject]) {
            $nestedString = Format-Hashtable -Hashtable $value -IndentLevel ($IndentLevel + 1)
            $lines += "$levelIndent$key = $nestedString"
        } elseif ($value -is [bool]) {
            $lines += "$levelIndent$key = `$$($value.ToString().ToLower())"
        } elseif ($value -is [int] -or $value -is [double]) {
            $lines += "$levelIndent$key = $value"
        } elseif ($value -is [array]) {
            if ($value.Count -eq 0) {
                $lines += "$levelIndent$key = @()"
            } else {
                $lines += "$levelIndent$key = @("
                $arrayIndent = $levelIndent + $indent  # Increase indentation for elements inside @(...)

                $value | ForEach-Object {
                    $nestedValue = $_
                    Write-Verbose "Processing array element: $_"
                    Write-Verbose "Element type: $($_.GetType().Name)"
                    if (($nestedValue -is [System.Collections.Hashtable]) -or ($nestedValue -is [System.Collections.Specialized.OrderedDictionary])) {
                        $nestedString = Format-Hashtable -Hashtable $nestedValue -IndentLevel ($IndentLevel + 2)
                        $lines += "$arrayIndent$nestedString"
                    } elseif ($nestedValue -is [bool]) {
                        $lines += "$arrayIndent`$$($nestedValue.ToString().ToLower())"
                    } elseif ($nestedValue -is [int]) {
                        $lines += "$arrayIndent$nestedValue"
                    } else {
                        $lines += "$arrayIndent'$nestedValue'"
                    }
                }
                $arrayIndent = $levelIndent
                $lines += "$arrayIndent)"
            }
        } else {
            $value = $value -replace "('+)", "''" # Escape single quotes in a manifest file
            $lines += "$levelIndent$key = '$value'"
        }
    }
    $levelIndent = $indent * ($IndentLevel - 1)
    $lines += "$levelIndent}"
    return $lines -join [Environment]::NewLine
}
