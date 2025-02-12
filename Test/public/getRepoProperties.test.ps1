function Test_GetRepoProperties_Success{

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'rulasg'

    $mockFile = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getRepoInfoSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo" -Command "Get-Content -Path $(($mockFile | Get-Item).FullName)"

    $result = Get-RepoProperties -owner $owner -repo $repo

    Assert-AreEqual -Expected $result.owner -Presented $user
    Assert-AreEqual -Expected $result.expiresAt.ToString('yyMMdd') -Presented '240831'
}

function Test_GetRepoProperties_NoProperties{
    $owner = 'solidifycustomers' ; $repo = 'bit22'

    $mockFile = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getRepoInfoNoProperties.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo" -Command "Get-Content -Path $(($mockFile | Get-Item).FullName)"

    $result = Get-RepoProperties -owner $owner -repo $repo

    Assert-Count -Expected 0 -Presented $result
}

function Test_GetRepoProperties_NoRepo{
    $owner = 'solidifycustomers' ; $repo = 'wrongRepo'

    $mockFile = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getRepoPropertiesNotFound.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo" -Command "Get-Content -Path $(($mockFile | Get-Item).FullName)"

    $result = Get-RepoProperties -owner $owner -repo $repo

    Assert-IsNull -Object $result
}