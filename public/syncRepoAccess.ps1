<#
.SYNOPSIS
    Synchronize the access of a list of users to a repository.
#>
function Sync-RepoAccess{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory,Position=0)][ValidateSet("read", "triage", "write", "maintain", "admin")] [string]$Role,
        [Parameter(Mandatory,Position=1)] [string]$FilePath,
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo
    )
    # Resolve repor form parameters and environment
    $Owner,$Repo = Get-Environment $Owner $Repo

    # Error if parameters not set. No need to check repo too.
    if([string]::IsNullOrEmpty($Owner) -or [string]::IsNullOrEmpty($Repo)){
        "[Sync-RepoAccess] Owner and Repo parameters are required" | Write-Error
        return $null
    }

    "Syncing access $role to $Owner/$Repo from $FilePath" | Write-Verbose

    $ret = @{}

    # Read users from file
    $users = Get-UsersFromFile -Path $FilePath

    if($null -eq $users){
        "Error reading user file $FilePath" | Write-Error
        return $null
    }

    "Found $($users.Count) users" | Write-Verbose

    # Get current permissions and invitations
    $permissions = Get-UserAccess -Owner $Owner -Repo $Repo

    if($null -eq $permissions){
        "Error getting current permissions" | Write-Error
        $permissions = @{}
    }

    $invitations = Get-RepoAccessInvitations -Owner $Owner -Repo $Repo

    if($null -eq $invitations){
        "Error getting current invitations. Check if you are on a personal account. Try Verbose for more information." | Write-Verbose
        $invitations = @{}
    }

    "Found [$($permissions.Count)] permissions granted" | Write-Verbose
    "Found [$($invitations.Count)] invitations pending" | Write-Verbose

    # Update or add existing users
    foreach($user in $users){

        "Processing $user for role $role" | Write-Verbose

        # Already invited to this role
        if($invitations.$user -eq $role){
            "User $user has an invitation pending" | Write-Verbose
            $ret.$user = "?"
            continue
        }
        
        # Already granted to this role
        if($permissions.$user -eq $role){
            "User $user already has this role" | Write-Verbose
            $ret.$user = "="
            continue
        }

        # Check if it has granted a different role
        "User $user needs to be granted $role" | Write-Verbose
        if($permissions.ContainsKey($user)){
            "User $user has already granted role $($permissions.$user)" | Write-Verbose
            $status = "+ ($($permissions.$user))"
        } elseif ($invitations.ContainsKey($user)){
            "User $user has already an invitation pending for role $($invitations.$user)" | Write-Verbose
            $status = "+ ($($invitations.$user))"
        } else {
            "User $user has no access" | Write-Verbose
            $status = "+"
        }
        "Status: $status" | Write-Verbose

        # Force to avoid the call to check if the access is already set
        if ($PSCmdlet.ShouldProcess("User $user", "Grant-RepoAccess -Owner $Owner -Repo $Repo -User $user -Role $role -Force")) {

            "Calling - Grant-RepoAccess -Owner $Owner -Repo $Repo -User $user -Role $role -Force" | Write-Verbose
            $result = Grant-RepoAccess -Owner $Owner -Repo $Repo -User $user -Role $role -Force
            
            if($result.$user -eq $role.ToLower()){
                "User $user granted $role" | Write-Verbose
                $ret.$user = $status
            } else {
                "Error granting $role to $user" | Write-Verbose
                $ret.$user = "X"
            }
        } else {
            $ret.$user = $status
        }
    }

    # Delete non existing users
    "Deleting users that are granted but not in the list" | Write-Verbose

    # Just remove the users that where set to $role
    $usersToDelete = $Permissions.Keys | Where-Object { $users -notcontains $_ }
    $usersToDelete = $usersToDelete | Where-Object { $Permissions.$_ -eq $role}

    "Found $($usersToDelete.Count) users to delete" | Write-Verbose

    foreach($userToDelete in $usersToDelete){

        "Deleting $userToDelete access $role to $Owner/$Repo" | Write-Verbose
        
        if ($PSCmdlet.ShouldProcess("User $userToDelete", "Remove-RepoAccess -Owner $owner -Repo $repo -User $userToDelete")) {
            $result = Remove-RepoAccess -Owner $owner -Repo $repo -User $userToDelete

            if($null -eq $result){
                "Deleted $role grant for $userToDelete" | Write-Verbose
                $ret.$userToDelete += "-"
            } else {
                "Error deleting $role grant for $userToDelete" | Write-Verbose
                $ret.$userToDelete += 'X -'
            }
        } else {
            $ret.$userToDelete += "-"
        }
    }

    return $ret

} Export-ModuleMember -Function Sync-RepoAccess

function Get-UsersFromFile{
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)] [string]$Path
    )

    $users = @()

    $content = Get-Content -Path $Path

    if(-not $?){
        return $null
    }

    foreach($line in $content){
        $line = $line.Trim()
        if($line -eq ""){
            continue
        }
        if($line.StartsWith("#")){
            continue
        }

        $users += $line
    }

    return $users
}