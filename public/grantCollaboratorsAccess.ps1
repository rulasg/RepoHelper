
Set-InvokeCommandAlias -Alias 'GrantUserAccess' -Command 'gh api repos/{owner}/{repo}/collaborators/{user} -X PUT -f permission="{role}"'

function Grant-RepoAccess{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] [string]$owner,
        [Parameter(Mandatory=$true)] [string]$repo,
        [Parameter(Mandatory=$true)] [string]$user,
        [Parameter(Mandatory=$true)]
        [ValidateSet("read", "triage", "write", "maintain", "admin")] [string]$role
    )
    
    # gh api repos/solidifycustomers/bit21/collaborators/raulgeu -X PUT -f permission='triage'

    $param = @{
        owner = $owner
        repo = $repo
        user = $user
        role = $role
    }

    $result = Invoke-MyCommandJson -Command GrantUserAccess -Parameters $param

    return $result
} Export-ModuleMember -Function Grant-RepoAccess