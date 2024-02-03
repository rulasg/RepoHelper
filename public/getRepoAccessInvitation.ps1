Set-MyInvokeCommandAlias -Alias 'GetUserAccessInvitations'   -Command 'gh api repos/{owner}/{repo}/invitations'
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
    if([string]::IsNullOrEmpty($Owner)){
        "Owner and Repo parameters are required" | Write-Error
        return $null
    }

    $param = @{ owner = $Owner ; repo = $Repo }

    $ret = @{}

    $result = Invoke-MyCommandJson -Command GetUserAccessInvitations -Parameters $param

    if($result | Test-NotFound){ return }

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
    if([string]::IsNullOrEmpty($Owner)){
        "Owner and Repo parameters are required" | Write-Error
        return $null
    }

    $invitations = Get-RepoAccessInvitations -Owner $Owner -Repo $Repo -Ids

    if (-not $invitations.ContainsKey($User)) {
        Write-Warning "User $User not found in invitations list."
        return $null
    }

    $invitation_Id = $invitations.$User

    $param = @{ owner = $Owner ; repo = $Repo ; invitation_id = $invitation_Id }

    $result = Invoke-MyCommandJson -Command CancelRepoAccessInvitation -Parameters $param

    return $result
} Export-ModuleMember -Function Remove-RepoAccessInvitation