function RepoHelperTest_GetRepoPropertiesSchema_Success{

    $owner = 'solidifycustomers'

    $mockFile = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getRepoPropertiesSchema.json'
    Set-InvokeCommandMock -Alias "gh api orgs/$owner/properties/schema" -Command "Get-Content -Path $(($mockFile | Get-Item).FullName)"

    $result = Get-RepoPropertiesSchema -owner $owner

    Assert-Count -Expected 10 -Presented $result

    $resultOwner = $result | Where-Object { $_.property_name -eq 'owner' }

    Assert-AreEqual -Presented $resultOwner.property_name      -Expected "owner"
    Assert-AreEqual -Presented $resultOwner.value_type         -Expected "string"
    Assert-AreEqual -Presented $resultOwner.required           -Expected "False"
    Assert-AreEqual -Presented $resultOwner.description        -Expected "person responsible for the content and the health of the repo"
    Assert-AreEqual -Presented $resultOwner.values_editable_by -Expected "org_and_repo_actors"
}

function RepoHelperTest_GetRepoProperties_NotFound{

    $owner = 'solidifycustomers22'

    $mockFile = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getRepoPropertiesSchemaNotFound.json'
    Set-InvokeCommandMock -Alias "gh api orgs/$owner/properties/schema" -Command "Get-Content -Path $(($mockFile | Get-Item).FullName)"

    $result = Get-RepoPropertiesSchema -owner $owner

    Assert-IsNull -Object $result
}


function RepoHelperTest_GetRepoProperties_OneResult{

    $owner = 'solidify-internal'

    $mockFile = $PSScriptRoot | Join-Path -ChildPath 'testData' -AdditionalChildPath 'getRepoPropertiesSchemaOneResult.json'
    Set-InvokeCommandMock -Alias "gh api orgs/$owner/properties/schema" -Command "Get-Content -Path $(($mockFile | Get-Item).FullName)"

    $result = Get-RepoPropertiesSchema -owner $owner

    Assert-Count -Expected 1 -Presented $result
    Assert-AreEqual -Presented $result.property_name      -Expected "owner"
    Assert-AreEqual -Presented $result.value_type         -Expected "string"
    Assert-AreEqual -Presented $result.required           -Expected "False"
    Assert-AreEqual -Presented $result.description        -Expected "Person responsable of the well-being of the repo and content"
    Assert-AreEqual -Presented $result.values_editable_by -Expected "org_actors"

}