function Convert-ObjectToDictionary {
    param(
        [Parameter(Mandatory)]
        $Object
    )

    # If you know your keys should be strings
    $dictionary = New-Object 'System.Collections.Generic.Dictionary[System.String, System.Object]'

    # Grab the “Properties” collection from the PSObject
    foreach ($prop in $Object.PSObject.Properties) {
        # Filter only note/alias/other relevant property types if you like
        $dictionary[$prop.Name] = $prop.Value
    }

    return $dictionary
}

# Example usage:
$psObj = [PSCustomObject]@{
    FirstName = 'Alice'
    LastName  = 'Smith'
    Age       = 30
}

$dict = Convert-PSObjectToDictionary $psObj
$dict
