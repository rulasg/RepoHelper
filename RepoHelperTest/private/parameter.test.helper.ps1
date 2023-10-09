# Variables used to the written output of the cmdlets

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Scope='Script')]
$WarningParameters = @{
    WarningAction = 'SilentlyContinue'
    WarningVariable = 'warningVar'
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Scope='Script')]
$InfoParameters = @{
    InformationAction = 'SilentlyContinue'
    InformationVariable = 'infoVar'
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Scope='Script')]
$ErrorParameters = @{
    ErrorAction = 'Silently'
    ErrorVariable = 'errorVar'
}