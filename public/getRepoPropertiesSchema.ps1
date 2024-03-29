
Set-MyInvokeCommandAlias -Alias 'GetRepoPropertiesSchema' -Command 'gh api orgs/{owner}/properties/schema'

<#
.SYNOPSIS
    Gets the schema of repo custom properties or a org
#>
function Get-RepoPropertiesSchema{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)] [string]$Owner
    )

    # Resolve repor form parameters and environment
    $Owner = Get-EnvironmentOwner $Owner

    # Error if parameters not set. No need to check repo too.
    if([string]::IsNullOrEmpty($Owner)){
        "[Get-RepoPropertiesSchema] Owner parameter is required" | Write-Error
        return $null
    }

    "Getting schema for $Owner" | Write-Verbose

    $param = @{ owner = $Owner }

    $result = Invoke-MyCommandJson -Command GetRepoPropertiesSchema -Parameters $param

    if($null -eq $result){
        "Error getting repo information" | Write-Error
        return $null
    }

    # Filter null values.
    # Seen null values in the schema on the beta version
    $result = $result.Where({ $null -ne $_ })

    # $IsEmpty = $result.Count -eq 0
    $IsEmpty = [string]::IsNullOrEmpty($result[0].property_name)
    $ret = $IsEmpty ? $null : $result

    "Repo Properties Schema for org [$owner] : " | Write-Verbose
    $ret | Format-List | Out-String | Write-Verbose

    return $ret
} Export-ModuleMember -Function Get-RepoPropertiesSchema