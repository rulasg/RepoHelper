
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

    MockCall -Command "gh issue view $issue -R $owner/$repo --json title,comments,url" -filename getIssueComments.json

    $result = Get-RepoIssueTimeTracking $issue -Owner $owner -Repo $repo

    Assert-AreEqual -Expected "Title of issue 2" -Presented $result.Title
    Assert-AreEqual -Expected $issue -Presented $result.IssueNumber
    Assert-AreEqual -Expected $repo -Presented $result.Repo
    Assert-AreEqual -Expected $owner -Presented $result.Owner
    Assert-AreEqual -Expected 5 -Presented $result.Comments
    Assert-AreEqual -Expected 3 -Presented $result.Times
    Assert-AreEqual -Expected 633 -Presented $result.TotalMinutes
    Assert-AreEqual -Expected "10h 33m" -Presented $result.Total
    Assert-AreEqual -Expected "https://github.com/$owner/$repo/issues/$issue" -Presented $result.Url
}

function RepoHelperTest_GetRepoIssueTimeTracking_SUCCESS_SeveralTimesInSingleComment
{
    Reset-InvokeCommandMock

    $owner = "rulasgorg" ; $repo = "repo1" ; $issue = 3 

    MockCall -Command "gh issue view $issue -R $owner/$repo --json title,comments,url" -filename getIssueComments_MultiTimesInComment.json

    $result = Get-RepoIssueTimeTracking $issue -Owner $owner -Repo $repo

    Assert-AreEqual -Expected "Issue3 Repo1" -Presented $result.Title
    Assert-AreEqual -Expected $issue -Presented $result.IssueNumber
    Assert-AreEqual -Expected $repo -Presented $result.Repo
    Assert-AreEqual -Expected $owner -Presented $result.Owner
    Assert-AreEqual -Expected 2 -Presented $result.Comments
    Assert-AreEqual -Expected 6 -Presented $result.Times
    Assert-AreEqual -Expected 231 -Presented $result.TotalMinutes
    Assert-AreEqual -Expected "3h 51m" -Presented $result.Total
    Assert-AreEqual -Expected "https://github.com/$owner/$repo/issues/$issue" -Presented $result.Url


}

function RepoHelperTest_GetRepoIssueTimeTracking_WrongFormat
{
    Reset-InvokeCommandMock

    $owner = "rulasgorg" ; $repo = "repo1" ; $issue = 1 

    MockCall -Command "gh issue view $issue -R $owner/$repo --json title,comments,url" -filename getIssueComments_WrongTTFormat.json

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

    MockCallToString -Command "gh issue view $issue -R $owner/$repo --json title,comments,url" -OutString "null"

    $result = Get-RepoIssueTimeTracking $issue -Owner $owner -Repo $repo @ErrorParameters

    Assert-IsNull -Object $result
    Assert-Count -Expected 1 -Presented $errorvar.exception.Message
    Assert-Contains -Presented $errorvar.exception.Message -Expected "Error getting comments for issue $issue for $owner/$repo"

}

