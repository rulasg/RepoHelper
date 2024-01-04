
Set-InvokeCommandAlias -Alias 'GrantUserAccess'  -Command 'gh api repos/{owner}/{repo}/collaborators/{user} -X PUT -f permission="{role}"'
Set-InvokeCommandAlias -Alias 'GetUserAccessAll' -Command 'gh api repos/{owner}/{repo}/collaborators'
Set-InvokeCommandAlias -Alias 'GetUserAccess' -Command 'gh api repos/{owner}/{repo}/collaborators/{user}/permission'

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

function Get-RepoAccessAll{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] [string]$Owner,
        [Parameter(Mandatory=$true)] [string]$Repo
    )
    
    $param = @{
        owner = $Owner
        repo = $Repo
    }

    $ret = @{}

    $result = Invoke-MyCommandJson -Command GetUserAccessAll -Parameters $param

    foreach ($item in $result) {
        $ret += @{
            $item.login = $item.role_name
        }
    }

    return $ret
} Export-ModuleMember -Function Get-RepoAccessAll

function Get-RepoAccess{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] [string]$Owner,
        [Parameter(Mandatory=$true)] [string]$Repo,
        [Parameter(Mandatory=$true)] [string]$User
    )
    
    $param = @{
        owner = $Owner
        repo = $Repo
        user = $User
    }

    $result = Invoke-MyCommandJson -Command GetUserAccess -Parameters $param

    return $result.permission

} Export-ModuleMember -Function Get-RepoAccess