
<#
.SYNOPSIS
Searches for a repository by name.

.DESCRIPTION
The Find-RepoByName function searches for a repository by name in GitHub.

.PARAMETER Name
The name words that have to be part of the repo name.

.PARAMETER Owner
Scope the search for repos of a specific owner.

.EXAMPLE
Find-RepoByName -Name "MyRepo" -Owner "MyOwner"

This example searches for a repository ownered by "MyOwner" that have "MyRepo" in the name.
#>
function Find-RepoByName{
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '', Scope='Function')]
    param(
        [Parameter()][string]$Name,
        [Parameter()][string]$Owner
    )

    $attributes = 'name,url'

    if($Owner){
        $command = 'gh search repos {name} in:name user:{owner} --json {attributes}'
        $command = $command -replace "{owner}", "$($Owner)"
    } else {
        $command = 'gh search repos {name} in:name --json {attributes}'
    }

    $command = $command -replace "{name}", "$($Name)"
    $command = $command -replace "{attributes}", "$($attributes)"

    if ($PSCmdlet.ShouldProcess("repo", $command)) {
        $ret = Invoke-GhExpression $command
    } else {
        Write-Information $command
        $ret = $null
    }

    return $ret
} Export-ModuleMember -Function Find-RepoByName
