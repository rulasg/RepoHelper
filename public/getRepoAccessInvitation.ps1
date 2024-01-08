Set-InvokeCommandAlias -Alias 'GetUserAccessInvitations'   -Command 'gh api repos/{owner}/{repo}/invitations'
Set-InvokeCommandAlias -Alias 'CancelRepoAccessInvitation' -Command 'gh api repos/{owner}/{repo}/invitations/{invitation_id} -X DELETE'

<#
.SYNOPSIS
    Get the actual invitations list of a repository.
#>
function Get-RepoAccessInvitations{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)] [string]$Owner,
        [Parameter(Mandatory)] [string]$Repo,
        [Parameter()][switch]$Ids
    )
    
    $param = @{
        owner = $Owner
        repo = $Repo
    }

    $ret = @{}

    $result = Invoke-MyCommandJson -Command GetUserAccessInvitations -Parameters $param

    foreach ($item in $result) {

        $ret += @{
            $item.invitee.login = $Ids ? $result.id : $result.permissions
        }
    }

    return $ret
} Export-ModuleMember -Function Get-RepoAccessInvitations


function Remove-RepoAccessInvitation{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$Owner,
        [Parameter(Mandatory)] [string]$Repo,
        [Parameter(Mandatory)] [string]$User
    )

    $invitations = Get-RepoAccessInvitations -Owner $Owner -Repo $Repo -Ids

    if (-not $invitations.ContainsKey($User)) {
        Write-Warning "User $User not found in invitations list."
        return $null
    }

    $invitation_Id = $invitations.$User

    $param = @{
        owner = $Owner
        repo = $Repo
        invitation_id = $invitation_Id
    }

    $result = Invoke-MyCommandJson -Command CancelRepoAccessInvitation -Parameters $param

    return $result
} Export-ModuleMember -Function Remove-RepoAccessInvitation