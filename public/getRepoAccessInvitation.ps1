Set-InvokeCommandAlias -Alias 'GetUserAccessInvitations'   -Command 'gh api repos/{owner}/{repo}/invitations'

function Get-RepoAccessInvitations{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$Owner,
        [Parameter(Mandatory)] [string]$Repo
    )
    
    $param = @{
        owner = $Owner
        repo = $Repo
    }

    $ret = @{}

    $result = Invoke-MyCommandJson -Command GetUserAccessInvitations -Parameters $param

    foreach ($item in $result) {
        $ret += @{
            $item.invitee.login = $item.permissions
        }
    }

    return $ret
} Export-ModuleMember -Function Get-RepoAccessInvitations