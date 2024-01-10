
Set-MyInvokeCommandAlias -Alias 'GetUserAccessAll' -Command 'gh api repos/{owner}/{repo}/collaborators'
Set-MyInvokeCommandAlias -Alias 'TestUserAccess'   -Command 'gh api repos/{owner}/{repo}/collaborators/{user}'

<#
.SYNOPSIS
    Get the list of all contributors of a repository.
#>
function Get-RepoAccess{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo
    )

    # Resolve repo name from parameters or environment
    $owner,$repo = Get-Environment $owner $repo
    
    # Error if parameters not set. No need to check repo too.
    if([string]::IsNullOrEmpty($Owner)){
        "Owner and Repo parameters are required" | Write-Error
        return $null
    }

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
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo,
        [Parameter(Mandatory)] [string]$User
    )

    # Resolve repo name from parameters or environment
    $owner,$repo = Get-Environment $owner $repo

    # Error if parameters not set. No need to check repo too.
    if([string]::IsNullOrEmpty($Owner)){
        "Owner and Repo parameters are required" | Write-Error
        return $null
    }

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
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo,
        [Parameter(Mandatory)] [string]$User
    )

    # Resolve repo name from parameters or environment
    $owner,$repo = Get-Environment $owner $repo
    
    # Error if parameters not set. No need to check repo too.
    if([string]::IsNullOrEmpty($Owner)){
        "Owner and Repo parameters are required" | Write-Error
        return $null
    }

    $param = @{ owner = $Owner ; repo = $Repo ; user = $User }

    $result = Invoke-MyCommandJson -Command TestUserAccess -Parameters $param 2> $null

    $ret = $null -eq $result

    return $ret

} Export-ModuleMember -Function Test-RepoAccess