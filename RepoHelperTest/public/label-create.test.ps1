# create a test to call Add-RepoLabel and check result

function RepoHelperTest_RepoLabel_New{

    # simple call 
    $result = Add-RepoLabel -Name 'testLabel' -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label create testLabel' -presented $infoVar

    # call with description
    $result = Add-RepoLabel -Name 'testLabel' -Description 'label description' -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label create testLabel -d "label description"' -presented $infoVar -Comment "Command not as expected"

    # call with color
    $result = Add-RepoLabel -Name 'testLabel' -Color 'red' -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label create testLabel -c "red"' -presented $infoVar

    # call with repo
    $result = Add-RepoLabel -Name 'testLabel' -Repo 'testRepo' -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label create testLabel -R "testRepo"' -presented $infoVar

    # call with force
    $result = Add-RepoLabel -Name 'testLabel' -Force -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label create testLabel -f' -presented $infoVar

    # call with all parameters
    $result = Add-RepoLabel -Name 'testLabel' -Description 'label description' -Color 'red' -Repo 'testRepo' -Force -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label create testLabel -d "label description" -c "red" -R "testRepo" -f' -presented $infoVar
}

