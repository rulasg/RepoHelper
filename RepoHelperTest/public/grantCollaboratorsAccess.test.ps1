function RepoHelperTest_GrantRepoAccess_SUCCESS{

    $owner = 'solidifycustomers'
    $repo = 'bit21'
    $user = 'raulgeu'
    $role = 'triage'
    Set-InvokeCommandAlias -Alias 'gh api repos/solidifycustomers/bit21/collaborators/raulgeu -X PUT -f permission="triage"' -Command 'return "null"'

    $result = Grant-RepoAccess -owner $owner -repo $repo -user $user -role $role

    Assert-IsNull -Object $result
}

function RepoHelperTest_GrantRepoAccess_fail_wrong_user_repo_owner{
    $GrantAccessError = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'grantAccessError.json'

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'wrongUser' ; $role = 'triage'

    Set-InvokeCommandAlias -Alias 'gh api repos/solidifycustomers/bit21/collaborators/wrongUser -X PUT -f permission="triage"' -Command "Get-Content -Path $(($GrantAccessError | Get-Item).FullName)"

    $result = Grant-RepoAccess -owner $owner -repo $repo -user $user -role $role

    Assert-AreEqual -expected 'Not Found' -Presented $result.message
}

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