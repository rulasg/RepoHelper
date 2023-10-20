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

# This code is not working. Invoke-Expression is not piping output to Error stream
# for later check the error from gh cli and manage it at module level
# the pipe when calling gh directly works fine

# function Invoke-GhExpression {
#     [CmdletBinding(SupportsShouldProcess)]
#     [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '', Scope='Function')]
#     param(
#         [Parameter(Position=0)][string]$Command
#     )

#     if ($PSCmdlet.ShouldProcess("Target", $command)) {
#         $result = Invoke-Expression $Command 2>&1

#         if ($result -is [System.Management.Automation.ErrorRecord]) {
#             Write-Error $result
#             $result = $null
#         } else {
#             $result = $result | ConvertFrom-Json
#         }
#     } else {
#         Write-Information $command
#         $result = $null
#     }

#     return $result
# }