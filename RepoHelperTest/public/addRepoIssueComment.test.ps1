function RepoHelperTest_AddRepoIssueComment_Success{

    Reset-InvokeCommandMock

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $issueNumber = '1' ; $comment = 'This is a comment'

    $mockUrl = "https://api.github.com/repos/{owner}/{repo}/issues/{issueNumber}#issuecomment-1906504801"
    $mockUrl = $mockUrl -replace '{owner}',$owner -replace '{repo}',$repo -replace '{issueNumber}',$issueNumber

    Set-InvokeCommandMock -Alias "gh issue comment $issueNumber -b '$comment' -R $owner/$repo" -Command "echo $mockUrl"

    $result = Add-RepoIssueComment -Owner $owner -Repo $repo -IssueNumber $issueNumber -Comment $comment

    Assert-AreEqual -Expected $mockUrl -Presented $result
}

function RepoHelperTest_AddRepoIssueComment_Success_minimalCommand{

    Reset-InvokeCommandMock

    $owner = 'orgName' ; $repo = 'repoName' ; $issueNumber = '1' ; $comment = 'This is a comment'

    Set-InvokeCommandMock -Alias 'git remote get-url origin 2>$null' -Command "echo https://github.com/$owner/$repo.git"

    $mockUrl = "https://api.github.com/repos/{owner}/{repo}/issues/{issueNumber}#issuecomment-1906504801"
    $mockUrl = $mockUrl -replace '{owner}',$owner -replace '{repo}',$repo -replace '{issueNumber}',$issueNumber

    Set-InvokeCommandMock -Alias "gh issue comment $issueNumber -b '$comment' -R $owner/$repo" -Command "echo $mockUrl"

    $result = $comment | Add-RepoIssueComment $issueNumber

    Assert-AreEqual -Expected $mockUrl -Presented $result
}

function RepoHelperTest_AddRepoIssueComment_WrongIssueNumber{

    Reset-InvokeCommandMock

    $owner = 'orgName' ; $repo = 'repoName' ; $issueNumber = '1' ; $comment = 'This is a comment'

    $mockUrl = "https://api.github.com/repos/{owner}/{repo}/issues/{issueNumber}#issuecomment-1906504801"
    $mockUrl = $mockUrl -replace '{owner}',$owner -replace '{repo}',$repo -replace '{issueNumber}',$issueNumber

    Set-InvokeCommandMock -Alias "gh issue comment $issueNumber -b '$comment' -R $owner/$repo" -Command "return $null"

    $result = Add-RepoIssueComment -Owner $owner -Repo $repo -IssueNumber $issueNumber -Comment $comment @ErrorParameters

    Assert-IsNull -Object $result
    Assert-Count -Expected 1 -Presented $errorvar
    Assert-Contains -Expected "Error adding comment to issue $issueNumber for $owner/$repo" -Presented $errorvar.exception.Message
}