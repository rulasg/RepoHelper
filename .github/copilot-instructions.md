# Copilot Instructions

## Powershell Modules Code Instructions

### PowerShell Functions Instructions

Every powershell function will contain the `CmdletBinding` attribute and the `parm`iven if there are no parameters. 
If the function is on the public folder of the module, we will add the Èxport-ModuleFunction` statement in the same line as the closing `}` of the function

Sample of function will be:

```powershell

function Get-UserName{
    [CmdletBinding()]
    param()

    #Logic of the function
} Export-ModuleFunction -FunctionName 'Get-UserName'
```

### PowerShell Test Instructions

Every public function on the Test module will have the following format

- Name will start with `Test_` will follow the name of the function that we are testing with no '-'. It will follow the intention of the test splited with a '_'
- Every time we create a new function with no body we will add the `Assert-NotImplemented` statement at the end
- We will add the 3 sections as with comments `Arrange`, `Act` and `Assert` to make the test more readable.
- Sample of a test function to test `Get-UserName` function  will be `Test_GetUserName_UserNotFound`

Full sample will be as follows

```powershell
function Test_GetUserName_UserNotFound{

    # Arrange

    # Act

    # Assert

    Assert-NotImplemented
} 
```
