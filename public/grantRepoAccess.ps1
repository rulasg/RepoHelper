

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

        $userRole = Get-RepoAccessUser -Owner $owner -Repo $repo -User $user

        if($userRole -eq $role){
            return @{ $user = $userRole }
        }
    }

    # Remove preivouse access
    $result = Remove-RepoAccess -Owner $owner -Repo $repo -User $user
    if($null -ne $result){
        "Issues removing access for user" | Write-Warning
    }

    # Grant access
    $result = Grant-UserAccess -Owner $owner -Repo $repo -User $user -Role $role

    return $result

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

    $ret = $null

    if ($PSCmdlet.ShouldProcess("User on RepoAccess List", "RemoveUserAccess")) {

        $result1 = Remove-UserAccess -Owner $owner -Repo $repo -User $user

        $result2 = Remove-RepoAccessInvitation -Owner $owner -Repo $repo -User $user
        
        $ret = $result1 + $result2
    }

    return $ret

} Export-ModuleMember -Function Remove-RepoAccess
