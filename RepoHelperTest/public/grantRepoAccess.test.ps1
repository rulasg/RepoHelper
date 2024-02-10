function RepoHelperTest_GrantRepoAccess_SUCCESS_NotCache{

    Reset-InvokeCommandMock
    
    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'raulgeu' ; $role = 'write'

    # $GetAccessSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessNone.json'
    # Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators/$user/permission" -Command "Get-Content -Path $(($GetAccessSuccess | Get-Item).FullName)"

    MockCall -Command "gh api repos/$owner/$repo/collaborators --paginate" -Filename 'getAccessAllSuccess.json'
    MockCall -command "gh api repos/$owner/$repo/invitations --paginate" -filename 'getAccessInvitationsSuccess.json'
    
    MockCall -Filename 'grantAccessSuccess.json' -Command "gh api repos/$owner/$repo/collaborators/raulgeu -X PUT -f permission=`"write`""

    $result = Grant-RepoAccess -owner $owner -repo $repo -user $user -role $role

    Assert-AreEqual -Expected $result.$user -Presented $role
}

function RepoHelperTest_GrantRepoAccess_SUCCESS_Cached{

    Reset-InvokeCommandMock

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'raulgeu' ; $role = 'write'

    # $GetAccessSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessSuccess.json'
    # Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators/$user/permission" -Command "Get-Content -Path $(($GetAccessSuccess | Get-Item).FullName)"

    MockCall -Command "gh api repos/$owner/$repo/collaborators --paginate" -Filename 'getAccessAllSuccess.json'
    MockCall -command "gh api repos/$owner/$repo/invitations --paginate" -filename 'getAccessInvitationsSuccess.json'
    MockCallThrow -Command "gh api repos/$owner/$repo/collaborators/raulgeu -X PUT -f permission=`"write`""

    $result = Grant-RepoAccess -owner $owner -repo $repo -user $user -role $role

    Assert-AreEqual -Expected $result.$user -Presented $role
}

function RepoHelperTest_GrantRepoAccess_fail_wrong_user_repo_owner{
    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'wrongUser' ; $role = 'triage'

    Reset-InvokeCommandMock

    # Checks for user
    MockCall -Command "gh api repos/$owner/$repo/collaborators --paginate" -Filename 'getAccessAllSuccess.json'
    MockCall -command "gh api repos/$owner/$repo/invitations --paginate" -filename 'getAccessInvitationsSuccess.json'

    # Remove user
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators/$user -X DELETE" -Command "echo null"
    # Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations/$invitation_id -X DELETE" -Command "echo null"
    

    # Grant access
    $GrantAccessError = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'grantAccessError.json'
    Set-InvokeCommandMock -Alias 'gh api repos/solidifycustomers/bit21/collaborators/wrongUser -X PUT -f permission="triage"' -Command "Get-Content -Path $(($GrantAccessError | Get-Item).FullName)"

    $result = Grant-RepoAccess -owner $owner -repo $repo -user $user -role $role 

    Assert-AreEqual -Expected $result.$user -Presented 'Not Found'
}
