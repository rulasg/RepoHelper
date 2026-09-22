function Get-RepoFile{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][string]$Repo,
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Content,
        [Parameter()][string]$branch
    )

    throw "WIP"

    $repoView = Get-Repo -Owner $Owner -Repo $Repo

    if(-not $repoView){
        throw "Failed to get repository view for $Owner/$Repo"
    }

    $branch = [string]::IsNullOrEmpty($branch) ? $repoView.defaultBranch : $branch

    # 1) Get default branch and its latest commit SHA
    # 2) Create new branch from default branch tip
    New-RepoBranch -owner $owner -Repo $Repo -NewBranch $branch -baseBranch $defaultBranch

    # 3) Prepare base64 content
    # 4) If file exists, get SHA (required for update)
    # 5) Create/update file in that branch
    Set-RepoFile -Owner $owner -Repo $Repo -Content $Content -path $path -branch $branch

    # 6) Create a pull request for the new branch
    gh pr create --repo "$owner/$Repo" --base "$defaultBranch" --head "$branch" --title "Update $path" --body "Automated update via gh api."

} Export-ModuleMember -Function Get-RepoFile