

$TT_START = "<TT>"
$TT_END = "</TT>"
Set-MyInvokeCommandAlias -Alias "GetIssueComments" -Command "gh issue view {number} -R {owner}/{repo} --json title,comments"

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

        $result = Add-RepoIssueComment -IssueNumber $IssueNumber -Owner $Owner -Repo $Repo -Comment $body

        return $result
    }
} Export-ModuleMember -Function Add-RepoIssueTimeTracking -Alias "att"

function Get-RepoIssueTimeTracking{
    [CmdletBinding(SupportsShouldProcess)]
    [Alias("gtt")]
    param(
        [Parameter(Mandatory,ValueFromPipeline,Position=0)] [int]$IssueNumber,
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

    process {
        $param = @{ owner = $Owner ; repo = $Repo ; number = $IssueNumber }

        $result = Invoke-MyCommandJson -Command "GetIssueComments" -Parameters $param

        if(($null -eq $result) -or ($result | Test-NotFound )){
            "Error getting comments for issue $IssueNumber for $Owner/$Repo" | Write-Error
            return $null
        }

        $title = $result.title
        $comments = $result.comments

        $body = $comments.body
        $md = $body | ConvertFrom-Markdown
        $tags = $md.Tokens.inline | Where-Object {$_.Tag -eq $TT_END} | Select-Object -Property PreviousSibling | Select-Object -ExpandProperty PreviousSibling
        $contents = $tags.Content
        $times = $contents | ForEach-Object{$_.Text.Substring($_.Start,$_.Length)}

        $totalMinutes = 0
        foreach($time in $times){
            try {
                $totalMinutes += ConvertTo-Minutes $time
            }
            catch {
                Write-Warning -Message "Skipping Tag [ $time ]"
                Write-Warning -Message $_.Exception.Message
            }
        }

        $ret = [PSCustomObject]@{
            Title = $title
            Repo = $Repo
            Owner = $Owner
            IssueNumber = $IssueNumber
            Comments = $comments.Count
            Times = $times.Count
            TotalMinutes = $totalMinutes
            Total = ConvertTo-TimeString -Minutes $totalMinutes
        }

        return $ret
    }
} Export-ModuleMember -Function Get-RepoIssueTimeTracking -Alias "gtt"

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
} Export-ModuleMember -Function ConvertTo-TimeString