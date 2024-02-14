function RepoHelperTest_AddRepoIssueComment_Success{

    Reset-InvokeCommandMock

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $issueNumber = '1' ; $comment = 'This is a comment'

    $mockUrl = "https://api.github.com/repos/{owner}/{repo}/issues/{issueNumber}#issuecomment-1906504801"
    $mockUrl = $mockUrl -replace '{owner}',$owner -replace '{repo}',$repo -replace '{issueNumber}',$issueNumber

    MockCallToString -Command "gh issue comment $issueNumber -b `"$comment`" -R $owner/$repo" -OutString $mockUrl

    $result = Add-RepoIssueComment -Owner $owner -Repo $repo -IssueNumber $issueNumber -Comment $comment

    Assert-AreEqual -Expected $mockUrl -Presented $result
}

function RepoHelperTest_AddRepoIssueComment_Success_minimalCommand{

    Reset-InvokeCommandMock

    $owner = 'orgName' ; $repo = 'repoName' ; $issueNumber = '1' ; $comment = 'This is a comment'

    MockCallToString -Command 'git remote get-url origin 2>$null' -OutString "https://github.com/$owner/$repo.git"

    $mockUrl = "https://api.github.com/repos/$owner/$repo/issues/$issueNumber#issuecomment-1906504801"
    MockCallToString -Command "gh issue comment $issueNumber -b `"$comment`" -R $owner/$repo" -OutString $mockUrl


    $result = Add-RepoIssueComment $issueNumber $comment

    Assert-AreEqual -Expected $mockUrl -Presented $result
}

function RepoHelperTest_AddRepoIssueComment_WrongIssueNumber{

    Reset-InvokeCommandMock

    $owner = 'orgName' ; $repo = 'repoName' ; $issueNumber = '1' ; $comment = 'This is a comment'

    $mockUrl = "https://api.github.com/repos/{owner}/{repo}/issues/{issueNumber}#issuecomment-1906504801"
    $mockUrl = $mockUrl -replace '{owner}',$owner -replace '{repo}',$repo -replace '{issueNumber}',$issueNumber

    MockCallToNull -Command "gh issue comment $issueNumber -b `"$comment`" -R $owner/$repo"

    $result = Add-RepoIssueComment -Owner $owner -Repo $repo -IssueNumber $issueNumber -Comment $comment @ErrorParameters

    Assert-IsNull -Object $result
    Assert-Count -Expected 1 -Presented $errorvar
    Assert-Contains -Expected "Error adding comment to issue $issueNumber for $owner/$repo" -Presented $errorvar.exception.Message
}

function RepoHelperTest_GetRepoIssues_Success{

    Reset-InvokeCommandMock

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $attributes="number,title,url"

    MockCall -Command "gh issue list -R $owner/$repo --json $attributes" -filename getIssueList.json

    $result = Get-RepoIssue -Owner $owner -Repo $repo

    Assert-Count -Expected 5 -Presented $result

    Assert-Contains -Expected 12 -Presented $result.number
    Assert-Contains -Expected "comment development 12" -Presented $result.title

}