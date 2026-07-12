# Hashtable

Hashtable is a comprehensive PowerShell module for working with hashtables. It converts hashtables to and from
PSCustomObjects, formats hashtables into readable PowerShell code, merges hashtables with override support, and removes
entries based on specific criteria — simplifying complex hashtable manipulations in your automation workflows.

## Installation

Install the module from the PowerShell Gallery:

```powershell
Install-PSResource -Name Hashtable
Import-Module -Name Hashtable
```

## Usage

### Example: Convert a hashtable to a PSCustomObject

Convert a nested hashtable into a PSCustomObject, making it easier to manipulate and explore your data.

```powershell
$hashtable = @{
    Name    = 'Alice'
    Age     = 30
    Contact = @{
        Email = 'alice@example.com'
        Phone = '123-456-7890'
    }
}

$object = $hashtable | ConvertFrom-Hashtable
$object | Format-List
```

### Example: Merge hashtables with overrides

Merge a default settings hashtable with user-specified overrides. Values in the override hashtable replace those in the
base hashtable.

```powershell
$defaultSettings = @{
    Theme    = 'Light'
    Language = 'en'
    Layout   = 'Standard'
}
$userSettings = @{
    Theme  = 'Dark'
    Layout = 'Compact'
}

$mergedSettings = $defaultSettings | Merge-Hashtable -Overrides $userSettings
$mergedSettings
```

### Example: Format a hashtable as PowerShell code

Convert a hashtable into a nicely formatted PowerShell code representation — useful for exporting configuration to a
`.psd1` file.

```powershell
$configuration = @{
    Server      = 'localhost'
    Port        = 8080
    Credentials = @{
        Username = 'admin'
        Password = 'P@ssw0rd'
    }
    Enabled     = $true
}

$formattedConfig = $configuration | Format-Hashtable
Write-Output $formattedConfig
```

### Example: Remove hashtable entries by criteria

Remove specific entries from a hashtable, such as keys with null or empty values or a key matching a particular name.

```powershell
$ht = @{
    ValidKey = 'SomeValue'
    EmptyKey = ''
    RemoveMe = 'Unwanted'
}

# Remove entries with null or empty values and the key named 'RemoveMe'
$ht | Remove-HashtableEntry -NullOrEmptyValues -Keys 'RemoveMe'
$ht
```

## Documentation

Documentation is published at [psmodule.io/Hashtable](https://psmodule.io/Hashtable/).

Use PowerShell help and command discovery for module details:

```powershell
Get-Command -Module Hashtable
Get-Help -Name ConvertTo-Hashtable -Examples
```