function RepoHelperTest_GetRepoIssueTimeTracking_Pipe
{
    Reset-InvokeCommandMock

    $owner = "rulasgorgkk" ; $repo = "repo1" ; $attributes = "title,comments,url" ; $attributes2 = "number,title,url"

    MockCall -Command "gh issue list -R $owner/$repo --json $attributes2" -filename getIssueList.json

    MockCall -Command "gh issue view 1 -R $owner/$repo --json $attributes" -filename getIssueComments.json
    MockCall -Command "gh issue view 4 -R $owner/$repo --json $attributes" -filename getIssueComments_2.json
    MockCall -Command "gh issue view 8 -R $owner/$repo --json $attributes" -filename getIssueComments.json
    MockCall -Command "gh issue view 21 -R $owner/$repo --json $attributes" -filename getIssueComments_2.json
    MockCall -Command "gh issue view 12 -R $owner/$repo --json $attributes" -filename getIssueComments.json

    $result = Get-RepoIssue -Owner $owner -Repo $repo

    $result = $result | Get-RepoIssueTimeTracking -Owner $Owner -Repo $repo

    Assert-Count -Expected 5 -Presented $result
    
    $issue = $result | Where-Object {$_.IssueNumber -eq 4}
    
    Assert-AreEqual -Presented $issue.Title        -Expected  "Title of issue 2"
    Assert-AreEqual -Presented $issue.Repo         -Expected  "repo1"
    Assert-AreEqual -Presented $issue.Owner        -Expected  "rulasgorgkk"
    Assert-AreEqual -Presented $issue.IssueNumber  -Expected  4
    Assert-AreEqual -Presented $issue.Comments     -Expected  5
    Assert-AreEqual -Presented $issue.Times        -Expected  3
    Assert-AreEqual -Presented $issue.TotalMinutes -Expected  110
    Assert-AreEqual -Presented $issue.Total        -Expected  "1h 50m"

    $issue =  $result | Where-Object {$_.IssueNumber -eq 12}

    Assert-AreEqual -Presented $issue.Title        -Expected  "Title of issue 2"
    Assert-AreEqual -Presented $issue.Repo         -Expected  "repo1"
    Assert-AreEqual -Presented $issue.Owner        -Expected  "rulasgorgkk"
    Assert-AreEqual -Presented $issue.IssueNumber  -Expected  12
    Assert-AreEqual -Presented $issue.Comments     -Expected  5
    Assert-AreEqual -Presented $issue.Times        -Expected  3
    Assert-AreEqual -Presented $issue.TotalMinutes -Expected  633
    Assert-AreEqual -Presented $issue.Total        -Expected  "10h 33m"
}

function RepoHelperTest_GetRepoIssueTimeTrackingRecords_Pipe
{
    Reset-InvokeCommandMock

    $owner = "rulasgorgkk" ; $repo = "repo1" ; $attributes = "title,comments,url" ; $attributes2 = "number,title,url"

    MockCall -Command "gh issue list -R $owner/$repo --json $attributes2" -filename getIssueList.json

    MockCall -Command "gh issue view 1 -R $owner/$repo --json $attributes" -filename getIssueComments.json
    MockCall -Command "gh issue view 4 -R $owner/$repo --json $attributes" -filename getIssueComments_2.json
    MockCall -Command "gh issue view 8 -R $owner/$repo --json $attributes" -filename getIssueComments.json
    MockCall -Command "gh issue view 21 -R $owner/$repo --json $attributes" -filename getIssueComments_2.json
    MockCall -Command "gh issue view 12 -R $owner/$repo --json $attributes" -filename getIssueComments.json

    $result = Get-RepoIssue -Owner $owner -Repo $repo 

    $result = $result | Get-RepoIssueTimeTrackingRecords -Owner $Owner -Repo $repo

    Assert-Count -Expected 15 -Presented $result

    
    $issueRecords = $result | Where-Object {$_.Number -eq 4}
    Assert-Count -Expected 3 -Presented $issueRecords
    $expectedJson = @"
[
  {
    "Number": 4,
    "Text": "<TT>11m</TT> First time tracking comment",
    "Time": 11,
    "CreatedAt": "2024-02-10T07:28:36Z",
    "Repo": "repo1",
    "Owner": "rulasgorgkk",
    "Url": "https://github.com/rulasgorg/repo1/issues/2#issuecomment-1936914856"
  },
  {
    "Number": 4,
    "Text": "<TT>33m</TT> Third  time tracking comment",
    "Time": 33,
    "CreatedAt": "2024-02-10T07:30:43Z",
    "Repo": "repo1",
    "Owner": "rulasgorgkk",
    "Url": "https://github.com/rulasgorg/repo1/issues/2#issuecomment-1936915371"
  },
  {
    "Number": 4,
    "Text": "<TT>66m</TT> Sixth  time tracking comment\nNew line in comment\nAnd Second line",
    "Time": 66,
    "CreatedAt": "2024-02-10T07:32:50Z",
    "Repo": "repo1",
    "Owner": "rulasgorgkk",
    "Url": "https://github.com/rulasgorg/repo1/issues/2#issuecomment-1936915977"
  }
]
"@
    Assert-AreEqual -Expected $expectedJson -Presented ($issueRecords | ConvertTo-Json)


    $issue =  $result | Where-Object {$_.Number -eq 12}

    Assert-Count -Expected 3 -Presented $issue
    $expectedJson = @"
[
  {
    "Number": 12,
    "Text": "<TT>33m</TT> First time tracking comment",
    "Time": 33,
    "CreatedAt": "2024-02-10T07:28:36Z",
    "Repo": "repo1",
    "Owner": "rulasgorgkk",
    "Url": "https://github.com/rulasgorg/repo1/issues/2#issuecomment-1936914856"
  },
  {
    "Number": 12,
    "Text": "<TT>2h</TT> Third  time tracking comment",
    "Time": 120,
    "CreatedAt": "2024-02-10T07:30:43Z",
    "Repo": "repo1",
    "Owner": "rulasgorgkk",
    "Url": "https://github.com/rulasgorg/repo1/issues/2#issuecomment-1936915371"
  },
  {
    "Number": 12,
    "Text": "<TT>1d</TT> Sixth  time tracking comment\nNew line in comment\nAnd Second line",
    "Time": 480,
    "CreatedAt": "2024-02-10T07:32:50Z",
    "Repo": "repo1",
    "Owner": "rulasgorgkk",
    "Url": "https://github.com/rulasgorg/repo1/issues/2#issuecomment-1936915977"
  }
]
"@
    Assert-AreEqual -Expected $expectedJson -Presented ($issue | ConvertTo-Json)
}

