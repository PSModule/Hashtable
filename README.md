# Hashtable

Hashtable is a comprehensive module that provides functions for working with PowerShell hashtables.
It enables you to convert hashtables to PSCustomObjects and vice versa, format hashtables into readable PowerShell
code, merge hashtables with override support, and remove entries based on specific criteria. This collection of
utilities is designed to simplify complex hashtable manipulations and help automate your PowerShell workflows.

## Prerequisites

This module uses the following external resources:
- The [PSModule framework](https://github.com/PSModule) for building, testing, and publishing the module.

## Installation

To install the module from the PowerShell Gallery, you can use the following command:

```powershell
Install-PSResource -Name Hashtable
Import-Module -Name Hashtable
```

## Usage

Below are some examples illustrating typical use cases for the module.

### Example 1: Converting a Hashtable to a PSCustomObject

This example demonstrates how to convert a nested hashtable into a PSCustomObject, making it easier to manipulate and explore your data.

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

### Example 2: Merging Hashtables

Merge a default settings hashtable with user-specified overrides. In this example, the values in the override hashtable
replace those in the main hashtable.

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

### Example 3: Formatting a Hashtable as PowerShell Code

Convert a hashtable into a nicely formatted PowerShell code representation. This is especially useful for exporting
configurations to a `.psd1` file.

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

### Example 4: Removing Hashtable Entries Based on Criteria

Remove specific entries from a hashtable, such as keys with null or empty values, or those matching a particular name.

```powershell
$ht = @{
    ValidKey  = 'SomeValue'
    EmptyKey  = ''
    RemoveMe  = 'Unwanted'
}

# Remove entries with null or empty values and keys named 'RemoveMe'
$ht | Remove-HashtableEntry -NullOrEmptyValues -Keys 'RemoveMe'
$ht
```

You can use `Get-Command -Module 'Hashtable'` to list available commands, and `Get-Help -Examples <CommandName>` to view command-specific examples.

## Documentation

Detailed documentation for each function is available via inline help. For more extensive documentation, please visit the 
[Hashtable docs](https://psmodule.io/Hashtable/) or [PSModule Docs](https://psmodule.io/docs).

## Contributing

Coder or not, you can contribute to the project! We welcome all contributions.

### For Users

If you don't code, your feedback is invaluable. If you encounter issues, unexpected behaviors, or missing functionality,
please submit a bug report or feature request via the project's issues page.

### For Developers

If you code, we'd love to see your contributions. Please review the [Contribution Guidelines](CONTRIBUTING.md) for more details.
You can start by picking up an existing issue or submitting a new one if you have an idea for a new feature or improvement.
