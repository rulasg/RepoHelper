function RepoHelperTest_SetRepoProperties_Success{

    $owner = 'solidifydemo' ; $repo = 'bit21' ; $property = 'kk' ; $value = 'someValuekk'

$cmd = @'
curl -L -s -H "Authorization: Bearer $env:GH_TOKEN" -X PATCH https://api.github.com/repos/{owner}/{repo}/properties/values -d '{"properties":[{"property_name":"{name}","value":"{value}"}]}'
'@
    $cmd = $cmd -replace '{owner}',$owner
    $cmd = $cmd -replace '{repo}',$repo
    $cmd = $cmd -replace '{name}',$property
    $cmd = $cmd -replace '{value}',$value

    # If success return null
    Set-InvokeCommandMock -Alias $cmd -Command "echo null"

    $result = Set-RepoProperties -owner $owner -repo $repo -name $property -value $value

    Assert-IsNull -Object $result -Message "Set-RepoProperties should return null on success"
}

function RepoHelperTest_SetRepoProperties_NotFound{

    $owner = 'solidifydemo' ; $repo = 'bit21' ; $property = 'kk' ; $value = 'someValuekk'

$cmd = @'
curl -L -s -H "Authorization: Bearer $env:GH_TOKEN" -X PATCH https://api.github.com/repos/{owner}/{repo}/properties/values -d '{"properties":[{"property_name":"{name}","value":"{value}"}]}'
'@
    $cmd = $cmd -replace '{owner}',$owner
    $cmd = $cmd -replace '{repo}',$repo
    $cmd = $cmd -replace '{name}',$property
    $cmd = $cmd -replace '{value}',$value

    # If success return null
    $mockfile = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'setRepoPropertiesNotFound.json'
    Set-InvokeCommandMock -Alias $cmd -Command "Get-Content -Path $(($mockfile | Get-Item).FullName)"

    $result = Set-RepoProperties -owner $owner -repo $repo -name $property -value $value @ErrorParameters

    Assert-IsNull -Object $result -Comment "Set-RepoProperties should return null on success"
    Assert-Contains -Expected  "Error setting property $property to $value for $owner/$repo" -Presented $errorVar.Exception.Message
}