Set-MyInvokeCommandAlias -Alias 'GetRepoInformation' -Command 'gh api repos/{owner}/{repo}'

<#
.SYNOPSIS
    Gets the custom properties of a repository.
#>
function Get-RepoProperties{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)] [string]$Owner,
        [Parameter(Mandatory,Position=1)] [string]$Repo
    )

    # Resolve repor form parameters and environment
    $Owner,$Repo = Get-Environment $Owner $Repo

    # Error if parameters not set. No need to check repo too.
    if([string]::IsNullOrEmpty($Owner) -or [string]::IsNullOrEmpty($Repo)){
        "[Get-RepoProperties] Owner and Repo parameters are required" | Write-Error
        return $null
    }

    "Getting properties for $Owner/$Repo" | Write-Verbose

    $param = @{ owner = $Owner ; repo = $Repo }

    $result = Invoke-MyCommandJson -Command GetRepoInformation -Parameters $param

    if($null -eq $result){
        "Error getting repo information" | Write-Error
        return $null
    }
    $IsEmpty = [string]::IsNullOrEmpty($result.custom_properties)
    $ret = $IsEmpty ? $null : $result.custom_properties

    "Repo found custom_properties on [$owner/$repo] : " | Write-Verbose
    $ret | Format-List | Out-String | Write-Verbose

    return $ret
} Export-ModuleMember -Function Get-RepoProperties