function RepoHelperTest_GetRepoIssueTimeTrackingRecords_SUCCESS{
    Reset-InvokeCommandMock

    $owner = "rulasgorg" ; $repo = "repo1" ; $issue = 2 

    MockCall -Command "gh issue view $issue -R $owner/$repo --json title,comments,url" -filename getIssueComments.json

    $result = Get-RepoIssueTimeTrackingRecords $issue -Owner $owner -Repo $repo

    Assert-count -Expected 3 -Presented $result

    # Text
    $resultText = $result.Text | ConvertTo-Json
    $textExpected = @"
[
  "<TT>33m</TT> First time tracking comment",
  "<TT>2h</TT> Third  time tracking comment",
  "<TT>1d</TT> Sixth  time tracking comment\nNew line in comment\nAnd Second line"
]
"@
    Assert-AreEqual -Expected $textExpected -Presented $resultText

    # CreatedAt
    Assert-Contains -Expected (Get-Date -Date "February 10, 2024 7:28:36 AM") -Presented $result.CreatedAt
    Assert-Contains -Expected (Get-Date -Date "February 10, 2024 7:30:43 AM") -Presented $result.CreatedAt
    Assert-Contains -Expected (Get-Date -Date "February 10, 2024 7:32:50 AM") -Presented $result.CreatedAt
}

function RepoHelperTest_GetRepoIssueTimeTrackingRecord_SUCCESS_SeveralTimesInSingleComment
{
    Reset-InvokeCommandMock

    $owner = "rulasgorg" ; $repo = "repo1" ; $issue = 3 

    MockCall -Command "gh issue view $issue -R $owner/$repo --json title,comments,url" -filename getIssueComments_MultiTimesInComment.json

    $result = Get-RepoIssueTimeTrackingRecords $issue -Owner $owner -Repo $repo
    $resultText = $result.Text | ConvertTo-Json
    $expectedText = @"
[
  "- [ ] <TT>11m</TT> For 1 task\r\n- [x] <TT>22m</TT> For 2 task\r\n- [ ] <TT>33m</TT> For 3 task",
  "- [ ] <TT>44m</TT> For 4 task\r\n- [x] <TT>55m</TT> For 5 task\r\n- [ ] <TT>66m</TT> For 6 task"
]
"@

    Assert-count -Expected 2 -Presented $result
    Assert-AreEqual -Expected $expectedText -Presented $resultText
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