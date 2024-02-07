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
    MockCall -command "gh api users/rulasg" -filename 'getuserSuccess_rulasg.json'
    MockCall -command "gh api users/raulgeu" -filename 'getuserSuccess_raulgeu.json'
    MockCall -command "gh api users/raulgeukk" -filename 'getuserSuccess_raulgeukk.json'
    MockCall -command "gh api users/MagnusTim" -filename 'getuserSuccess_MagnusTim.json'

    # Act
    $result = Get-RepoAccessTeam -Owner $owner -Repo $repo

    Assert-Count -Expected 6 -Presented $result
    Assert-Contains -Presented $result -Expected "| Photo                      | Name   | Access   | Email   | Handle | Company    |"
    Assert-Contains -Presented $result -Expected "|----------------------------|--------|----------|---------|--------|------------|"

    Assert-Contains -Presented $result -Expected "| ![@raulgeukk](https://avatars.githubusercontent.com/raulgeukk?s=40) | Raul Dibildos kk | write | raulgeukk@github.com | raulgeukk| Contoso  |"
    Assert-Contains -Presented $result -Expected "| ![@raulgeu](https://avatars.githubusercontent.com/raulgeu?s=40) | Raul Dibildos | write | raulgeu@github.com | raulgeu| Contoso  |"
    Assert-Contains -Presented $result -Expected "| ![@MagnusTim](https://avatars.githubusercontent.com/MagnusTim?s=40) | Magnus Timner | admin | MagnusTim@github.com | MagnusTim| Contoso  |"
    Assert-Contains -Presented $result -Expected "| ![@rulasg](https://avatars.githubusercontent.com/rulasg?s=40) | Raul Gonzalez | admin | rulasg@github.com | rulasg| Contoso  |"
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
    MockCall -command "gh api users/rulasg" -filename 'getuserSuccess_rulasg.json'
    MockCall -command "gh api users/raulgeu" -filename 'getuserSuccess_raulgeu.json'
    MockCall -command "gh api users/raulgeukk" -filename 'getuserSuccess_raulgeukk.json'
    MockCall -command "gh api users/MagnusTim" -filename 'getuserSuccess_MagnusTim.json'

    # Act
    $result = Get-RepoAccessTeam -Owner $owner -Repo $repo -NoHeaders

    Assert-Count -Expected 4 -Presented $result

    Assert-Contains -Presented $result -Expected "| ![@raulgeukk](https://avatars.githubusercontent.com/raulgeukk?s=40) | Raul Dibildos kk | write | raulgeukk@github.com | raulgeukk| Contoso  |"
    Assert-Contains -Presented $result -Expected "| ![@raulgeu](https://avatars.githubusercontent.com/raulgeu?s=40) | Raul Dibildos | write | raulgeu@github.com | raulgeu| Contoso  |"
    Assert-Contains -Presented $result -Expected "| ![@MagnusTim](https://avatars.githubusercontent.com/MagnusTim?s=40) | Magnus Timner | admin | MagnusTim@github.com | MagnusTim| Contoso  |"
    Assert-Contains -Presented $result -Expected "| ![@rulasg](https://avatars.githubusercontent.com/rulasg?s=40) | Raul Gonzalez | admin | rulasg@github.com | rulasg| Contoso  |"

}

function MockCall{
    param(
        [string] $command,
        [string] $filename

    )

    $mockFile = $PSScriptRoot | Join-Path -ChildPath 'testdata' -AdditionalChildPath $filename
    Set-InvokeCommandMock -Alias $command -Command "Get-Content -Path $(($mockFile | Get-Item).FullName)"
}