# create a function that deletes a label using GH Cli

function Remove-RepoLabel{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Name,
        [Parameter()][string]$Repo
    )

    process{
        $command = 'gh label delete "{name}" --yes'
        $command = $command -replace '{name}', $Name

        # add repo if it exists
        if ($Repo) { $command = $command + $(' -R "{}"' -replace '{}',$Repo) }

        $result = Invoke-GhExpression $command -whatif:$WhatIfPreference

        return $result
    }
} Export-ModuleMember -Function Remove-RepoLabel