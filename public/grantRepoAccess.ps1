
Set-InvokeCommandAlias -Alias 'GrantUserAccess'  -Command 'gh api repos/{owner}/{repo}/collaborators/{user} -X PUT -f permission="{role}"'
Set-InvokeCommandAlias -Alias 'RemoveUserAccess'  -Command 'gh api repos/{owner}/{repo}/collaborators/{user} -X DELETE'

function Grant-RepoAccess{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$owner,
        [Parameter(Mandatory)] [string]$repo,
        [Parameter(Mandatory)] [string]$user,
        [Parameter(Mandatory)]
        [ValidateSet("read", "triage", "write", "maintain", "admin")] [string]$role
    )
    
    # gh api repos/solidifycustomers/bit21/collaborators/raulgeu -X PUT -f permission='triage'

    $permission = Get-RepoAccess -Owner $owner -Repo $repo -User $user

    if($permission -eq $role){
        Write-Warning "User $user already has $role access to $owner/$repo"
        return
    }

    $param = @{
        owner = $owner
        repo = $repo
        user = $user
        role = $role
    }

    $result = Invoke-MyCommandJson -Command GrantUserAccess -Parameters $param

    $ret = $result.permission

    return $ret

} Export-ModuleMember -Function Grant-RepoAccess

function Remove-RepoAccess{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$owner,
        [Parameter(Mandatory)] [string]$repo,
        [Parameter(Mandatory)] [string]$user
    )

    $param = @{
        owner = $owner
        repo = $repo
        user = $user
    }

    $result = Invoke-MyCommandJson -Command RemoveUserAccess -Parameters $param

    return $result

} Export-ModuleMember -Function Remove-RepoAccess
