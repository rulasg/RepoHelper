function Test_SyncRepoAccessAll_Success_Write{
    $owner = 'solidifycustomers' ; $repo = 'bit21'

    Reset-InvokeCommandMock

    # Avoid calls to single user check
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators --paginate" -Command "throw"
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations --paginate" -Command "throw"

    # All users
    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators --paginate" -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"

    $getInvitations = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessInvitationsSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations --paginate" -Command "Get-Content -Path $(($getInvitations | Get-Item).FullName)"

    # Grant access
    $grantAccessRulasg = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'grantAccessSuccessRulasg.json'
    Set-InvokeCommandMock -Alias 'gh api repos/solidifycustomers/bit21/collaborators/rulasg -X PUT -f permission="write"' -Command "Get-Content -Path $(($grantAccessRulasg | Get-Item).FullName)"

    # Remove raulgeukk
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators/raulgeukk -X DELETE" -Command "echo null"
    
    # Remove rulasg
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators/rulasg -X DELETE" -Command "echo null"

    $userList = @"
raulgeu
rulasg
"@

    New-TestingFile -Name "contributors" -Content $userList

    $result = Sync-RepoAccess -owner $owner -repo $repo -FilePath "contributors" -role 'write'

    # As admin Mangnus should not be removed from the repo even if not in the write list
    Assert-NotContains -Expected 'MagnusTim' -Presented $result.Keys
    
    Assert-AreEqual -Expected '?' -Presented $result.raulgeu -Comment "Pending invitation"

    Assert-AreEqual -Expected '+ (admin)' -Presented $result.rulasg -Comment "added with admin preciouse access"

    Assert-AreEqual -Expected '-' -Presented $result.raulgeukk -Comment "remove from list"

}

function Test_SyncRepoAccessAll_Success_Admin{
    $owner = 'solidifycustomers' ; $repo = 'bit21'

    Reset-InvokeCommandMock


    # Avoid calls to single user check
    # Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators --paginate" -Command "throw"
    # Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations --paginate" -Command "throw"

    # All users
    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators --paginate" -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"
    $getInvitations = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessInvitationsSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations --paginate" -Command "Get-Content -Path $(($getInvitations | Get-Item).FullName)"

    # Grant access
    $grantAccessRaulgeu = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'grantAccessSuccessRaulgeuAdmin.json'
    Set-InvokeCommandMock -Alias 'gh api repos/solidifycustomers/bit21/collaborators/raulgeu -X PUT -f permission="admin"' -Command "Get-Content -Path $(($grantAccessRaulgeu | Get-Item).FullName)"
    
    # Remove MagnusTim
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators/MagnusTim -X DELETE" -Command "echo null"

    # Remove raulgeu
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations/243067060 -X DELETE" -Command "echo null"
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators/raulgeu -X DELETE" -Command "echo null"
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations/$invitation_id -X DELETE" -Command "echo null"

    $userList = @"
raulgeu
rulasg
"@

    New-TestingFile -Name "contributors" -Content $userList

    $result = Sync-RepoAccess -owner $owner -repo $repo -FilePath "contributors" -role 'admin'

    # As admin Mangnus should not be removed from the repo even if not in the write list
    
    Assert-AreEqual -Expected '=' -Presented $result.rulasg

    Assert-AreEqual -Expected '+ (write (invitation Pending))' -Presented $result.raulgeu

    Assert-AreEqual -Expected '-' -Presented $result.MagnusTim
    
}

