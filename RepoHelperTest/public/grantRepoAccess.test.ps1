function RepoHelperTest_GrantRepoAccess_SUCCESS_NotCache{
    
    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'raulgeu' ; $role = 'write'

    # $GetAccessSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessNone.json'
    # Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators/$user/permission" -Command "Get-Content -Path $(($GetAccessSuccess | Get-Item).FullName)"

    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'
    Set-InvokeCommandMock -Alias 'gh api repos/solidifycustomers/bit21/collaborators' -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"
    
    $grantAccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'grantAccessSuccess.json'
    Set-InvokeCommandMock -Alias 'gh api repos/solidifycustomers/bit21/collaborators/raulgeu -X PUT -f permission="write"' -Command "Get-Content -Path $(($grantAccess | Get-Item).FullName)"

    $result = Grant-RepoAccess -owner $owner -repo $repo -user $user -role $role

    Assert-AreEqual -Expected $result.$user -Presented $role
}

function RepoHelperTest_GrantRepoAccess_SUCCESS_Cached{
    
    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'raulgeu' ; $role = 'write'

    # $GetAccessSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessSuccess.json'
    # Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators/$user/permission" -Command "Get-Content -Path $(($GetAccessSuccess | Get-Item).FullName)"

    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'
    Set-InvokeCommandMock -Alias 'gh api repos/solidifycustomers/bit21/collaborators' -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"

    $getInvitations = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessInvitationsSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations" -Command "Get-Content -Path $(($getInvitations | Get-Item).FullName)"

    Set-InvokeCommandMock -Alias 'gh api repos/solidifycustomers/bit21/collaborators/raulgeu -X PUT -f permission="write"' -Command "throw"

    $result = Grant-RepoAccess -owner $owner -repo $repo -user $user -role $role

    Assert-AreEqual -Expected $result.$user -Presented $role
}

function RepoHelperTest_GrantRepoAccess_fail_wrong_user_repo_owner{
    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'wrongUser' ; $role = 'triage'

    # Checks for user
    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'
    Set-InvokeCommandMock -Alias 'gh api repos/solidifycustomers/bit21/collaborators' -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"
    $getInvitations = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessInvitationsSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations" -Command "Get-Content -Path $(($getInvitations | Get-Item).FullName)"

    # Remove user
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators/$user -X DELETE" -Command "echo null"
    # Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations/$invitation_id -X DELETE" -Command "echo null"
    

    # Grant access
    $GrantAccessError = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'grantAccessError.json'
    Set-InvokeCommandMock -Alias 'gh api repos/solidifycustomers/bit21/collaborators/wrongUser -X PUT -f permission="triage"' -Command "Get-Content -Path $(($GrantAccessError | Get-Item).FullName)"



    $result = Grant-RepoAccess -owner $owner -repo $repo -user $user -role $role 

    Assert-AreEqual -Expected $result.$user -Presented 'Not Found'
}
