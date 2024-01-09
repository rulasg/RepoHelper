
Set-InvokeCommandAlias -Alias 'GetUserAccessAll' -Command 'gh api repos/{owner}/{repo}/collaborators'
Set-InvokeCommandAlias -Alias 'TestUserAccess'   -Command 'gh api repos/{owner}/{repo}/collaborators/{user}'

<#
.SYNOPSIS
    Get the list of all contributors of a repository.
#>
function Get-RepoAccess{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)] [string]$Owner,
        [Parameter(Mandatory)] [string]$Repo
    )
    
    $access = Get-UserAccess -Owner $owner -Repo $repo

    $invitations = Get-RepoAccessInvitations -Owner $owner -Repo $repo

    $ret = $access + $invitations

    return $ret
} Export-ModuleMember -Function Get-RepoAccess

<#
.SYNOPSIS
    Get the Access level of a given user
#>
function Get-RepoAccessUser{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)] [string]$Owner,
        [Parameter(Mandatory)] [string]$Repo,
        [Parameter(Mandatory)] [string]$User
    )
    
    $permissions = Get-UserAccess -Owner $owner -Repo $repo
        
    if($permissions.$user -eq $role){
        return $permissions.$user
    }

    $invitations = Get-RepoAccessInvitations -Owner $owner -Repo $repo

    if($invitations.$user -eq $role){
        return $invitations.$user
    }

    return $null
} Export-ModuleMember -Function Get-RepoAccessUser

<#
.SYNOPSIS
    Test if a user has access to a repository.
#>
function Test-RepoAccess{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$Owner,
        [Parameter(Mandatory)] [string]$Repo,
        [Parameter(Mandatory)] [string]$User
    )
    
    $param = @{ owner = $Owner ; repo = $Repo ; user = $User }

    $result = Invoke-MyCommandJson -Command TestUserAccess -Parameters $param 2> $null

    $ret = $null -eq $result

    return $ret

} Export-ModuleMember -Function Test-RepoAccess