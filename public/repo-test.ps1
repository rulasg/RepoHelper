
function Test-Repo{
    [CmdletBinding()]
    param(
        #Repo
        [Parameter(Position=0,ValueFromPipelineByPropertyName)][string]$Repo
    )
    process{
        try{
            "Testing if repo [$repo] exists." | Write-Verbose
            "If no parameter will use local. If no owern will use default for auth user" | Write-Verbose
            gh repo view $Repo *>&1 | Out-Null
            return $?
        } catch {
            return $false
        }
    }
} Export-ModuleMember -Function Test-Repo

