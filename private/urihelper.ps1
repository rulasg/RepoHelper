function Test-Uri{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory,ValueFromPipeline)] [string]$Uri
    )
    process {

        if([string]::IsNullOrWhiteSpace($Uri)){
            return $false
        }

        try{
            $null = [System.Uri]::new($uri)
            return $true
        }catch{
            return $false
        }
    }
}

function Get-Uri{
    [CmdletBinding()]
    [OutputType([System.Uri])]
    param(
        [Parameter(Mandatory,ValueFromPipeline)] [string]$Uri
    )
    process {

        if([string]::IsNullOrWhiteSpace($Uri)){
            return $null
        }

        try{
            $result = [System.Uri]::new($uri)
            return $result
        }catch{
            return $null
        }
    }
}