

$TT_START = "<TT>"
$TT_END = "</TT>"
Set-MyInvokeCommandAlias -Alias "GetIssueComments" -Command "gh issue view {number} -R {owner}/{repo} --json {attributes}"

<#
.SYNOPSIS
    Adds time tracking to an issue in a GitHub repository.
#>
function Add-RepoIssueTimeTracking{
    [CmdletBinding(SupportsShouldProcess)]
    [Alias("att")]
    param(
        [Parameter(Mandatory,Position=0)] [int]$IssueNumber,
        [Parameter(Mandatory,Position=1)] [string]$Time,
        [Parameter(Mandatory,Position=2)] [string]$Comment,
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo
    )

    begin{
        $owner,$repo = Get-Environment $Owner $Repo
        
        # Error if parameters not set. No need to check repo too.
        if([string]::IsNullOrEmpty($Owner) -or [string]::IsNullOrEmpty($Repo)){
            "[Add-RepoIssueTimeTracking] Owner and Repo parameters are required" | Write-Error
            return $null
        }
    }

    process {
        $timeTag = $TT_START+"{time}"+$TT_END
        $timeTag = $timeTag -replace "{time}",$Time

        $body = "$timeTag $Comment"

        $result = Add-RepoIssueComment -IssueNumber $IssueNumber -Owner $Owner -Repo $Repo -Comment $body -WhatIf:$WhatIfPreference

        return $result
    }
} Export-ModuleMember -Function Add-RepoIssueTimeTracking -Alias "att"

<#
.SYNOPSIS
    Gets time tracking from an issue in a GitHub repository.
#>
function Get-RepoIssueTimeTracking{
    [CmdletBinding()]
    [Alias("gtt")]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)][Alias("Number")][int]$IssueNumber,
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo
    )

    begin{
        $owner,$repo = Get-Environment $Owner $Repo
        
        # Error if parameters not set. No need to check repo too.
        if([string]::IsNullOrEmpty($Owner) -or [string]::IsNullOrEmpty($Repo)){
            "[Get-RepoIssueTimeTracking] Owner and Repo parameters are required" | Write-Error
            return $null
        }
    }

    process{
        $result = GetRepoIssueTimeTracking -IssueNumber $IssueNumber -Owner $Owner -Repo $Repo

        if($null -eq $result){
            return $null
        }

        $ret = [PSCustomObject]@{
            Title = $result.title
            Repo = $result.Repo
            Owner = $result.Owner
            IssueNumber = $result.IssueNumber
            Comments = $result.Comments
            Times = $result.Times
            TotalMinutes = $result.TotalMinutes
            Total = $result.Total
            Url = $result.url
        }

        return $ret
    }
} Export-ModuleMember -Function Get-RepoIssueTimeTracking -Alias "gtt"

<#
.SYNOPSIS
    Gets time tracking records from an issue in a GitHub repository.
#>
function Get-RepoIssueTimeTrackingRecords{
    [CmdletBinding()]
    [Alias("gttr")]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)][Alias("Number")][int]$IssueNumber,
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo
    )

    begin{
        $owner,$repo = Get-Environment $Owner $Repo
        
        # Error if parameters not set. No need to check repo too.
        if([string]::IsNullOrEmpty($Owner) -or [string]::IsNullOrEmpty($Repo)){
            "[Get-RepoIssueTimeTrackingRecords] Owner and Repo parameters are required" | Write-Error
            return $null
        }
    }

    process{
        $result = GetRepoIssueTimeTracking -IssueNumber $IssueNumber -Owner $Owner -Repo $Repo

        $ret = @()
        foreach($record in $result.Records){
            $ret += [PSCustomObject]@{
                Number = $IssueNumber
                Text = $record.Text
                Time = $record.Time
                CreatedAt = $record.CreatedAt
                Repo = $Repo
                Owner = $Owner
                Url = $record.Url
            }
        }

        return $ret
    }
} Export-ModuleMember -Function Get-RepoIssueTimeTrackingRecords -Alias "gttr"

function GetRepoIssueTimeTracking{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [int]$IssueNumber,
        [Parameter(Mandatory)] [string]$Owner,
        [Parameter(Mandatory)] [string]$Repo
    )

    process {
        $param = @{ owner = $Owner ; repo = $Repo ; number = $IssueNumber ; attributes = 'title,comments,url'}

        $result = Invoke-MyCommandJson -Command "GetIssueComments" -Parameters $param

        if(($null -eq $result) -or ($result | Test-NotFound )){
            "Error getting comments for issue $IssueNumber for $Owner/$Repo" | Write-Error
            return $null
        }

        $title = $result.title
        $url = $result.url
        $comments = $result.comments

        $totalMinutes = 0
        $totalTimes = 0
        $records = @()

        foreach ($comment in $comments){

            $body = $comment.body
            $md = $body | ConvertFrom-Markdown
            $tags = $md.Tokens.inline | Where-Object {$_.Tag -eq $TT_END} | Select-Object -Property PreviousSibling | Select-Object -ExpandProperty PreviousSibling
            $contents = $tags.Content

            # Skipp comments without time tags
            If($null -eq $contents){ continue }

            $commentTotalMinutes = 0

            # We allow to have more than one time tag in a comment
            foreach($content in $contents){
                $totalTimes++

                $time = $content.Text.Substring($content.Start,$content.Length)
                
                #Control the time tag syntax
                try { $commentTotalMinutes += ConvertTo-Minutes $time}
                catch {
                    Write-Warning -Message "Skipping Tag [ $time ] $text"
                    Write-Warning -Message $_.Exception.Message
                }
            }

            $totalMinutes += $commentTotalMinutes

            $records += [PSCustomObject]@{
                Time = $commentTotalMinutes
                Text = $comment.body
                CreatedAt = $comment.createdAt
                Url = $comment.url
            }
        }

        $ret = [PSCustomObject]@{
            Title = $title
            Repo = $Repo
            Owner = $Owner
            IssueNumber = $IssueNumber
            Comments = $comments.Count
            Times = $totalTimes
            Records = $records
            TotalMinutes = $totalMinutes
            Total = ConvertTo-TimeString -Minutes $totalMinutes
            Url = $url
        }

        return $ret
    }
} 

<#
.SYNOPSIS
    Converts a time tag to minutes.
#>
function ConvertTo-Minutes([string] $Tag){
    # TODO: Implemnet
    # calculate the time based on m,h,d
    if (-not ($Tag -match "^\d+[mhd]$")) {
        throw "Invalid time tag: $Tag"
    }

    "Match found: $($matches[0])" | Write-Verbose
    [int] $number = $Tag -replace '\D', '' # Remove non-digit characters
    $char = $Tag -replace '\d', '' # Remove digit characters

     switch ($char.ToLower()) {
        'm' { $time = $number } # Minutes
        'h' { $time = $number * 60 } # Hours
        'd' { $time = $number * 60 * 8 } # Days
        Default {
            throw "Invalid time tag: $Tag"
        }
    }
    return $time
} Export-ModuleMember -Function ConvertTo-Minutes

function ConvertTo-TimeString([int] $Minutes){
    $hours = [math]::Floor($Minutes / 60)
    $minutes = $Minutes % 60

    $ret = "{0}h {1}m" -f $hours,$minutes
    return $ret
}