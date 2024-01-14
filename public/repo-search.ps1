
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
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter()][string]$Owner
    )

    $attributes = 'name,fullName,url'

    $command = 'gh search repos {name} --match name'
    $command = $command -replace "{name}", $Name

    #check of $owner is null or whitespace
    if (-not [string]::IsNullOrWhiteSpace($Owner)) {
        $command = $command + " --owner {owner}"
        $command = $command -replace "{owner}", $Owner
    }

    $command = $command + " --json {attributes}"
    $command = $command -replace "{attributes}", $attributes

    if ($PSCmdlet.ShouldProcess("repo", $command)) {
        $ret = Invoke-GhExpression $command
    } else {
        Write-Information $command
        $ret = $null
    }

    return $ret
} Export-ModuleMember -Function Find-RepoByName

function Get-RepoCollaborators{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromPipelineByPropertyName)][Alias("fullName")][string]$RepoName
    )

    process{

        $command = 'gh api repos/{repoName}/collaborators '
        $command = $command -replace "{repoName}", "$($RepoName)"
        $command = $command -replace "{attributes}", "$($attributes)"
        
        $collaborators = Invoke-GhExpression $command
        
        $ret = foreach ($collaborator in $collaborators) {
            [PSCustomObject]@{
                Login = $collaborator.login
                Role = $collaborator.role_name
            }
        }
        
        return $ret
    }
} Export-ModuleMember -Function Get-RepoCollaborators

function Get-RepoAdmins{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromPipelineByPropertyName)][Alias("fullName")][string]$RepoName
    )

    process{

        $command = 'gh api repos/{repoName}/collaborators'
        $command = $command -replace "{repoName}", "$($RepoName)"
        $command = $command -replace "{attributes}", "$($attributes)"
        
        $collaborators = Invoke-GhExpression $command -whatif:$WhatIfPreference

        $admin = $collaborators | Where-Object {$_.role_name -eq 'admin'}

        $ret = $admin.login
        
        return $ret
    }
} Export-ModuleMember -Function Get-RepoAdmins

function Test-IsAdmin{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromPipelineByPropertyName)][Alias("fullName")][string]$RepoName,
        [Parameter()][Alias("login")][string]$User
    )

    process{

        $admins = Get-RepoAdmins -RepoName $RepoName
        
        $ret = $admins -contains $Login
        
        return $ret
    }
} Export-ModuleMember -Function IsAdmin