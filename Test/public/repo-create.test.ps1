function Test_Create_Repo_Path{

    $repoName = 'testModule_{0}' -f $((New-guid).Guid.Substring(0,8))
    $repoDescription = 'A demo for testing'

    New-ModuleV3 -Name $repoName -Description $repoDescription

    $repoPath = $repoName | Convert-Path

    $expectedCommand = 'gh repo create --public -d {description} -s {path} --disable-wiki --push'
    $expectedCommand = $expectedCommand -replace "{description}", "`"$($repoDescription)`""
    $expectedCommand = $expectedCommand -replace "{path}", "`"$($repoPath)`""

    New-RepoFromModule -Path $repoName -whatif @InfoParameters

    Assert-Contains -Expected $expectedCommand -presented $infoVar -Comment "Command not as expected"

}

function Test_Create_Repo_Local{

    $repoName = 'testModule_{0}' -f $((New-guid).Guid.Substring(0,8))

    $repoDescription = 'A demo for testing'

    New-ModuleV3 -Name $repoName -Description $repoDescription

    $repoPath = $repoName | Convert-Path

    $expectedCommand = 'gh repo create --public -d {description} -s {path} --disable-wiki --push'
    $expectedCommand = $expectedCommand -replace "{description}", "`"$($repoDescription)`""
    $expectedCommand = $expectedCommand -replace "{path}", "`"$($repoPath)`""

    Set-Location $repoName

    git init

    New-RepoFromModule -whatif @InfoParameters

    Assert-Contains -Expected $expectedCommand -presented $infoVar -Comment "Command not as expected"
}

function Test_Create_Repo_Local_Folder{

    $repoName = 'testModule_{0}' -f $((New-guid).Guid.Substring(0,8))

    $repoDescription = 'A demo for testing'

    New-TestingFolder -Path $repoName

    $repoPath = $repoName | Convert-Path

    $expectedCommand = 'gh repo create --public -d {description} -s {path} --disable-wiki --push'
    $expectedCommand = $expectedCommand -replace "{description}", "`"$($repoDescription)`""
    $expectedCommand = $expectedCommand -replace "{path}", "`"$($repoPath)`""

    Set-Location $repoName

    git init

    New-RepoFromModule -Description $repoDescription -whatif @InfoParameters

    Assert-Contains -Expected $expectedCommand -presented $infoVar -Comment "Command not as expected"
}