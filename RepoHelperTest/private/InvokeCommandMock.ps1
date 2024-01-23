# Managing dependencies
$MODULE_INVOKATION_TAG = "RepoHelperModule_Mock"

function Set-InvokeCommandMock{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)][string]$Alias,
        [Parameter(Mandatory,Position=1)][string]$Command
    )

    InvokeHelper\Set-InvokeCommandAlias -Alias $Alias -Command $Command -Tag $MODULE_INVOKATION_TAG
}

function Reset-InvokeCommandMock{
    [CmdletBinding()]
    param()

    InvokeHelper\Reset-InvokeCommandAlias -Tag $MODULE_INVOKATION_TAG
}