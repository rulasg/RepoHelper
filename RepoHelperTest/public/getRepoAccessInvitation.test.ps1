function RepoHelperTest_GetRepoInvitations_SUCCESS{

    $GetAccessAllSuccess = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getAccessInvitationsSuccess.json'

    $owner = 'solidifycustomers' ; $repo = 'bit21' 

    Set-InvokeCommandAlias -Alias 'gh api repos/solidifycustomers/bit21/invitations' -Command "Get-Content -Path $(($GetAccessAllSuccess | Get-Item).FullName)"

    $result = Get-RepoAccessInvitations -owner $owner -repo $repo

    Assert-AreEqual -Expected $result.raulteu -Presented 'write'
}

function RepoHelperTest_GetRepoInvitations_Empty{

    $owner = 'solidifycustomers' ; $repo = 'bit21' 

    Set-InvokeCommandAlias -Alias "gh api repos/$owner/$repo/invitations" -Command 'echo "[]"'

    $result = Get-RepoAccessInvitations -owner $owner -repo $repo

    Assert-Count -Expected 0 -Presented $result
}