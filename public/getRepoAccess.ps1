
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
    
    $param = @{ owner = $Owner ; repo = $Repo }

    $ret = @{}

    $result = Invoke-MyCommandJson -Command GetUserAccessAll -Parameters $param

    foreach ($item in $result) {
        $ret += @{
            $item.login = $item.role_name
        }
    }

    return $ret
} Export-ModuleMember -Function Get-RepoAccess

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