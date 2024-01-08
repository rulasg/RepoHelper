
Set-InvokeCommandAlias -Alias 'GrantUserAccess'  -Command 'gh api repos/{owner}/{repo}/collaborators/{user} -X PUT -f permission="{role}"'
Set-InvokeCommandAlias -Alias 'RemoveUserAccess'  -Command 'gh api repos/{owner}/{repo}/collaborators/{user} -X DELETE'

<#
.SYNOPSIS
    Grant a user access to a repository.
#>
function Grant-RepoAccess{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)] [string]$owner,
        [Parameter(Mandatory)] [string]$repo,
        [Parameter(Mandatory)] [string]$user,
        [Parameter(Mandatory)]
        [ValidateSet("read", "triage", "write", "maintain", "admin")] [string]$role,
        [Parameter()][switch]$force
    )

    if(!$force){

        $permission = Get-RepoAccess -Owner $owner -Repo $repo -User $user
        
        if($permission -eq $role){
            return @{ $user = $permission }
        }
    }

    $param = @{ owner = $owner ; repo = $repo ; user = $user ; role = $role }

    $result = Invoke-MyCommandJson -Command GrantUserAccess -Parameters $param

    if($result.message -eq "Not Found"){
        $ret = @{ $user = $result.message }
    } else {
        $ret = @{ $result.invitee.login = $result.permissions }
    }

    return $ret

} Export-ModuleMember -Function Grant-RepoAccess

<#
.SYNOPSIS
    Remove a user access to a repository.
#>
function Remove-RepoAccess{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)] [string]$owner,
        [Parameter(Mandatory)] [string]$repo,
        [Parameter(Mandatory)] [string]$user
    )

    $param = @{ owner = $owner ; repo = $repo ; user = $user }

    $ret = $null

    if ($PSCmdlet.ShouldProcess("User on RepoAccess List", "RemoveUserAccess")) {

        $result1 = Invoke-MyCommandJson -Command RemoveUserAccess -Parameters $param

        $result2 = Remove-RepoAccessInvitation -Owner $owner -Repo $repo -User $user
        
        $ret = $result1 + $result2
    }

    return $ret

} Export-ModuleMember -Function Remove-RepoAccess
