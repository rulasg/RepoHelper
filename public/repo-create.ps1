<#
.SYNOPSIS
Creates a new repository from a PowerShell module.

.DESCRIPTION
The New-RepoFromModule function creates a new GitHub repository from a PowerShell module. It takes the name of the module as a parameter and creates a new repository with the same name on GitHub.

.EXAMPLE
New-RepoFromModule
Creates a new GitHub repository with the content on the local folder.

.EXAMPLE
New-RepoFromModule -Path "C:\Users\user\Documents\PowerShell\MyModule"
Creates a new GitHub repository with the content on the specified Path folder.

.NOTES
This function requires that you have proper GH CLI authentication in place. Use the gh auth login command to authenticate to GitHub.
#>
function New-RepoFromModule {
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '', Scope='Function')]
    param(
        # path parameter
        [Parameter(ValueFromPipelineByPropertyName)] [string] $Path
    )

    process {
        #check for empty path
        if([string]::IsNullOrEmpty($Path)){
            $repoPath = Get-Location
        } else {
            $repoPath = $Path
        }
        
        $repoPath = $repoPath | Convert-Path
        
        $manifestPath = $repoPath | Join-Path -ChildPath *.psd1 | Get-Item
        
        if($manifestPath.Count -eq 0 ){
            throw "No module found. Please move to a folder with a powershell module on it to import to GitHub"
        }
        
        if ($manifestPath.Count -ne 1) {
            throw "More than one module manifest found."
        }
        
        $description = (Import-PowerShellDataFile -Path $manifestPath).Description
        
        $command = 'gh repo create --public -d {description} -s {path} --disable-wiki --push'
        
        $command = $command -replace "{description}", "`"$($description)`""
        $command = $command -replace "{path}", "`"$($repoPath)`""
        
        if ($PSCmdlet.ShouldProcess("Repo", $command)) {

            Invoke-Expression $command
        } else {
            Write-Information $command
        }
    }
} Export-ModuleMember -Function New-RepoFromModule