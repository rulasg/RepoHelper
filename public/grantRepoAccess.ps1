

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
    if([string]::IsNullOrEmpty($Owner) -or [string]::IsNullOrEmpty($Repo)){
        "[Grant-RepoAccess] Owner and Repo parameters are required" | Write-Error
        return $null
    }

    "Granting access $role to $Owner/$Repo for $User" | Write-Verbose

    if(!$force){

        "Checking if user $user already has access $role on $Owner/$Repo" | Write-Verbose

        $userRole = Get-RepoAccessUser -Owner $Owner -Repo $Repo -User $User

        if($userRole -eq $role){
            "User $user already has access $role on $Owner/$Repo" | Write-Verbose
            return @{ $User = $userRole }
        } else {
            "User $user does not have access $role on $Owner/$Repo" | Write-Verbose
        }
    } else {
        "Force flag set. Skipping check if user $user already has access $role on $Owner/$Repo" | Write-Verbose
    }

    # Remove preivouse access
    "Removing previous access for $User in $Owner/$Repo if any" | Write-Verbose
    $result = Remove-RepoAccess -Owner $Owner -Repo $Repo -User $User
    if($null -ne $result){
        "Issues removing access for user" | Write-Warning
    }

    # Grant access
    "Granting access $role to $Owner/$Repo for $User" | Write-Verbose

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
    if([string]::IsNullOrEmpty($Owner) -or [string]::IsNullOrEmpty($Repo)){
        "[Remove-RepoAccess] Owner and Repo parameters are required" | Write-Error
        return $null
    }

    $ret = $null

    if ($PSCmdlet.ShouldProcess("User on RepoAccess List", "RemoveUserAccess")) {

        "Removing access for $User in $Owner/$Repo" | Write-Verbose
        $result1 = Remove-UserAccess -Owner $Owner -Repo $Repo -User $User

        "Removing access invitation for $User in $Owner/$Repo" | Write-Verbose
        $result2 = Remove-RepoAccessInvitation -Owner $Owner -Repo $Repo -User $User
        
        $ret = $result1 + $result2
    }

    return $ret

} Export-ModuleMember -Function Remove-RepoAccess
