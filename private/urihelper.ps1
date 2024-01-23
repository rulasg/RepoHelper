function Test-Uri{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)] [string]$Uri
    )
    process {

        if([string]::IsNullOrWhiteSpace($Uri)){
            return $false
        }

        try{
            $result = [System.Uri]::new($uri)
            return $true
        }catch{
            return $false
        }
    }
}

function Get-Uri{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)] [string]$Uri
    )
    process {

        if([string]::IsNullOrWhiteSpace($Uri)){
            return $false
        }

        try{
            $result = [System.Uri]::new($uri)
            return $result
        }catch{
            return $null
        }
    }
}