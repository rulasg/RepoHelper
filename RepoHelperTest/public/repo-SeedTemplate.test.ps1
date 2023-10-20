
function RepoHelperTest_RepoSeedTemplate_Get{

    $result = Get-RepoSeedTemplate -Repo "ownerName/repoName" -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected "gh repo view ownerName/repoName --json templateRepository" -presented $infoVar -Comment "Command not as expected"

    $result = Get-RepoSeedTemplate -Repo rulasg/testrepo2 
    Assert-AreEqual -Expected "rulasg/testPublicRepo" -Presented $result -Comment "Template not as expected"

    $result = Get-RepoSeedTemplate -Repo "wrongrepo" @InfoParameters @ErrorParameters
    Assert-IsNull -Object $result
}

function RepoHelperTest_RepoSeedTemplate_Get_local{

    gh repo clone rulasg/testrepo2

    Set-Location testrepo2

    $result = Get-RepoSeedTemplate
    Assert-AreEqual -Expected "rulasg/testPublicRepo" -Presented $result -Comment "Template not as expected"

}