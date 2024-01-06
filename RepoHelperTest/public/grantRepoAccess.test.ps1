function RepoHelperTest_GrantRepoAccess_SUCCESS_NotCache{
    
    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'raulgeu' ; $role = 'write'

    $GetAccessSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessNone.json'
    Set-InvokeCommandAlias -Alias "gh api repos/$owner/$repo/collaborators/$user/permission" -Command "Get-Content -Path $(($GetAccessSuccess | Get-Item).FullName)"
    
    $grantAccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'grantAccessSuccess.json'
    Set-InvokeCommandAlias -Alias 'gh api repos/solidifycustomers/bit21/collaborators/raulgeu -X PUT -f permission="write"' -Command "Get-Content -Path $(($grantAccess | Get-Item).FullName)"

    $result = Grant-RepoAccess -owner $owner -repo $repo -user $user -role $role

    Assert-AreEqual -Expected $result.$user -Presented $role
}

function RepoHelperTest_GrantRepoAccess_SUCCESS_Cached{
    
    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'raulgeu' ; $role = 'write'

    $GetAccessSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessSuccess.json'
    Set-InvokeCommandAlias -Alias "gh api repos/$owner/$repo/collaborators/$user/permission" -Command "Get-Content -Path $(($GetAccessSuccess | Get-Item).FullName)"

    Set-InvokeCommandAlias -Alias 'gh api repos/solidifycustomers/bit21/collaborators/raulgeu -X PUT -f permission="write"' -Command "throw"

    $result = Grant-RepoAccess -owner $owner -repo $repo -user $user -role $role

    Assert-AreEqual -Expected $result.$user -Presented $role
}

function RepoHelperTest_GrantRepoAccess_fail_wrong_user_repo_owner{
    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'wrongUser' ; $role = 'triage'

    $GetAccessSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessNone.json'
    Set-InvokeCommandAlias -Alias "gh api repos/$owner/$repo/collaborators/$user/permission" -Command "Get-Content -Path $(($GetAccessSuccess | Get-Item).FullName)"

    $GrantAccessError = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'grantAccessError.json'
    Set-InvokeCommandAlias -Alias 'gh api repos/solidifycustomers/bit21/collaborators/wrongUser -X PUT -f permission="triage"' -Command "Get-Content -Path $(($GrantAccessError | Get-Item).FullName)"

    $result = Grant-RepoAccess -owner $owner -repo $repo -user $user -role $role

    Assert-AreEqual -Expected $result.$user -Presented 'Not Found'
}

function RepoHelperTest_GrantRepoAccessAll_Success{
    Assert-NotImplemented
}