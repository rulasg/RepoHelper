function 
RepoHelperTest_GetRepoAccessTeam_Success{

    Reset-InvokeCommandMock

    $owner = "solidifycustomers"; $repo = "bit21"

    # All users
    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators --paginate" -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"
    $getInvitations = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessInvitationsSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations --paginate" -Command "Get-Content -Path $(($getInvitations | Get-Item).FullName)"

    # Get User information
    MockCall -command "gh api users/rulasg" -filename 'getUserSuccess_rulasg.json'
    MockCall -command "gh api users/raulgeu" -filename 'getUserSuccess_raulgeu.json'
    MockCall -command "gh api users/raulgeukk" -filename 'getUserSuccess_raulgeukk.json'
    MockCall -command "gh api users/MagnusTim" -filename 'getUserSuccess_MagnusTim.json'

    # Act
    $result = Get-RepoAccessTeam -Owner $owner -Repo $repo

    Assert-Count -Expected 6 -Presented $result
    Assert-Contains -Presented $result -Expected "| Photo                      | Name   | Access   | Email   | Handle | Company    |"
    Assert-Contains -Presented $result -Expected "|----------------------------|--------|----------|---------|--------|------------|"

    Assert-Contains -Presented $result -Expected '| <img alt="" width="100" height="100" class="avatar width-full height-full avatar-before-user-status" src="https://avatars.githubusercontent.com/MagnusTim"> | Magnus Timner | admin | MagnusTim@github.com |  [@MagnusTim](https://https://github.com/MagnusTim) | Contoso  |'
    Assert-Contains -Presented $result -Expected '| <img alt="" width="100" height="100" class="avatar width-full height-full avatar-before-user-status" src="https://avatars.githubusercontent.com/rulasg"> | Raul Gonzalez | admin | rulasg@github.com |  [@rulasg](https://https://github.com/rulasg) | Contoso  |'
    Assert-Contains -Presented $result -Expected '| <img alt="" width="100" height="100" class="avatar width-full height-full avatar-before-user-status" src="https://avatars.githubusercontent.com/raulgeukk"> | Raul Dibildos kk | write | raulgeukk@github.com |  [@raulgeukk](https://https://github.com/raulgeukk) | Contoso  |'
    Assert-Contains -Presented $result -Expected '| <img alt="" width="100" height="100" class="avatar width-full height-full avatar-before-user-status" src="https://avatars.githubusercontent.com/raulgeu"> | Raul Dibildos | write | raulgeu@github.com |  [@raulgeu](https://https://github.com/raulgeu) | Contoso  |'
}

function RepoHelperTest_GetRepoAccessTeam_Success_NoHead{

    Reset-InvokeCommandMock

    $owner = "solidifycustomers"; $repo = "bit21"

    # All users
    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessAllSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/collaborators --paginate" -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"
    $getInvitations = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessInvitationsSuccess.json'
    Set-InvokeCommandMock -Alias "gh api repos/$owner/$repo/invitations --paginate" -Command "Get-Content -Path $(($getInvitations | Get-Item).FullName)"

    # Get User information
    MockCall -command "gh api users/rulasg" -filename 'getUserSuccess_rulasg.json'
    MockCall -command "gh api users/raulgeu" -filename 'getUserSuccess_raulgeu.json'
    MockCall -command "gh api users/raulgeukk" -filename 'getUserSuccess_raulgeukk.json'
    MockCall -command "gh api users/MagnusTim" -filename 'getUserSuccess_MagnusTim.json'

    # Act
    $result = Get-RepoAccessTeam -Owner $owner -Repo $repo -NoHeaders

    Assert-Count -Expected 4 -Presented $result

    Assert-Contains -Presented $result -Expected '| <img alt="" width="100" height="100" class="avatar width-full height-full avatar-before-user-status" src="https://avatars.githubusercontent.com/MagnusTim"> | Magnus Timner | admin | MagnusTim@github.com |  [@MagnusTim](https://https://github.com/MagnusTim) | Contoso  |'
    Assert-Contains -Presented $result -Expected '| <img alt="" width="100" height="100" class="avatar width-full height-full avatar-before-user-status" src="https://avatars.githubusercontent.com/rulasg"> | Raul Gonzalez | admin | rulasg@github.com |  [@rulasg](https://https://github.com/rulasg) | Contoso  |'
    Assert-Contains -Presented $result -Expected '| <img alt="" width="100" height="100" class="avatar width-full height-full avatar-before-user-status" src="https://avatars.githubusercontent.com/raulgeukk"> | Raul Dibildos kk | write | raulgeukk@github.com |  [@raulgeukk](https://https://github.com/raulgeukk) | Contoso  |'
    Assert-Contains -Presented $result -Expected '| <img alt="" width="100" height="100" class="avatar width-full height-full avatar-before-user-status" src="https://avatars.githubusercontent.com/raulgeu"> | Raul Dibildos | write | raulgeu@github.com |  [@raulgeu](https://https://github.com/raulgeu) | Contoso  |'
}

function MockCall{
    param(
        [string] $command,
        [string] $filename

    )

    $mockFile = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath $filename
    Set-InvokeCommandMock -Alias $command -Command "Get-Content -Path $(($mockFile | Get-Item).FullName)"
}