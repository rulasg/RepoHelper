function Test-NotFound{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline)][object]$Result
    )


     if($result.message -eq "Not Found" ){
        "Result not Found $owner/$repo" | Write-Error
        return $true
     }

     return $false
}