
Set-InvokeCommandAlias -Alias 'GetRepoRemoteUrl' -Command 'git remote get-url origin 2>$null'

function Get-Environment{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo
    )

    $url = Invoke-MyCommand -Command GetRepoRemoteUrl
    if($null -ne $url){

        $remoteRepo = $url | Split-Path -Leafbase
        $remoteOwner = $url | Split-Path -Parent | Split-Path -Leafbase
    }

    # Default owner
    if([string]::IsNullOrWhiteSpace($Owner)){
        $Owner = $remoteOwner
    }

    # Default owner
    if([string]::IsNullOrWhiteSpace($Repo)){
        $Repo = $remoteRepo
    }

    if ($null -eq $repo -eq $owner){
        return $null
    }

    return [PSCustomObject]@{
        Repo = $Repo
        Owner = $Owner
        RepoWithOwner = "$Owner/$Repo"
    }
}
