function RepoHelperTest_GetRepoInvitations_SUCCESS{

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'raulgeu' ; $role = 'write'

    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessInvitationsSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations" -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"

    $result = Get-RepoAccessInvitations -owner $owner -repo $repo

    Assert-AreEqual -Expected $result.$user -Presented $role
}

function RepoHelperTest_GetRepoInvitations_SUCCESS_Ids{

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $id = 243067060 ; $user = 'raulgeu'

    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessInvitationsSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations" -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"

    $result = Get-RepoAccessInvitations -owner $owner -repo $repo -Ids

    Assert-AreEqual -Expected $result.$user -Presented $id
}

function RepoHelperTest_GetRepoInvitations_Empty{

    $owner = 'solidifycustomers' ; $repo = 'bit21' 

    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations" -Command 'echo "[]"'

    $result = Get-RepoAccessInvitations -owner $owner -repo $repo

    Assert-Count -Expected 0 -Presented $result
}

function RepoHelperTest_RemoveRepoInvitations_SUCCESS{

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $id = 243067060 ; $user = 'raulgeu'

    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessInvitationsSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations" -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"

    # Call 
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations/$id -X DELETE" -Command "echo null"

    $result = Remove-RepoAccessInvitation -owner $owner -repo $repo -user $user @WarningParameters

    Assert-IsNull -Object $result
    Assert-Count -Expected 0 -Presented $warningVar.messages
}

function RepoHelperTest_RemoveRepoInvitations_NoUser{

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $id = 243067060 ; $user = 'raulgeu'

    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessInvitationsSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations" -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"

    # Call 
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations/$id -X DELETE" -Command "throw"

    $result = Remove-RepoAccessInvitation -owner $owner -repo $repo -user 'wrongUser' @WarningParameters

    Assert-IsNull -Object $result
    Assert-Contains -Expected "User wrongUser not found in invitations list." -Presented $warningVar
}