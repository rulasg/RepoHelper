Set-InvokeCommandAlias -Alias 'GetUserAccessInvitations'   -Command 'gh api repos/{owner}/{repo}/invitations'

<#
.SYNOPSIS
    Get the actual invitations list of a repository.
#>
function Get-RepoAccessInvitations{
    [CmdletBinding()]
    [OutputType([hashtable])]
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