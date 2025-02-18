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
            Key3 = @(1, 2, 3)
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
        [int] $IndentLevel = 0
    )

    $lines = @()
    $lines += '@{'
    $indent = '    ' * $IndentLevel

    foreach ($key in $Hashtable.Keys) {
        Write-Verbose "Processing key: $key"
        $value = $Hashtable[$key]
        Write-Verbose "Processing value: $value"
        if ($null -eq $value) {
            Write-Verbose "Value type: `$null"
            continue
        }
        Write-Verbose "Value type: $($value.GetType().Name)"
        switch -Regex ($value.GetType().Name) {
            'Hashtable|OrderedDictionary' {
                $nestedString = Format-Hashtable -Hashtable $value -IndentLevel ($IndentLevel + 1)
                $lines += "$indent    $key = $nestedString"
            }
            'PSCustomObject|PSObject' {
                $nestedString = Format-Hashtable -Hashtable $value -IndentLevel ($IndentLevel + 1)
                $lines += "$indent    $key = $nestedString"
            }
            'bool' {
                $lines += "$indent    $key = `$$($value.ToString().ToLower())"
            }
            'int' {
                $lines += "$indent    $key = $value"
            }
            'array|list' {
                if ($value.Count -eq 0) {
                    $lines += "$indent    $key = @()"
                } else {
                    $lines += "$indent    $key = @("
                    $arrayIndent = "$indent        "  # Increase indentation for elements inside @(...)

                    $value | ForEach-Object {
                        $nestedValue = $_
                        Write-Verbose "Processing array element: $_"
                        Write-Verbose "Element type: $($_.GetType().Name)"
                        switch -Regex ($nestedValue.GetType().Name) {
                            'Hashtable|OrderedDictionary' {
                                $nestedString = Format-Hashtable -Hashtable $nestedValue -IndentLevel ($IndentLevel + 2)
                                $lines += "$arrayIndent$nestedString"
                            }
                            'PSCustomObject|PSObject' {
                                $nestedString = Format-Hashtable -Hashtable $nestedValue -IndentLevel ($IndentLevel + 2)
                                $lines += "$arrayIndent$nestedString"
                            }
                            'bool' {
                                $lines += "$arrayIndent`$$($nestedValue.ToString().ToLower())"
                            }
                            'int' {
                                $lines += "$arrayIndent$nestedValue"
                            }
                            default {
                                $lines += "$arrayIndent'$nestedValue'"
                            }
                        }
                    }
                    $lines += "$indent    )"
                }
            }
            default {
                $value = $value -replace "('+)", "''" # Escape single quotes in a manifest file
                $lines += "$indent    $key = '$value'"
            }
        }
    }

    $lines += "$indent}"
    return $lines -join "`n"
}
