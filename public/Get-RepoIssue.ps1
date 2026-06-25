Set-MyInvokeCommandAlias -Alias 'GetRepoissues' -Command 'gh issue list -R {owner}/{repo} -S "{searchpatter}" --json {attributes} -L 1000 -s {state}'


function Get-RepoIssue{
    [CmdletBinding()]
    param(
        [Parameter(Position=0)] [string]$Owner,
        [Parameter(Position=1)] [string]$Repo,
        [Parameter(Position=2)] [string]$SearchPattern,
        [Parameter()][switch] $IncludeClosed
    )

    $attributes = "number,title,state,url"

    # Resolve repo name from parameters or environment
    $Owner,$Repo = Get-Environment $Owner $Repo

    # Error if parameters not set. No need to check repo too.
    if([string]::IsNullOrEmpty($Owner) -or [string]::IsNullOrEmpty($Repo)){
        Write-Error "Owner and Repo parameters are required."
        return
    }

    $params = @{
        owner = $Owner
        repo  = $Repo
        attributes = $attributes
        searchpatter = $SearchPattern
        state = $($IncludeClosed) ? 'all' : 'open'
    }

    $responseJson = Invoke-MyCommand -Command GetRepoissues -Parameters $params

    $response = $responseJson | ConvertFrom-Json -AsHashtable
    
    # TODO: Check if the response is correct

    $ret = @()

    # Add extra attributes
    $response | ForEach-Object {
        $_.Owner = $Owner
        $_.Repo = $Repo

        $ret += [PSCustomObject]$_
    }
    
    return $ret
} Export-ModuleMember -Function Get-RepoIssue