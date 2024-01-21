function RepoHelperTest_SetRepoProperties_Success{

    $owner = 'solidifydemo' ; $repo = 'bit21' ; $property = 'kk' ; $value = 'someValuekk'

    Enable-InvokeCommandAlias -Tag RepoHelperModule
    
    $result = Set-RepoProperties -owner $owner -repo $repo -name $property -value $value
    
    Disable-InvokeCommandAlias -Tag RepoHelperModule

    Assert-NotImplemented
}