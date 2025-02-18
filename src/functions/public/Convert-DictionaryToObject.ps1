function Convert-DictionaryToPSObject {
    param(
        # You can use either a strongly-typed dictionary or just a hashtable
        [Parameter(Mandatory)]
        [System.Collections.IDictionary] $Dictionary
    )

    # Using an ordered hashtable so properties appear in the same order as the dictionary
    $ht = [ordered]@{}

    foreach ($key in $Dictionary.Keys) {
        # If you're worried about invalid PowerShell property names (like keys with special characters),
        # you might do some sanitization here; otherwise, you can use the raw key.
        $ht[$key] = $Dictionary[$key]
    }

    # Cast the hashtable to a PSCustomObject
    return [PSCustomObject]$ht
}

# Example usage:

# If you have a hashtable
$hash = @{
    FirstName = 'Alice'
    LastName  = 'Smith'
    Age       = 30
}

$psObjFromHash = Convert-DictionaryToPSObject -Dictionary $hash
$psObjFromHash  # Inspect the PSCustomObject


# If you have a .NET Dictionary[string,object]
$dict = New-Object 'System.Collections.Generic.Dictionary[string, object]'
$dict['City'] = 'London'
$dict['Country'] = 'UK'

$psObjFromDict = Convert-DictionaryToPSObject -Dictionary $dict
$psObjFromDict  # Inspect the PSCustomObject
