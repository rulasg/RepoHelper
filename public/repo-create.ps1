function New-RepoFromModule {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # path parameter
        [Parameter(ValueFromPipelineByPropertyName)] [string] $Path
    )

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
} Export-ModuleMember -Function New-RepoFromModule