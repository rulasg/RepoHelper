
function RepoHelperTest_GetRepoAccessAll_SUCCESS{

    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'

    $owner = 'solidifycustomers' ; $repo = 'bit21' 

    Set-InvokeCommandAlias -Alias 'gh api repos/solidifycustomers/bit21/collaborators' -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"

    $result = Get-RepoAccessAll -owner $owner -repo $repo

    Assert-AreEqual -Expected $result.raulgeu -Presented 'write'
    Assert-AreEqual -Expected $result.rulasg -Presented 'admin'
}

function RepoHelperTest_GetRepoAccess_Success{

    $GetAccessSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessSuccess.json'

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'raulgeu'

    Set-InvokeCommandAlias -Alias 'gh api repos/solidifycustomers/bit21/collaborators/raulgeu/permission' -Command "Get-Content -Path $(($GetAccessSuccess | Get-Item).FullName)"

    $result = Get-RepoAccess -Owner $owner -Repo $repo -User $user

    Assert-AreEqual -Expected 'write' -Presented $result
}

function RepoHelperTest_TestRepoAccess_Success_True{

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'raulgeu'

    Set-InvokeCommandAlias -Alias  "gh api repos/$owner/$Repo/collaborators/$user" -Command 'echo null'

    $result = Test-RepoAccess -Owner 'solidifycustomers' -Repo 'bit21' -User 'raulgeu' 

    Assert-IsTrue -Condition $result
}

function RepoHelperTest_TestRepoAccess_Success_False{

    $testnotfound = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'testRepoAccessNotFound.json'
    
    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'raulgeu'

    Set-InvokeCommandAlias -Alias  "gh api repos/$owner/$Repo/collaborators/$user" -Command "Get-Content -Path $(($testnotfound | Get-Item).FullName)"

    $result = Test-RepoAccess -Owner $owner -Repo $repo -User $user

    Assert-IsFalse -Condition $result

}