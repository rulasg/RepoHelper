# create a test to call Add-RepoLabel and check result

function RepoHelperTest_RepoLabel_Add{

    # simple call 
    $result = Add-RepoLabel -Name 'testLabel' -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label create "testLabel"' -presented $infoVar

    # call with description
    $result = Add-RepoLabel -Name 'testLabel' -Description 'label description' -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label create "testLabel" -d "label description"' -presented $infoVar -Comment "Command not as expected"

    # call with color
    $result = Add-RepoLabel -Name 'testLabel' -Color 'red' -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label create "testLabel" -c "red"' -presented $infoVar

    # call with repo
    $result = Add-RepoLabel -Name 'testLabel' -Repo 'testRepo' -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label create "testLabel" -R "testRepo"' -presented $infoVar

    # call with force
    $result = Add-RepoLabel -Name 'testLabel' -Force -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label create "testLabel" -f' -presented $infoVar

    # call with all parameters
    $result = Add-RepoLabel -Name 'testLabel' -Description 'label description' -Color 'red' -Repo 'testRepo' -Force -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label create "testLabel" -d "label description" -c "red" -R "testRepo" -f' -presented $infoVar
}

# create a test to call Import-RepoLabels and check result
function RepoHelperTest_RepoLabel_Import{

    # create a test file
    $testFile = New-TestingFile -Name 'testLabels.json' -PassThru -Content @'
    [
        {
            "name": "testLabel",
            "description": "label description",
            "color": "d73a41"
        },
        {
            "name": "testLabel2",
            "description": "label description2",
            "color": "d73a42"
        }
    ]

'@

    # simple call 
    $result = Import-RepoLabels -Path $testFile -Repo 'testRepo' -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label create "testLabel" -d "label description" -c "d73a41" -R "testRepo"' -presented $infoVar
    Assert-Contains -Expected 'gh label create "testLabel2" -d "label description2" -c "d73a42" -R "testRepo"' -presented $infoVar

    # call with force
    $result = Import-RepoLabels -Path $testFile -Repo 'testRepo' -Force -whatif @InfoParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected 'gh label create "testLabel" -d "label description" -c "d73a41" -R "testRepo" -f' -presented $infoVar
    Assert-Contains -Expected 'gh label create "testLabel2" -d "label description2" -c "d73a42" -R "testRepo" -f' -presented $infoVar
}