function Test_SyncRepoAccessAll_Success_Admin_WhatIf{
    $owner = 'solidifycustomers' ; $repo = 'bit21'

    Reset-InvokeCommandMock

    # Avoid calls to single user check
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators --paginate" -Command "throw"
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations --paginate" -Command "throw"

    # All users
    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators --paginate" -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"
    $getInvitations = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessInvitationsSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations --paginate" -Command "Get-Content -Path $(($getInvitations | Get-Item).FullName)"

    # Grant access
    Set-InvokeCommandMock -Alias 'gh api repos/solidifycustomers/bit21/collaborators/raulgeu -X PUT -f permission="admin"' -Command "throw"

    # Remove MagnusTim
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators/MagnusTim -X DELETE" -Command "throw"

    $userList = @"
raulgeu
rulasg
"@

    New-TestingFile -Name "contributors" -Content $userList

    $result = Sync-RepoAccess -owner $owner -repo $repo -FilePath "contributors" -role 'admin' -WhatIf

    # As admin Mangnus should not be removed from the repo even if not in the write list

    Assert-AreEqual -Expected '=' -Presented $result.rulasg

    Assert-AreEqual -Expected '+ (write (invitation Pending))' -Presented $result.raulgeu

    Assert-AreEqual -Expected '-' -Presented $result.MagnusTim

}

function Test_SyncRepoAccess_EnvironmentParameters{
    $owner = 'solidifycustomers' ; $repo = 'bit21'

    Reset-InvokeCommandMock

    # "" | Out-File "contributors"

    $userList = @"
        #MagnusTim
        #raulgeu
        rulasg
"@

    New-TestingFile -Name "contributors" -Content $userList

    Set-InvokeCommandMock -Alias 'git remote get-url origin 2>$null' -Command "echo https://github.com/$owner/$repo.git"

    # All users
    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators --paginate" -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"
    $getInvitations = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessInvitationsSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations --paginate" -Command "Get-Content -Path $(($getInvitations | Get-Item).FullName)"

    $result = Sync-RepoAccess admin  "contributors" -WhatIf

    Assert-Count -Expected 2 -Presented $result
    Assert-AreEqual -Expected '=' -Presented $result.rulasg
    Assert-AreEqual -Expected '-' -Presented $result.MagnusTim
}

function Test_SyncRepoAccess_NoParameters {

    Reset-InvokeCommandMock

    Set-InvokeCommandMock -Alias 'git remote get-url origin 2>$null' -Command 'return $null'

    $userList = @"
    raulgeu
    rulasg
"@
    New-TestingFile -Name "contributors" -Content $userList

    $result = Sync-RepoAccess -FilePath "contributors" -role 'write' -WhatIf @ErrorParameters

    Assert-IsNull -Object $result
    Assert-Contains -Expected "[Sync-RepoAccess] Owner and Repo parameters are required" -Presented $errorvar.Exception.Message
}

function Test_SyncRepoAccess_NoUsersFile {
    $owner = 'solidifycustomers' ; $repo = 'bit21' ; $file = "contributors"

    Reset-InvokeCommandMock

    Set-InvokeCommandMock -Alias 'git remote get-url origin 2>$null' -Command "echo https://github.com/$owner/$repo.git"

    $result = Sync-RepoAccess admin $file -WhatIf  @ErrorParameters

    Assert-IsNull -Object $result
    Assert-Contains -Expected "Error reading user file $file" -Presented $errorvar.Exception.Message
}

function Test_SyncRepoAccess_Error_On_Invitations {
    $owner = 'solidifycustomers' ; $repo = 'bit21'

    Reset-InvokeCommandMock

    # "" | Out-File "contributors"

    $userList = @"
        #MagnusTim
        #raulgeu
        rulasg
"@

    New-TestingFile -Name "contributors" -Content $userList

    Set-InvokeCommandMock -Alias 'git remote get-url origin 2>$null' -Command "echo https://github.com/$owner/$repo.git"

    # All users
    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators --paginate" -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"
    $getAccessInvitationsError = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessInvitationsError.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations --paginate" -Command "Get-Content -Path $(($getAccessInvitationsError | Get-Item).FullName)"

    $result = Sync-RepoAccess admin  "contributors" -WhatIf

    Assert-Count -Expected 2 -Presented $result
    Assert-AreEqual -Expected '=' -Presented $result.rulasg
    Assert-AreEqual -Expected '-' -Presented $result.MagnusTim
}