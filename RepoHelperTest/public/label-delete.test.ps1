# create a test function that calls Remove-RepoLabel and checks the result

function RepoHelperTest_RepoLabel_Remove{

    # simple call 
    $result = Remove-RepoLabel -Name 'testLabel' -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label delete "testLabel" --yes' -presented $infoVar

    # call with repo
    $result = Remove-RepoLabel -Name 'testLabel' -Repo 'testRepo' -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label delete "testLabel" --yes -R "testRepo"' -presented $infoVar
}
