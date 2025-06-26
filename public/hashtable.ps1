function Convert-HashtableToObject {
    param (
        [hashtable]$Hashtable
    )
    $Hashtable.GetEnumerator() | ForEach-Object {
        [PSCustomObject]@{
            Handle=$_.Key
            Role=$_.Value
        } 
    }
} Export-ModuleMember -Function Convert-HashtableToObject