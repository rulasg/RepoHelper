Set-MyInvokeCommandAlias -Alias 'GetUserAccessInvitations'   -Command 'gh api repos/{owner}/{repo}/invitations --paginate'
Set-MyInvokeCommandAlias -Alias 'CancelRepoAccessInvitation' -Command 'gh api repos/{owner}/{repo}/invitations/{invitation_id} -X DELETE'

<#
.SYNOPSIS
    Get the actual invitations list of a repository.
#>
function Get-RepoAccessInvitations{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo,
        [Parameter()][switch]$Ids
    )

    # Resolve repo name from parameters or environment
    $owner,$repo = Get-Environment $owner $repo

    # Error if parameters not set. No need to check repo too.
    if([string]::IsNullOrEmpty($Owner) -or [string]::IsNullOrEmpty($Repo)){
        "[Get-RepoAccessInvitations] Owner and Repo parameters are required" | Write-Error
        return $null
    }

    "Getting access invitations for $role to $Owner/$Repo from $FilePath" | Write-Verbose

    $param = @{ owner = $Owner ; repo = $Repo }

    $ret = @{}

    $result = Invoke-MyCommandJson -Command GetUserAccessInvitations -Parameters $param

    if($result | Test-NotFound){ return }

    # Check if we are on a private accoutn and not org account.
    # This error is returned when the repo is a personal account repo with no invitations possible
    if($result.message -eq 'Resource not accessible by integration'){
        "No access invitations for $role to $Owner/$Repo" | Write-Verbose
        "Very possibly this repo is a personal account repo with no invitations possible" | Write-Verbose
        return $null
    }

    "Found $($result.count) invitations for role $role" | Write-Verbose

    foreach ($item in $result) {

        $ret += @{
            $item.invitee.login = $Ids ? $result.id : $result.permissions
        }
    }

    return $ret
} Export-ModuleMember -Function Get-RepoAccessInvitations

function Remove-RepoAccessInvitation{
    [CmdletBinding()]
    param(
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo,
        [Parameter(Mandatory)] [string]$User
    )

    # Resolve repo name from parameters or environment
    $owner,$repo = Get-Environment $owner $repo
    
    # Error if parameters not set. No need to check repo too.
    if([string]::IsNullOrEmpty($Owner) -or [string]::IsNullOrEmpty($Repo)){
        "[Remove-RepoAccessInvitation] Owner and Repo parameters are required" | Write-Error
        return $null
    }

    "Removing access invitation for $User to $Owner/$Repo" | Write-Verbose

    $invitations = Get-RepoAccessInvitations -Owner $Owner -Repo $Repo -Ids

    "Found $($invitations.Count) invitations on $Owner/$Repo" | Write-Verbose

    if (-not $invitations.ContainsKey($User)) {
        Write-Warning "User $User not found in invitations list."
        return $null
    }

    "Found invitation for $User [$($invitations.$User)] on $Owner/$Repo" | Write-Verbose

    $invitation_Id = $invitations.$User

    $param = @{ owner = $Owner ; repo = $Repo ; invitation_id = $invitation_Id }

    "Invoking CancelRepoAccessInvitation with parameters:" | Write-Verbose
    $param | Convertto-Json -Depth 1 | Write-Verbose

    $result = Invoke-MyCommandJson -Command CancelRepoAccessInvitation -Parameters $param

    return $result
} Export-ModuleMember -Function Remove-RepoAccessInvitation