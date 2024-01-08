
function RepoHelperTest_GetRepoAccessAll_SUCCESS{

    $owner = 'solidifycustomers' ; $repo = 'bit21' 
    
    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'
    Set-InvokeCommandAlias -Alias 'gh api repos/solidifycustomers/bit21/collaborators' -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"

    $GetInvitations = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessInvitationsSuccess.json'
    Set-InvokeCommandAlias -Alias 'gh api repos/solidifycustomers/bit21/invitations' -Command "Get-Content -Path $(($GetInvitations | Get-Item).FullName)"

    $result = Get-RepoAccess -owner $owner -repo $repo

    Assert-AreEqual -Expected $result.raulgeu -Presented 'write'
    Assert-AreEqual -Expected $result.MagnusTim -Presented 'admin'
    Assert-AreEqual -Expected $result.rulasg -Presented 'admin'
    Assert-AreEqual -Expected $result.raulgeukk -Presented 'write'
}

function RepoHelperTest_GetRepoAccess_Success{

    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $user = 'raulgeu'

    # $GetAccessSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessSuccess.json'
    # Set-InvokeCommandAlias -Alias 'gh api repos/solidifycustomers/bit21/collaborators/raulgeu/permission' -Command "Get-Content -Path $(($GetAccessSuccess | Get-Item).FullName)"

    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'
    Set-InvokeCommandAlias -Alias 'gh api repos/solidifycustomers/bit21/collaborators' -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"

    $result = Get-RepoAccess -Owner $owner -Repo $repo

    Assert-AreEqual -Expected 'write' -Presented $result.$user
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