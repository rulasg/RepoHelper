function Test_AddRepoIssueComment_Success{

    Reset-InvokeCommandMock

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $number = '1' ; $comment = 'This is a comment'

    $mockUrl = "https://api.github.com/repos/{owner}/{repo}/issues/{number}#issuecomment-1906504801"
    $mockUrl = $mockUrl -replace '{owner}',$owner -replace '{repo}',$repo -replace '{number}',$number

    MockCallToString -Command "gh issue comment $number -b `"$comment`" -R $owner/$repo" -OutString $mockUrl

    $result = Add-RepoIssueComment -Owner $owner -Repo $repo -Number $number -Comment $comment

    Assert-AreEqual -Expected $mockUrl -Presented $result
}

function Test_AddRepoIssueComment_Success_minimalCommand{

    Reset-InvokeCommandMock

    $owner = 'orgName' ; $repo = 'repoName' ; $number = '1' ; $comment = 'This is a comment'

    MockCallToString -Command 'git remote get-url origin 2>$null' -OutString "https://github.com/$owner/$repo.git"

    $mockUrl = "https://api.github.com/repos/$owner/$repo/issues/$number#issuecomment-1906504801"
    MockCallToString -Command "gh issue comment $number -b `"$comment`" -R $owner/$repo" -OutString $mockUrl


    $result = Add-RepoIssueComment $number $comment

    Assert-AreEqual -Expected $mockUrl -Presented $result
}

function Test_AddRepoIssueComment_WrongIssueNumber{

    Reset-InvokeCommandMock

    $owner = 'orgName' ; $repo = 'repoName' ; $number = '1' ; $comment = 'This is a comment'

    $mockUrl = "https://api.github.com/repos/{owner}/{repo}/issues/{number}#issuecomment-1906504801"
    $mockUrl = $mockUrl -replace '{owner}',$owner -replace '{repo}',$repo -replace '{number}',$number

    MockCallToNull -Command "gh issue comment $number -b `"$comment`" -R $owner/$repo"

    $result = Add-RepoIssueComment -Owner $owner -Repo $repo -Number $number -Comment $comment @ErrorParameters

    Assert-IsNull -Object $result
    Assert-Count -Expected 1 -Presented $errorvar
    Assert-Contains -Expected "Error adding comment to issue $number for $owner/$repo" -Presented $errorvar.exception.Message
}

function Test_GetRepoIssues_Success{

    Reset-InvokeCommandMock

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $attributes="number,title,url"

    MockCall -Command "gh issue list -R $owner/$repo --json $attributes" -filename getIssueList.json

    $result = Get-RepoIssue -Owner $owner -Repo $repo

    Assert-Count -Expected 5 -Presented $result

    Assert-Contains -Expected 12 -Presented $result.number
    Assert-Contains -Expected "comment development 12" -Presented $result.title

}