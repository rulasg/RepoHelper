
Set-InvokeCommandAlias -Alias 'GetUserAccessAll' -Command 'gh api repos/{owner}/{repo}/collaborators'
Set-InvokeCommandAlias -Alias 'GetUserAccess'    -Command 'gh api repos/{owner}/{repo}/collaborators/{user}/permission'
Set-InvokeCommandAlias -Alias 'TestUserAccess'   -Command 'gh api repos/{owner}/{repo}/collaborators/{user}'

function Get-RepoAccessAll{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$Owner,
        [Parameter(Mandatory)] [string]$Repo
    )
    
    $param = @{
        owner = $Owner
        repo = $Repo
    }

    $ret = @{}

    $result = Invoke-MyCommandJson -Command GetUserAccessAll -Parameters $param

    foreach ($item in $result) {
        $ret += @{
            $item.login = $item.role_name
        }
    }

    return $ret
} Export-ModuleMember -Function Get-RepoAccessAll

function Get-RepoAccess{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$Owner,
        [Parameter(Mandatory)] [string]$Repo,
        [Parameter(Mandatory)] [string]$User
    )
    
    $param = @{
        owner = $Owner
        repo = $Repo
        user = $User
    }

    $result = Invoke-MyCommandJson -Command GetUserAccess -Parameters $param

    return $result.permission

} Export-ModuleMember -Function Get-RepoAccess
