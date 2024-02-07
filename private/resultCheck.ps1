function Test-NotFound{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline)][object[]]$Result
    )

    begin{
        $ret = $false
    }

    process{

        if($result.message -eq "Not Found" ){
            "Result not Found $owner/$repo" | Write-Error
            $ret = $true
        }
    }

    end {
        return $ret
    }
}