
function Test_GetRepoAccessAll_SUCCESS{

    $owner = 'solidifycustomers' ; $repo = 'bit21' 
    
    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'
    Set-InvokeCommandMock -Alias 'gh api repos/solidifycustomers/bit21/collaborators --paginate' -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"

    $GetInvitations = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessInvitationsSuccess.json'
    Set-InvokeCommandMock -Alias 'gh api repos/solidifycustomers/bit21/invitations --paginate' -Command "Get-Content -Path $(($GetInvitations | Get-Item).FullName)"

    $result = Get-RepoAccess -owner $owner -repo $repo

    Assert-AreEqual -Expected $result.raulgeu -Presented 'write (invitation Pending)'
    Assert-AreEqual -Expected $result.MagnusTim -Presented 'admin'
    Assert-AreEqual -Expected $result.rulasg -Presented 'admin'
    Assert-AreEqual -Expected $result.raulgeukk -Presented 'write'
}

function Test_GetRepoAccess_Success_FromAccess{

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'raulgeukk'

    # $GetAccessSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessSuccess.json'
    # Set-InvokeCommandMock -Alias 'gh api repos/solidifycustomers/bit21/collaborators/raulgeu/permission' -Command "Get-Content -Path $(($GetAccessSuccess | Get-Item).FullName)"

    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'
    Set-InvokeCommandMock -Alias 'gh api repos/solidifycustomers/bit21/collaborators --paginate' -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"
    Set-InvokeCommandMock -Alias 'gh api repos/solidifycustomers/bit21/invitations --paginate' -Command "echo []"

    $result = Get-RepoAccess -Owner $owner -Repo $repo

    Assert-AreEqual -Expected 'write' -Presented $result.$user
}

function Test_GetRepoAccess_Success_FromInvites{

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'raulgeu'

    # $GetAccessSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessSuccess.json'
    # Set-InvokeCommandMock -Alias 'gh api repos/solidifycustomers/bit21/collaborators/raulgeu/permission' -Command "Get-Content -Path $(($GetAccessSuccess | Get-Item).FullName)"

    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators --paginate" -Command "echo []"
    $GetInvitations = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessInvitationsSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations --paginate" -Command "Get-Content -Path $(($GetInvitations | Get-Item).FullName)"

    $result = Get-RepoAccess -Owner $owner -Repo $repo

    Assert-AreEqual -Expected 'write (invitation Pending)' -Presented $result.$user
}



function Test_TestRepoAccess_Success_True{

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'raulgeu'

    Set-InvokeCommandMock -Alias  "gh api repos/$owner/$Repo/collaborators/$user" -Command 'echo null'

    $result = Test-RepoAccess -Owner 'solidifycustomers' -Repo 'bit21' -User 'raulgeu' 

    Assert-IsTrue -Condition $result
}

function Test_TestRepoAccess_Success_False{

    $testnotfound = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'testRepoAccessNotFound.json'
    
    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'raulgeu'
    
    Set-InvokeCommandMock -Alias  "gh api repos/$owner/$Repo/collaborators/$user" -Command "Get-Content -Path $(($testnotfound | Get-Item).FullName)"
    
    $result = Test-RepoAccess -Owner $owner -Repo $repo -User $user
    
    Assert-IsFalse -Condition $result
    
}