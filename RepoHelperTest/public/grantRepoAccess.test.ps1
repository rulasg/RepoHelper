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
