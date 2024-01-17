function Invoke-MyCommandJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Command,
        [Parameter(Position=1)][hashtable]$Parameters
    )

    # Tracing the command
    "Invoking [$Command]" | Write-Verbose
    $param | Out-String | Write-Verbose

    # Verbose preference calculation
    $IsVerbose = $VerbosePreference -eq 'Continue'

    # Invoke the command
    InvokeHelper\Invoke-MyCommandJson -Command $Command -Parameters $Parameters -Verbose:$IsVerbose
}
