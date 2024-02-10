
function RepoHelperTest_AddRepoIssueTimeTracking_SUCCESS
{
    Reset-InvokeCommandMock

    $owner = "rulasgorg" ; $repo = "repo1" ; $issue = 1 ; $time = "1h" ; $comment = "comment"

    MockCallToString -Command "gh issue comment $issue -b `"<TT>$time</TT> $comment`" -R $owner/$repo" -OutString "https://github.com/$owner/$repo/issues/1#issuecomment-1936046674"

    $result = Add-RepoIssueTimeTracking $issue $time $comment -Owner $owner -Repo $repo

    # https://github.com/rulasgorg/repo1/issues/1#issuecomment-1936046674
    Assert-IsTrue -Condition ($result.StartsWith("https://github.com/$owner/$repo/issues/$issue#issuecomment-"))
}

function RepoHelperTest_AddRepoIssueTimeTracking_SUCCESS_NoOwnerRepo
{
    Reset-InvokeCommandMock

    $owner = "rulasgorg" ; $repo = "repo1" ; $issue = 1 ; $time = "1h" ; $comment = "comment"

    MockCallToString -Command 'git remote get-url origin 2>$null' -OutString "https://github.com/$owner/$repo.git"
    MockCallToString -Command "gh issue comment $issue -b `"<TT>$time</TT> $comment`" -R $owner/$repo" -OutString "https://github.com/$owner/$repo/issues/1#issuecomment-1936046674"

    $result = Add-RepoIssueTimeTracking $issue $time $comment

    # https://github.com/rulasgorg/repo1/issues/1#issuecomment-1936046674
    Assert-IsTrue -Condition ($result.StartsWith("https://github.com/$owner/$repo/issues/$issue#issuecomment-"))
}

function RepoHelperTest_GetRepoIssueTimeTracking_SUCCESS
{
    Reset-InvokeCommandMock

    $owner = "rulasgorg" ; $repo = "repo1" ; $issue = 2 

    MockCall -Command "gh issue view $issue -R $owner/$repo --json title,comments" -filename getIssueComments.json

    $result = Get-RepoIssueTimeTracking $issue -Owner $owner -Repo $repo

    Assert-AreEqual -Expected "Title of issue 2" -Presented $result.Title
    Assert-AreEqual -Expected $issue -Presented $result.IssueNumber
    Assert-AreEqual -Expected $repo -Presented $result.Repo
    Assert-AreEqual -Expected $owner -Presented $result.Owner
    Assert-AreEqual -Expected 5 -Presented $result.Comments
    Assert-AreEqual -Expected 3 -Presented $result.Times
    Assert-AreEqual -Expected 633 -Presented $result.TotalMinutes
    Assert-AreEqual -Expected "10h 33m" -Presented $result.Total
}

function RepoHelperTest_GetRepoIssueTimeTracking_WrongFormat
{
    Reset-InvokeCommandMock

    $owner = "rulasgorg" ; $repo = "repo1" ; $issue = 1 

    MockCall -Command "gh issue view $issue -R $owner/$repo --json title,comments" -filename getIssueComments_WrongTTFormat.json

    $result = Get-RepoIssueTimeTracking $issue -Owner $owner -Repo $repo @WarningParameters

    Assert-AreEqual -Expected 378 -Presented $result.TotalMinutes
    # Assert-Contains -Presented $warningVar.Message -Expected "Skipping Tag [ 12x ]"
    Assert-Contains -Presented $warningVar.Message -Expected "Invalid time tag: 12x"
    # Assert-Contains -Presented $warningVar.Message -Expected "Skipping Tag [ d45 ]"
    Assert-Contains -Presented $warningVar.Message -Expected "Invalid time tag: d45"
}

function RepoHelperTest_GetRepoIssueTimeTracking_Notfound
{
    Reset-InvokeCommandMock

    $owner = "rulasgorgkk" ; $repo = "repo1" ; $issue = 1

    MockCallToString -Command "gh issue view $issue -R $owner/$repo --json title,comments" -OutString "null"

    $result = Get-RepoIssueTimeTracking $issue -Owner $owner -Repo $repo @ErrorParameters

    Assert-IsNull -Object $result
    Assert-Count -Expected 1 -Presented $errorvar.exception.Message
    Assert-Contains -Presented $errorvar.exception.Message -Expected "Error getting comments for issue $issue for $owner/$repo"

}

function RepoHelperTest_GetRepoIssueTimeTrackingRecords_SUCCESS{
    Reset-InvokeCommandMock

    $owner = "rulasgorg" ; $repo = "repo1" ; $issue = 2 

    MockCall -Command "gh issue view $issue -R $owner/$repo --json title,comments" -filename getIssueComments.json

    $result = Get-RepoIssueTimeTrackingRecords $issue -Owner $owner -Repo $repo

    Assert-count -Expected 3 -Presented $result
    Assert-contains -Presented $result.Text -Expected "<TT>33m</TT> First time tracking comment"
    Assert-contains -Presented $result.Text -Expected "<TT>2h</TT> Third  time tracking comment"
    $text = @"
<TT>1d</TT> Sixth  time tracking comment
New line in comment
And Second line
"@
    Assert-contains -Presented $result.Text -Expected $text
}

function RepoHelperTest_TimeTracking_ConvertToMinutes{

    # Wrong input
    Assert-ThrowOnConvertToMinutes -Tag "1"
    Assert-ThrowOnConvertToMinutes -Tag "1z"


    # Correct input
    Assert-ConvertToMinutes -Tag "1m" -Expected 1
    Assert-ConvertToMinutes -Tag "10m" -Expected 10
    Assert-ConvertToMinutes -Tag "100m" -Expected 100
    Assert-ConvertToMinutes -Tag "1000m" -Expected 1000
    Assert-ConvertToMinutes -Tag "5h" -Expected (5*60)
    Assert-ConvertToMinutes -Tag "5d" -Expected (5*60*8)

    Assert-ConvertToMinutes -Tag "22M" -Expected (22)
    Assert-ConvertToMinutes -Tag "11H" -Expected (11*60)
    Assert-ConvertToMinutes -Tag "3D" -Expected (3*8*60)
}

function Assert-ThrowOnConvertToMinutes{
    param(
        [string]$Tag
    )

    $hasThrow = $false
    try{
        $null = ConvertTo-Minutes -Time $Tag
    }catch{
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function Assert-ConvertToMinutes{
    param(
        [string]$Tag,
        [int]$Expected
    )

    $result = ConvertTo-Minutes -Tag $Tag
    Assert-AreEqual -Expected $Expected -Presented $result
}