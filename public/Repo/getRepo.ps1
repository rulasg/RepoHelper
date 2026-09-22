Set-MyInvokeCommandAlias -Alias "GetRepo" -Command "gh api repos/{owner}/{repo}"

function Get-Repo{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Owner,
        [Parameter(Mandatory, Position = 1)][string]$Repo
    )

    $params = @{
        owner = $Owner
        repo  = $Repo
        attributes = "defaultBranchRef"
    }

    $response =Invoke-MyCommandJson -Command GetRepo -Parameters $params 

    if(-not $response){
        return $null
    }
    
    return $response
} Export-ModuleMember -Function Get-Repo
