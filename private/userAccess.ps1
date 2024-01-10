Set-MyInvokeCommandAlias -Alias 'GrantUserAccess'  -Command 'gh api repos/{owner}/{repo}/collaborators/{user} -X PUT -f permission="{role}"'
Set-MyInvokeCommandAlias -Alias 'RemoveUserAccess'  -Command 'gh api repos/{owner}/{repo}/collaborators/{user} -X DELETE'

function Grant-UserAccess{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)] [string]$Owner,
        [Parameter(Mandatory)] [string]$Repo,
        [Parameter(Mandatory)] [string]$User,
        [Parameter(Mandatory)]
        [ValidateSet("read", "triage", "write", "maintain", "admin")] [string]$role,
        [Parameter()][switch]$force
    )
    $param = @{ owner = $Owner ; repo = $Repo ; user = $User ; role = $role }

    # Grant access
    $result = Invoke-MyCommandJson -Command GrantUserAccess -Parameters $param

    if($result.message -eq "Not Found"){
        $ret = @{ $User = $result.message }
    } else {
        $ret = @{ $result.invitee.login = $result.permissions }
    }

    return $ret
}

function Remove-UserAccess{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)] [string]$Owner,
        [Parameter(Mandatory)] [string]$Repo,
        [Parameter(Mandatory)] [string]$User
    )

    $param = @{ owner = $Owner ; repo = $Repo ; user = $User }

    $ret = $null

    if ($PSCmdlet.ShouldProcess("User on RepoAccess List", "RemoveUserAccess")) {

        $ret = Invoke-MyCommandJson -Command RemoveUserAccess -Parameters $param

    }

    return $ret
}

function Get-UserAccess{
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
}
