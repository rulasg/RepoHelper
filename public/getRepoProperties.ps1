Set-MyInvokeCommandAlias -Alias 'GetRepoInformation' -Command 'gh api repos/{owner}/{repo}'

<#
.SYNOPSIS
    Gets the custom properties of a repository.
#>
function Get-RepoProperties{
    [CmdletBinding()]
    param(
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo
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

    $resultjson = Invoke-MyCommand -Command GetRepoInformation -Parameters $param

    $result = $resultjson | ConvertFrom-Json -AsHashtable

    if($null -eq $result){
        "Error getting repo information" | Write-Error
        return $null
    }
    $IsEmpty = [string]::IsNullOrEmpty($result.custom_properties)
    $ret = $IsEmpty ? @{} : $result.custom_properties

    $ret.Owner = $Owner
    $ret.Repo = $Repo

    "Repo found custom_properties on [$owner/$repo] : " | Write-Verbose
    $ret | Format-List | Out-String | Write-Verbose

    return [PsCustomObject]$ret
} Export-ModuleMember -Function Get-RepoProperties