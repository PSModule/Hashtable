# Export-PowerShellDataFile.ps1
# Function to export a hashtable to a .psd1 data file with proper formatting

function Export-PowerShellDataFile {
    <#
    .SYNOPSIS
    Exports a hashtable to a PowerShell Data File (.psd1).

    .DESCRIPTION
    Takes a hashtable containing various data types (strings, booleans, numbers, doubles, floats,
    DateTime objects, arrays/lists, and nested hashtables) and writes it to a .psd1 file.
    The output file is a PowerShell data file representing the hashtable with proper syntax and formatting.
    This function preserves the data types by using appropriate literal notation (e.g. quotes for strings,
    $true/$false for booleans, etc.), escapes special characters in strings, and indents nested structures for readability.
    It will recursively process any nested hashtables or lists. If an unsupported data type is encountered,
    the function throws an error to avoid creating an invalid file.

    .PARAMETER Data
    The hashtable to export. Can include nested hashtables and arrays/lists of supported types.

    .PARAMETER Path
    The file path where the output .psd1 content will be saved.

    .PARAMETER NoClobber
    If specified, the function will not overwrite an existing file at the given Path.
    It will throw an error instead if the file already exists.

    .EXAMPLE
    $config = @{
        Name    = 'ExampleApp'
        Enabled = $true
        Ports   = @(80, 443, [single]8080.0)
        Nested  = @{
            Greeting = 'Hello World'
            Today    = (Get-Date)
        }
    }
    Export-PowerShellDataFile -Data $config -Path '.\ConfigData.psd1' -NoClobber

    # This creates 'ConfigData.psd1' with the content of $config in PSD1 format.
    # You can later retrieve the data using:
    #    $imported = Import-PowerShellDataFile -Path '.\ConfigData.psd1'
    # $imported will be a hashtable identical to $config (types preserved).
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [hashtable]$Data, # Hashtable (dictionary) to export
        [Parameter(Mandatory = $true)]
        [string]$Path, # Output file path for the .psd1
        [switch]$NoClobber          # Prevent overwriting an existing file
    )


    # Helper function: Returns the string $text indented by $indentLevel (4 spaces per level).
    function Get-IndentedString {
        param($text, [int]$indentLevel = 0)
        return (' ' * (4 * $indentLevel)) + $text
    }

    # Helper function: Converts any supported object to its PSD1 string representation (with indent).
    function Convert-Element {
        param(
            $obj,
            [int]$indent = 0,
            [switch]$SkipIndentOnce  # if set, do not indent the first line of the output
        )
        # Determine the object type and call the appropriate converter:
        if ($obj -is [System.Collections.IDictionary]) {
            # Hashtable or dictionary
            return Convert-Hashtable -obj $obj -indent $indent -SkipIndentOnce:$SkipIndentOnce
        } elseif ($obj -is [string]) {
            return Convert-String -obj $obj -indent $indent -SkipIndentOnce:$SkipIndentOnce
        } elseif ($obj -is [bool]) {
            return Convert-Boolean -obj $obj -indent $indent -SkipIndentOnce:$SkipIndentOnce
        } elseif ($obj -is [datetime]) {
            return Convert-DateTime -obj $obj -indent $indent -SkipIndentOnce:$SkipIndentOnce
        } elseif ($obj -is [System.Collections.IEnumerable] -and -not ($obj -is [string])) {
            # Arrays or Lists (any enumerable that's not a string or hashtable)
            return Convert-Array -obj $obj -indent $indent -SkipIndentOnce:$SkipIndentOnce
        } elseif ($obj -is [single]) {
            return Convert-Float -obj $obj -indent $indent -SkipIndentOnce:$SkipIndentOnce
        } elseif ($obj -is [double]) {
            return Convert-Double -obj $obj -indent $indent -SkipIndentOnce:$SkipIndentOnce
        } elseif ($obj -is [decimal]) {
            return Convert-Decimal -obj $obj -indent $indent -SkipIndentOnce:$SkipIndentOnce
        } elseif ($obj -is [byte] -or $obj -is [sbyte] -or
            $obj -is [int16] -or $obj -is [int32] -or $obj -is [int64] -or
            $obj -is [uint16] -or $obj -is [uint32] -or $obj -is [uint64]) {
            # Any integer numeric type
            return Convert-Number -obj $obj -indent $indent -SkipIndentOnce:$SkipIndentOnce
        } else {
            # Unsupported type – throw an error
            Write-Error ("Export-PowerShellDataFile: Unsupported data type '{0}'." -f ($obj.GetType().FullName)) -ErrorAction Stop
        }
    }

    # Helper: Convert a hashtable/dictionary to PSD1 format (recursive).
    function Convert-Hashtable {
        param(
            $obj,
            [int]$indent = 0,
            [switch]$SkipIndentOnce
        )
        # Start of hashtable: '@{' with a newline
        $output = if ($SkipIndentOnce) {
            Get-IndentedString "@{`n" 0
        } else {
            Get-IndentedString "@{`n" $indent
        }
        $indent += 1  # increase indent for content inside the hashtable
        foreach ($key in $obj.Keys) {
            # Write each key-value pair.
            # Convert key (always indent normally for the key):
            $output += (Convert-Element -obj $key -indent $indent) + ' = '
            # Convert value. Use -SkipIndentOnce so the value's first line aligns after '='.
            $output += (Convert-Element -obj $obj[$key] -indent $indent -SkipIndentOnce) + "`n"
        }
        $indent -= 1  # decrease indent back to original
        # End of hashtable: '}' (closing brace)
        $output += Get-IndentedString '}' $indent
        return $output
    }

    # Helper: Convert an array or list to PSD1 format.
    function Convert-Array {
        param(
            $obj,
            [int]$indent = 0,
            [switch]$SkipIndentOnce
        )
        # Start array: '@(' with a newline
        $output = if ($SkipIndentOnce) {
            Get-IndentedString "@(`n" 0
        } else {
            Get-IndentedString "@(`n" $indent
        }
        # Each element on a new line, indented one level deeper
        foreach ($element in $obj) {
            $output += Convert-Element -obj $element -indent ($indent + 1)
            $output += "`n"
        }
        # End array: ')' at the original indent level
        $output += Get-IndentedString ')' $indent
        return $output
    }

    # Helper: Convert a string to a quoted string literal (single or double quotes).
    function Convert-String {
        param(
            [string]$obj,
            [int]$indent = 0,
            [switch]$SkipIndentOnce
        )
        $text = $obj
        # If the string contains newline characters, use double quotes with `n; otherwise use single quotes.
        if ($text.Contains("`r") -or $text.Contains("`n")) {
            # Escape special chars for double-quoted string: backtick (`), dollar ($), and double-quote (").
            $escaped = $text -replace '`', '``'        # double each backtick
            $escaped = $escaped -replace '\$', '`$'    # escape any $ as `$
            $escaped = $escaped -replace '"', '`"'     # escape any " as `"
            # Replace carriage return + newline, or lone newline, with `n (literal sequence).
            $escaped = $escaped -replace "`r`n", '`n' -replace "`r", '`n'
            # Wrap in double quotes
            $outputStr = "`"$escaped`""
        } else {
            # No newlines: use single quotes. Escape any single quote by doubling it.
            $escaped = $text -replace "'", "''"
            $outputStr = "'$escaped'"
        }
        return if ($SkipIndentOnce) {
            Get-IndentedString $outputStr 0
        } else {
            Get-IndentedString $outputStr $indent
        }
    }

    # Helper: Convert a boolean to $true/$false literal.
    function Convert-Boolean {
        param(
            [bool]$obj,
            [int]$indent = 0,
            [switch]$SkipIndentOnce
        )
        # Use $true or $false (with $ so it is a literal boolean in the PSD1)
        $boolLiteral = if ($obj) { '$true' } else { '$false' }
        return if ($SkipIndentOnce) {
            Get-IndentedString $boolLiteral 0
        } else {
            Get-IndentedString $boolLiteral $indent
        }
    }

    # Helper: Convert integer numeric types to a numeric literal.
    function Convert-Number {
        param(
            $obj, # (int, long, byte, etc.)
            [int]$indent = 0,
            [switch]$SkipIndentOnce
        )
        # Use invariant culture to avoid locale-specific formatting (e.g. no commas)
        $numStr = $obj.ToString([System.Globalization.CultureInfo]::InvariantCulture)
        # Just output the number (no quotes)
        return if ($SkipIndentOnce) {
            Get-IndentedString $numStr 0
        } else {
            Get-IndentedString $numStr $indent
        }
    }

    # Helper: Convert a double (System.Double) to a numeric literal (ensure it stays a [double]).
    function Convert-Double {
        param(
            [double]$obj,
            [int]$indent = 0,
            [switch]$SkipIndentOnce
        )
        $numStr = $obj.ToString([System.Globalization.CultureInfo]::InvariantCulture)
        # Ensure a decimal point (or exponent) is present so it parses as a double (not int).
        if ($numStr -notmatch '[\.eE]') {
            $numStr += '.0'
        }
        return if ($SkipIndentOnce) {
            Get-IndentedString $numStr 0
        } else {
            Get-IndentedString $numStr $indent
        }
    }

    # Helper: Convert a float (System.Single) to a [float] cast expression to preserve type.
    function Convert-Float {
        param(
            [single]$obj,
            [int]$indent = 0,
            [switch]$SkipIndentOnce
        )
        $numStr = $obj.ToString([System.Globalization.CultureInfo]::InvariantCulture)
        if ($numStr -notmatch '[\.eE]') {
            $numStr += '.0'
        }
        # Prefix with [float] to ensure it's a Single when imported
        $literal = "[float]$numStr"
        return if ($SkipIndentOnce) {
            Get-IndentedString $literal 0
        } else {
            Get-IndentedString $literal $indent
        }
    }

    # Helper: Convert a decimal (System.Decimal) to a [decimal] cast with a string literal.
    function Convert-Decimal {
        param(
            [decimal]$obj,
            [int]$indent = 0,
            [switch]$SkipIndentOnce
        )
        $numStr = $obj.ToString([System.Globalization.CultureInfo]::InvariantCulture)
        # Use [decimal]"<value>" to preserve full precision (casts from string)
        $literal = "[decimal]`"$numStr`""
        return if ($SkipIndentOnce) {
            Get-IndentedString $literal 0
        } else {
            Get-IndentedString $literal $indent
        }
    }

    # Helper: Convert a DateTime to a [datetime] cast with ISO 8601 string.
    function Convert-DateTime {
        param(
            [datetime]$obj,
            [int]$indent = 0,
            [switch]$SkipIndentOnce
        )
        # Use round-trip ISO 8601 format ("o") for unambiguous date/time including offset/UTC.
        $dateStr = $obj.ToString('o', [System.Globalization.CultureInfo]::InvariantCulture)
        $literal = "[datetime]`"$dateStr`""
        return if ($SkipIndentOnce) {
            Get-IndentedString $literal 0
        } else {
            Get-IndentedString $literal $indent
        }
    }

    # Convert the top-level hashtable to PSD1-formatted text
    $psd1Content = Convert-Hashtable -obj $Data -indent 0

    # Write the content to the specified file, handling NoClobber if set
    if (Test-Path -LiteralPath $Path) {
        if ($NoClobber) {
            Write-Error "Export-PowerShellDataFile: File '$Path' already exists and NoClobber was specified." -ErrorAction Stop
        }
        # If not NoClobber, overwrite is allowed
    }
    # Output to file (UTF-8 encoding)
    $psd1Content # | Out-File -LiteralPath $Path -Encoding UTF8
}

