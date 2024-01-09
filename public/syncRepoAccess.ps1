<#
.SYNOPSIS
    Synchronize the access of a list of users to a repository.
#>
function Sync-RepoAccess{
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory,Position=0)][ValidateSet("read", "triage", "write", "maintain", "admin")] [string]$role,
        [Parameter(Mandatory,Position=1)] [string]$FilePath,
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo
    )
    # Resolve repor form parameters and environment
    $env = Get-Environment -Owner $owner -Repo $repo
    
    # Error if parameters not set
    if($null -eq $env){
        "Owner and Repo parameters are required" | Write-Error
        return $null
    }

    $ret = @{}

    # Read users from file
    $users = Get-UsersFromFile -Path $FilePath

    if(-not $?){
        "Error reading user file $file" | Write-Error
        return $null
    }

    # Get current permissions and invitations
    $permissions = Get-RepoAccess -Owner $env.owner -Repo $env.repo
    $invitations = Get-RepoAccessInvitations -Owner $env.owner -Repo $env.repo

    # Update or add existing users
    foreach($user in $users){

        # Already invited to this role
        if($invitations.$user -eq $role){
            $ret.$user = "?"
            continue
        }
        
        # Already granted to this role
        if($permissions.$user -eq $role){
            $ret.$user = "="
            continue
        }

        # Check if it has granted a different role
        if($permissions.ContainsKey($user)){
            $status = "+ ($($permissions.$user))"
        } else {
            $status = "+"
        }

        # Force to avoid the call to check if the access is already set
        if ($PSCmdlet.ShouldProcess("Target", "Operation")) {
            $result = Grant-RepoAccess -Owner $env.Owner -Repo $env.Repo -User $user -Role $role -Force
            
            if($result.$user -eq $role.ToLower()){
                $ret.$user = $status
            } else {
                $ret.$user = $status
            }
        } else {
            $ret.$user = $status
        }
    }

    # Delete non existing users

    $usersToDelete = $Permissions.Keys | Where-Object { $users -notcontains $_ }

    # Just remove the users that where set to $role
    $usersToDelete = $usersToDelete | Where-Object { $Permissions.$_ -eq $role}

    foreach($userToDelete in $usersToDelete){
        
        if ($PSCmdlet.ShouldProcess("Target", "Operation")) {
            $result = Remove-RepoAccess -Owner $owner -Repo $repo -User $userToDelete

            if($null -eq $result){
                $ret.$userToDelete += "-"
            } else {
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