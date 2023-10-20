function Get-RepoSeedTemplate{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromPipelineByPropertyName, Position=0)][string]$Repo
    )

    process {
        $attributes = 'templateRepository'

        $command = 'gh repo view'

        # add repo to command if $repo not null
        if ($Repo) { $command = $command + " $repo"}

        # add attributes to command
        $command = $command + " --json {attributes}" -replace "{attributes}", "$($attributes)"

        $result = Invoke-GhExpression $command -whatif:$WhatIfPreference

        $ret = $result ? $("{0}/{1}" -f $result.templateRepository.owner.login, $result.templateRepository.name) : $null

        return $ret
    }
} Export-ModuleMember -Function Get-RepoSeedTemplate