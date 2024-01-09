
Set-InvokeCommandAlias -Alias 'GetRepoRemoteUrl' -Command 'git remote get-url origin 2>$null'

function Get-Environment{
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0)] [string]$Owner,
        [Parameter(Position = 1)] [string]$Repo
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

    if ($null -eq $owner -eq $owner){
        return $null
    }

    return $owner, $repo
}
