
function Add-RepoTopic{
    [CmdletBinding()]
    param(
        #Repo
        [Parameter(Position=0,ValueFromPipelineByPropertyName)][string]$Repo,
        #Topic
        [Parameter(Position=1)][string]$Topic
    )
    process{
        try{
            "Testing if repo [$repo] exists." | Write-Verbose
            "If no parameter will use local. If no owern will use default for auth user" | Write-Verbose
            gh repo edit $Repo --add-topic $Topic

        } catch {
            "Error adding topic to repo [$repo]." | Write-Error
        }
    }
} Export-ModuleMember -Function Add-RepoTopic

