# Create a function that list the repos from a repo

function Get-RepoLabels{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromPipelineByPropertyName, Position=0)][string]$Repo
    )

    process {

        $attributes = "name,description,color"
        $command = 'gh label list --json "{attributes}"'

        # add attributes if it exists
        $command = $command -replace '{attributes}', $attributes

        # add repo if it exists
        if ($Repo) { $command = $command + $(' -R "{}"' -replace '{}',$Repo) }

        # call the command
        $result = Invoke-GhExpression $command -whatif:$WhatIfPreference

        return $result
    }
} Export-ModuleMember -Function Get-RepoLabels