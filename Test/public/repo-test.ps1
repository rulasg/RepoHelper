function Test_Repo_Test_Manual{

    Assert-SkipTest

    $result = Test-Repo -Repo cv

    Assert-IsTrue $result

    $result = Test-Repo -Repo kk

    Assert-IsFalse $result
}