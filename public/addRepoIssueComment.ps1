Set-MyInvokeCommandAlias -Alias AddRepoIssueComment -Command 'gh issue comment {issuenumber} -b "{comment}" -R {owner}/{repo}'
Set-MyInvokeCommandAlias -Alias ListRepoIssues -Command "gh issue list -R {owner}/{repo} --json {attributes}"

<#
.SYNOPSIS
    Adds a comment to an issue in a GitHub repository.
#>
function Add-RepoIssueComment{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0)] [string]$IssueNumber,
        [Parameter(Mandatory,Position=1)] [string]$Comment,
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo
    )

    process{
        $owner,$repo = Get-Environment $Owner $Repo
        
        # Error if parameters not set. No need to check repo too.
        if([string]::IsNullOrEmpty($Owner) -or [string]::IsNullOrEmpty($Repo)){
            "[Add-RepoIssueComment] Owner and Repo parameters are required" | Write-Error
            return $null
        }

        $param = @{ owner = $Owner ; repo = $Repo ; issuenumber = $IssueNumber ; comment = $Comment }

        # Return the URL of the comment
        if($PSCmdlet.ShouldProcess("$Owner/$Repo","Add comment to issue $IssueNumber")){
            $result = Invoke-MyCommand -Command AddRepoIssueComment -Parameters $param
        }

        # if(($result | Test-NotFound) -or ($result | Test-IsNull) -or  (-Not ($result | Get-Uri))){
        if(($null -eq $result) -or ($result | Test-NotFound ) -or (-Not ($result | Get-Uri))){
            "Error adding comment to issue $IssueNumber for $Owner/$Repo" | Write-Error
            return $null
        }

        # return the URL of the comment
        return $result
    }

} Export-ModuleMember -Function Add-RepoIssueComment

<#
.SYNOPSIS
    Adds a comment to an issue in a GitHub repository.
#>
function Get-RepoIssue{
    [CmdletBinding()]
    [Alias("gri")]
    param(
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo
    )

    process{
        $owner,$repo = Get-Environment $Owner $Repo
        
        # Error if parameters not set. No need to check repo too.
        if([string]::IsNullOrEmpty($Owner) -or [string]::IsNullOrEmpty($Repo)){
            "[Get-RepoIssue] Owner and Repo parameters are required" | Write-Error
            return $null
        }

        $param = @{ owner = $Owner ; repo = $Repo; attributes="number,title,url" }

        # Return the URL of the comment
        $result = Invoke-MyCommandJson -Command ListRepoIssues -Parameters $param

        if($result | Test-NotFound){
            Write-Error -Message "Repo not found"
            return
        }

        return $result
    }

} Export-ModuleMember -Function Get-RepoIssue -Alias "gri"