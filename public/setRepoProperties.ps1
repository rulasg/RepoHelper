
# Documentation is not clear enough to describe the GH command to set a property.
# Found working command with curl command.
# Using this version until we can refactor to GH comand.
# This command works
# curl -L -H "Authorization: Bearer $env:GH_TOKEN" -X PATCH https://api.github.com/repos/solidifydemo/bit21/properties/values -d '{"properties":[{"property_name":"kk","value":"kkvalue23"}]}'
$cmd = @'
curl -L -s -H "Authorization: Bearer {token}" -X PATCH https://api.github.com/repos/{owner}/{repo}/properties/values -d '{"properties":[{"property_name":"{name}","value":"{value}"}]}'
'@

Set-MyInvokeCommandAlias -Alias SetRepoProperty -Command $cmd

<#
.SYNOPSIS
    Sets the custom properties of a repository.
#>
function Set-RepoProperty{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo,
        [Parameter(Mandatory)] [string]$Name,
        [Parameter(Mandatory)] [string]$Value
    )

    # Resolve repor form parameters and environment
    $Owner,$Repo = Get-Environment $Owner $Repo

    # Error if parameters not set. No need to check repo too.
    if([string]::IsNullOrEmpty($Owner) -or [string]::IsNullOrEmpty($Repo)){
        "[Get-RepoProperties] Owner and Repo parameters are required" | Write-Error
        return $null
    }

    "Setting property $Name to $Value for $Owner/$Repo" | Write-Verbose

    $token = Get-UserToken

    $param = @{ owner = $Owner ; repo = $Repo ; name = $Name ; value = $Value ; token= $token}

    if($PSCmdlet.ShouldProcess("$Owner/$Repo","Set property $Name to $Value")){
        $result = Invoke-MyCommandJson -Command SetRepoProperty -Parameters $param
    }

    if($null -ne $result){
        "Error setting property $Name to $Value for $Owner/$Repo" | Write-Error
    }
    
    return $null
} Export-ModuleMember -Function Set-RepoProperty

function Get-UserToken{
    $token = $env:GH_TOKEN
    if($null -eq $token){
        "GH_TOKEN environment variable is not set" | Write-Error
        return $null
    }
    return $token
}

