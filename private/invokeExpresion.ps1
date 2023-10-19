function Invoke-GhExpression {
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '', Scope='Function')]
    param(
        [Parameter(Position=0)][string]$Command
    )

    if ($PSCmdlet.ShouldProcess("Target", $command)) {
        $result = Invoke-Expression $Command | ConvertFrom-Json
    } else {
        Write-Information $command
        $result = $null
    }

    return $result
}