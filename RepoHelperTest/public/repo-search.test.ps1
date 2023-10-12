
$attributes = 'name,url'

function RepoHelperTest_Search_Repo_Name{
    $expectedcommand = "gh search repos testName in:name --json {attributes}" -replace "{attributes}", "$($attributes)"

    $result = Find-RepoByName -Name "testName" @InfoParameters -whatif

    Assert-IsNull -Object $result
    Assert-Contains -Expected $expectedcommand -presented $infoVar -Comment "Command not as expected"
}

function RepoHelperTest_Search_Repo_NameWithOwner{

    $expectedcommand = "gh search repos testName in:name user:testOwner --json {attributes}" -replace "{attributes}", "$($attributes)"

    $result = Find-RepoByName -Name "testName" -Owner testOwner @InfoParameters -whatif

    Assert-IsNull -Object $result
    Assert-Contains -Expected $expectedcommand -presented $infoVar -Comment "Command not as expected"

}

function RepoHelperTest_RepoAdmins_Get{

    $result = Get-RepoAdmins -RepoName 'bit21/bitkeeper'

    Assert-NotImplemented
}
