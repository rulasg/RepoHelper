function Invoke-GhExpression {
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '', Scope='Function')]
    param(
        [Parameter(Position=0)][string]$Command
    )

    if ($PSCmdlet.ShouldProcess("Target", $Command)) {
        Invoke-Expression $Command | ConvertFrom-Json
    } else {
        Write-Information $Command
    }
}