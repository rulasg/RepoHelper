Set-MyInvokeCommandAlias -Alias 'CreateRepoPages' -Command "gh api   --method POST   /repos/{owner}/{repo}/pages  -f 'source[branch]={branch}' -f 'source[path]={path}'"
Set-MyInvokeCommandAlias -Alias 'GetRepoPages'    -Command "gh api   --method GET   /repos/{owner}/{repo}/pages"

function New-RepoPages{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo,
        [Parameter()] [string]$Branch,
        [Parameter()] [string]$Path = '/docs'
    )

    # Resolve repo name from parameters or environment
    $owner,$repo = Get-Environment $owner $repo
    
    $params = @{
        Owner = $owner
        Repo  = $repo
        Branch = $branch
        Path = $path
    }

    $Response = Invoke-MyCommandJson -Command 'CreateRepoPages' -Parameters $params

    return $Response
} Export-ModuleMember -Function New-RepoPages


function Get-RepoPages{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo
    )

    # Resolve repo name from parameters or environment
    $owner,$repo = Get-Environment $owner $repo

    $params = @{
        Owner = $owner
        Repo  = $repo
    }

    $Response = Invoke-MyCommandJson -Command 'GetRepoPages' -Parameters $params

    return $Response
} Export-ModuleMember -Function Get-RepoPages

    


