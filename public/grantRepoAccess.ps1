

<#
.SYNOPSIS
    Grant a user access to a repository.
#>
function Grant-RepoAccess{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo,
        [Parameter(Mandatory)] [string]$User,
        [Parameter(Mandatory)]
        [ValidateSet("read", "triage", "write", "maintain", "admin")] [string]$role,
        [Parameter()][switch]$force
    )

    # Resolve repor form parameters and environment
    $Owner,$Repo = Get-Environment $Owner $Repo

    # Error if parameters not set. No need to check repo too.
    if([string]::IsNullOrEmpty($Owner)){
        "Owner and Repo parameters are required" | Write-Error
        return $null
    }

    if(!$force){

        $userRole = Get-RepoAccessUser -Owner $Owner -Repo $Repo -User $User

        if($userRole -eq $role){
            return @{ $User = $userRole }
        }
    }

    # Remove preivouse access
    $result = Remove-RepoAccess -Owner $Owner -Repo $Repo -User $User
    if($null -ne $result){
        "Issues removing access for user" | Write-Warning
    }

    # Grant access
    $result = Grant-UserAccess -Owner $Owner -Repo $Repo -User $User -Role $role

    return $result

} Export-ModuleMember -Function Grant-RepoAccess

<#
.SYNOPSIS
    Remove a user access to a repository.
#>
function Remove-RepoAccess{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo,
        [Parameter(Mandatory)] [string]$User
    )

    # Resolve repor form parameters and environment
    $Owner,$Repo = Get-Environment $Owner $Repo

    # Error if parameters not set. No need to check repo too.
    if([string]::IsNullOrEmpty($Owner)){
        "Owner and Repo parameters are required" | Write-Error
        return $null
    }

    $ret = $null

    if ($PSCmdlet.ShouldProcess("User on RepoAccess List", "RemoveUserAccess")) {

        $result1 = Remove-UserAccess -Owner $Owner -Repo $Repo -User $User

        $result2 = Remove-RepoAccessInvitation -Owner $Owner -Repo $Repo -User $User
        
        $ret = $result1 + $result2
    }

    return $ret

} Export-ModuleMember -Function Remove-RepoAccess
