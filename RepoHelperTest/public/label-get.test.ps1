
# create a test function that calls Get-RepoLabels and checks the result

function RepoHelperTest_RepoLabel_List{

    # simple call 
    $result = Get-RepoLabels -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label list --json "name,description,color"' -presented $infoVar

    # call with repo
    $result = Get-RepoLabels -Repo 'testRepo' -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label list --json "name,description,color" -R "testRepo"' -presented $infoVar
}