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
            # "Result Not Found" | Write-Error
            $ret = $true
        }
    }

    end {
        return $ret
    }
}

function Test-IsNull{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Position=0,ValueFromPipeline)][object[]]$Result
    )

    begin{
        $ret = $false
    }

    process{

        if($null -eq $result ){
            # "Result is Null" | Write-Error
            $ret = $true
        }
    }

    end {
        return $ret
    }
}