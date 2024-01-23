Set-MyInvokeCommandAlias -Alias AddRepoIssueComment -Command "gh issue comment {issuenumber} -b '{comment}' -R {owner}/{repo}"

<#
.SYNOPSIS
    Adds a comment to an issue in a GitHub repository.
#>
function Add-RepoIssueComment{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0)] [string]$IssueNumber,
        [Parameter(Mandatory,ValueFromPipeline)] [string]$Comment,
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo
    )

    process{
        $owner,$repo = Get-Environment $Owner $Repo
        
        # Error if parameters not set. No need to check repo too.
        if([string]::IsNullOrEmpty($Owner) -or [string]::IsNullOrEmpty($Repo)){
            "[Get-RepoProperties] Owner and Repo parameters are required" | Write-Error
            return $null
        }

        $param = @{ owner = $Owner ; repo = $Repo ; issuenumber = $IssueNumber ; comment = $Comment }

        # Return the URL of the comment
        $result = Invoke-MyCommand -Command AddRepoIssueComment -Parameters $param

        $Uri = $result | Get-Uri
        if(! $Uri){
            "Error adding comment to issue $IssueNumber for $Owner/$Repo" | Write-Error
            return $null
        }

        # return the URL of the comment
        return $Uri.ToString()
    }

} Export-ModuleMember -Function Add-RepoIssueComment