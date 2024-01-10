
Set-MyInvokeCommandAlias -Alias 'GetRepoRemoteUrl' -Command 'git remote get-url origin 2>$null'

function Get-Environment{
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [string]$Repo
    )

    if(-Not [string]::IsNullOrWhiteSpace($Owner) -and -Not [string]::IsNullOrWhiteSpace($Repo)){
        return $Owner, $Repo
    }

    # Get remote repo name
    $url = Invoke-MyCommand -Command GetRepoRemoteUrl
    if($null -ne $url){

        $remoteRepo = $url | Split-Path -Leafbase
        $remoteOwner = $url | Split-Path -Parent | Split-Path -Leafbase
    }

    # Default Owner
    if([string]::IsNullOrWhiteSpace($Owner)){
        $Owner = $remoteOwner
    }

    # Default Owner
    if([string]::IsNullOrWhiteSpace($Repo)){
        $Repo = $remoteRepo
    }

    if ($null -eq $Owner -eq $Owner){
        return $null
    }

    return $Owner, $Repo
}
