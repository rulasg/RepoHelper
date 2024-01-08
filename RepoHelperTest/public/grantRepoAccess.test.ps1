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

function RepoHelperTest_SyncRepoAccessAll_Success_Write{
    $owner = 'solidifycustomers' ; $repo = 'bit21'

    # Avoid calls to single user check
    Set-InvokeCommandAlias -Alias "gh api repos/$owner/$repo/collaborators/rulasg/permission" -Command "throw"

    # All users
    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'
    Set-InvokeCommandAlias -Alias "gh api repos/$owner/$repo/collaborators" -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"

    # Grant access
    $grantAccessRulasg = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'grantAccessSuccessRulasg.json'
    Set-InvokeCommandAlias -Alias 'gh api repos/solidifycustomers/bit21/collaborators/rulasg -X PUT -f permission="write"' -Command "Get-Content -Path $(($grantAccessRulasg | Get-Item).FullName)"

    # Remove raulgeukk
    Set-InvokeCommandAlias -Alias "gh api repos/$owner/$repo/collaborators/raulgeukk -X DELETE" -Command "echo null"

    $userList = @"
raulgeu
rulasg
"@

    New-TestingFile -Name "contributors" -Content $userList

    $result = Sync-RepoAccess -owner $owner -repo $repo -FilePath "contributors" -role 'write'

    # As admin Mangnus should not be removed from the repo even if not in the write list
    Assert-NotContains -Expected 'MagnusTim' -Presented $result.Keys
    
    Assert-AreEqual -Expected '=' -Presented $result.raulgeu

    Assert-AreEqual -Expected '+ (admin)' -Presented $result.rulasg

    Assert-AreEqual -Expected '-' -Presented $result.raulgeukk
    
}

function RepoHelperTest_SyncRepoAccessAll_Success_Admin{
    $owner = 'solidifycustomers' ; $repo = 'bit21'

    # Avoid calls to single user check
    Set-InvokeCommandAlias -Alias "gh api repos/$owner/$repo/collaborators/rulasg/permission" -Command "throw"

    # All users
    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'
    Set-InvokeCommandAlias -Alias "gh api repos/$owner/$repo/collaborators" -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"

    # Grant access
    $grantAccessRaulgeu = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'grantAccessSuccessRaulgeuAdmin.json'
    Set-InvokeCommandAlias -Alias 'gh api repos/solidifycustomers/bit21/collaborators/raulgeu -X PUT -f permission="admin"' -Command "Get-Content -Path $(($grantAccessRaulgeu | Get-Item).FullName)"

    # Remove MagnusTim
    Set-InvokeCommandAlias -Alias "gh api repos/$owner/$repo/collaborators/MagnusTim -X DELETE" -Command "echo null"

    $userList = @"
raulgeu
rulasg
"@

    New-TestingFile -Name "contributors" -Content $userList

    $result = Sync-RepoAccess -owner $owner -repo $repo -FilePath "contributors" -role 'admin'

    # As admin Mangnus should not be removed from the repo even if not in the write list
    
    Assert-AreEqual -Expected '=' -Presented $result.rulasg

    Assert-AreEqual -Expected '+ (write)' -Presented $result.raulgeu

    Assert-AreEqual -Expected '-' -Presented $result.MagnusTim
    
}

function RepoHelperTest_SyncRepoAccessAll_Success_Admin_WhatIf{
    $owner = 'solidifycustomers' ; $repo = 'bit21'

    # Avoid calls to single user check
    Set-InvokeCommandAlias -Alias "gh api repos/$owner/$repo/collaborators/rulasg/permission" -Command "throw"

    # All users
    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'
    Set-InvokeCommandAlias -Alias "gh api repos/$owner/$repo/collaborators" -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"

    # Grant access
    Set-InvokeCommandAlias -Alias 'gh api repos/solidifycustomers/bit21/collaborators/raulgeu -X PUT -f permission="admin"' -Command "throw"

    # Remove MagnusTim
    Set-InvokeCommandAlias -Alias "gh api repos/$owner/$repo/collaborators/MagnusTim -X DELETE" -Command "throw"

    $userList = @"
raulgeu
rulasg
"@

    New-TestingFile -Name "contributors" -Content $userList

    $result = Sync-RepoAccess -owner $owner -repo $repo -FilePath "contributors" -role 'admin' -WhatIf

    # As admin Mangnus should not be removed from the repo even if not in the write list

    Assert-AreEqual -Expected '=' -Presented $result.rulasg

    Assert-AreEqual -Expected '+ (write)' -Presented $result.raulgeu

    Assert-AreEqual -Expected '-' -Presented $result.MagnusTim

}