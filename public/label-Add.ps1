#Create a function that creates a label using GH Cli

function Add-RepoLabel{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromPipelineByPropertyName)][string]$Name,
        [Parameter(ValueFromPipelineByPropertyName)][string]$Color,
        [Parameter(ValueFromPipelineByPropertyName)][string]$Description,
        [Parameter(ValueFromPipelineByPropertyName)][string]$Repo,
        [Parameter(ValueFromPipelineByPropertyName)][switch]$Force
    )
    
    process {

        $command = 'gh label create "{name}"'
        $command = $command -replace '{name}', $Name

        # add description if it exists
        if ($Description) { $command = $command + $(' -d "{}"' -replace '{}',$Description) }

        # add color if it exists
        if ($Color) { $command = $command + $(' -c "{}"' -replace '{}',$Color) }

        # add repo if it exists
        if ($Repo) { $command = $command + $(' -R "{}"' -replace '{}',$Repo) }

        # add force if it exists
        if ($Force) { $command = $command + ' -f' }

        $result = Invoke-GhExpression $command -whatif:$WhatIfPreference

        return $result

    }
} Export-ModuleMember -Function Add-RepoLabel

function Import-RepoLabels{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0)][string]$Path,
        [Parameter(Mandatory,Position=1)][string]$Repo,
        [Parameter()][switch]$Force
    )

    process {
        "Importing labels to $repo from $Path" | Write-Verbose

        $labels = Get-Content $Path | ConvertFrom-Json

        foreach ($label in $labels) {
            "Importing label $label" | Write-Verbose
            $null = $label | Add-RepoLabel -Repo $repo -WhatIf:$WhatIfPreference -Force:$Force
        }

    }
} Export-ModuleMember -Function Import-RepoLabels