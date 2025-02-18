function Format-Hashtable {
    <#
        .SYNOPSIS
        Formats a PowerShell hashtable into a structured, indented string representation.

        .DESCRIPTION
        This function takes a hashtable as input and returns a formatted string that represents
        the hashtable in a readable and structured PowerShell syntax. It supports nested hashtables
        and arrays, preserving indentation for clarity.

        This is useful for logging, debugging, or displaying structured data in a human-readable format.

        .EXAMPLE
        $hash = @{
            Name = "PowerShell"
            Version = "7.3"
            Nested = @{
                Key1 = "Value1"
                Key2 = "Value2"
            }
            List = @("Item1", "Item2")
        }
        Format-Hashtable -Hashtable $hash

        Output:
        ```powershell
        @{
            Name = 'PowerShell'
            Version = '7.3'
            Nested = @{
                Key1 = 'Value1'
                Key2 = 'Value2'
            }
            List = @(
                'Item1'
                'Item2'
            )
        }
        ```

        Formats the given hashtable into a structured PowerShell representation.

        .OUTPUTS
        System.String

        .NOTES
        A formatted string representation of the given hashtable.

        .LINK
        https://psmodule.io/Format/Functions/Format-Hashtable
    #>
    [CmdletBinding()]
    param(
        # The hashtable to format into a structured string representation.
        [Parameter(Mandatory)]
        [System.Collections.IDictionary] $Hashtable,

        # Internal use for recursion, specifies indentation level (default is 0).
        [int] $Indent = 0
    )

    # Determine indent strings for current level and next level
    $indentStr = ' ' * 4 * $Indent      # current level indent (4 spaces per level)
    $indentStrOne = ' ' * 4 * ($Indent + 1)  # one level deeper

    # Use a list to accumulate output lines for efficiency
    $lines = New-Object System.Collections.Generic.List[string]

    # Opening brace for hashtable (with @ sign for literal syntax)
    $lines.Add("$indentStr@{")

    foreach ($key in $Hashtable.Keys) {
        # Format the key, quoting it if necessary for valid PowerShell syntax
        $keyStr = if ($key -is [string]) {
            if ($key -match '\s|[^A-Za-z0-9_]') {
                # contains space or special char - quote the key
                "'" + $key.Replace("'", "''") + "'"  # single-quote, escape internal '
            } else {
                $key  # safe unquoted key
            }
        } else {
            # Non-string keys: use $true/$false for bool, $null for null, otherwise toString
            if ($key -eq $true -or $key -eq $false) {
                $key.ToString().ToLower()  # $true/$false as lowercase
            } elseif ($null -eq $key) {
                '$null'
            } else {
                $key   # numeric or other types output as-is (will call ToString if not string)
            }
        }

        # Get the value for this key
        $value = $Hashtable[$key]

        if ($value -is [System.Collections.IDictionary]) {
            # Nested hashtable: output key = @{ then recurse
            $lines.Add("$indentStrOne$keyStr = @{")
            # Recurse with Indent+2 (one for this nested content, one because we already at indentStrOne for key)
            $nested = Format-Hashtable -Hashtable $value -Indent ($Indent + 2)
            # Add each nested line (which already includes its closing brace and newline structure)
            foreach ($line in ($nested -split [environment]::NewLine)) {
                if ($line) { $lines.Add($line) }
            }
            # Add closing brace for this nested hashtable, aligned with indentStrOne
            $lines.Add("$indentStrOne`}")
        } elseif ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string])) {
            # Array or collection: output key = @(
            $lines.Add("$indentStrOne$keyStr = @(")
            foreach ($elem in $value) {
                if ($elem -is [System.Collections.IDictionary]) {
                    # Hashtable element inside array
                    $lines.Add((' ' * 4 * ($Indent + 2)) + '@{')
                    $nestedElem = Format-Hashtable -Hashtable $elem -Indent ($Indent + 3)
                    foreach ($line in ($nestedElem -split [environment]::NewLine)) {
                        if ($line) { $lines.Add($line) }
                    }
                    $lines.Add((' ' * 4 * ($Indent + 2)) + '}')
                } elseif ($elem -is [System.Collections.IEnumerable] -and -not ($elem -is [string])) {
                    # Nested array inside array (rare): format recursively
                    $lines.Add((' ' * 4 * ($Indent + 2)) + '@(')
                    $nestedArr = Format-Hashtable -Hashtable @{'__ArrayTemp' = $elem } -Indent ($Indent + 3)
                    # Remove the artificial key wrappers "__ArrayTemp = " and just take its elements
                    $nestedArrLines = $nestedArr -split [environment]::NewLine
                    # Skip first line (@{) and last (}) and take the content in between as the array elements
                    $nestedArrContent = $nestedArrLines[1..($nestedArrLines.Length - 2)]
                    foreach ($line in $nestedArrContent) {
                        # Replace leading 8 spaces (2 indent levels) with current indent for array element
                        $lines.Add((' ' * 4 * ($Indent + 3)) + $line.TrimStart())
                    }
                    $lines.Add((' ' * 4 * ($Indent + 2)) + ')')
                } else {
                    # Simple element: format with quotes if string
                    $elemStr = if ($elem -is [string]) {
                        "'" + $elem.Replace("'", "''") + "'"
                    } elseif ($elem -eq $true -or $elem -eq $false) {
                        $elem.ToString().ToLower()
                    } elseif ($null -eq $elem) {
                        '$null'
                    } else {
                        $elem  # number or other type
                    }
                    $lines.Add((' ' * 4 * ($Indent + 2)) + "$elemStr")
                }
            }
            # Closing parenthesis for array
            $lines.Add("$indentStrOne)")
        } else {
            # Scalar value: format with quotes if it's a string, or appropriate literal
            $valStr = if ($value -is [string]) {
                "'" + $value.Replace("'", "''") + "'"
            } elseif ($value -eq $true -or $value -eq $false) {
                $value.ToString().ToLower()
            } elseif ($null -eq $value) {
                '$null'
            } else {
                $value
            }
            $lines.Add("$indentStrOne$keyStr = $valStr")
        }
    }

    # Closing brace for the hashtable
    $lines.Add("$indentStr}")
    # Join all lines into final string with OS-specific newline
    return $lines.ToArray() -join [Environment]::NewLine
}
