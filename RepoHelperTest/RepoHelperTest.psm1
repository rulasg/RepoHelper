
# Managing dependencies
$MODULE_INVOKATION_TAG = "RepoHelperModule_Mock"

function Set-InvokeCommandMock{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0)][string]$Alias,
        [Parameter(Mandatory,Position=1)][string]$Command
    )

    InvokeHelper\Set-InvokeCommandAlias -Alias $Alias -Command $Command -Tag $MODULE_INVOKATION_TAG
}

#Module path is where resides the RootModule file. This file. :)
$MODULE_PATH = $PSScriptRoot

#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $MODULE_PATH\public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $MODULE_PATH\private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($Public + $Private))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Here I might...
# Read in or create an initial config file and variable
# Export Public functions ($Public.BaseName) for WIP modules
# Set variables visible to the module and its functions only

Export-ModuleMember -Function RepoHelperTest_*

# Disable calling dependencies
# This requires that all dependecies are called through mocks
Disable-InvokeCommandAlias -Tag "RepoHelperModule"

