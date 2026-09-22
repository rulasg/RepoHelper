function Set-RepoFile{
    param(
        [Parameter(Mandatory)][string]$Owner,
        [Parameter(Mandatory)][string]$Repo,
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Content,
        [Parameter()][string]$branch
    )

    $random = (New-Guid).ToString().Substring(0,8)

    # Defaults
    $Owner = [string]::IsNullOrEmpty($Owner) ? "githubcustomers" : $Owner
    $path = [string]::IsNullOrEmpty($path) ? ".github/collaborators.yml" : $path
    $branch = [string]::IsNullOrEmpty($branch) ? "patch-$random" : $branch

    "Set-RepoFile for [$Owner/$Repo/$path] on branch [$branch] >>>" | Write-MyDebug -section "repofile"

    # 3) Prepare base64 content
    $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Content))

    "Content to Base64: $b64" | Write-MyDebug -section "repofile"

    $urlpath = "repos/$Owner/$Repo/contents/$($path)"
    $fullUrlPath =  "$urlpath"+"?ref=$branch"

    # 4) If file exists, get SHA (required for update)
    $fileSha = $null
    try {
        "Getting SHA for file [$urlpath] in branch [$branch]" | Write-MyDebug -section "repofile"
        $fileSha = gh api "$fullUrlPath" --jq .sha 2>$null
    } catch {}

    "Sha: $fileSha" | Write-MyDebug -section "repofile"

    # 5) Create/update file in that branch
    if ($fileSha) {
        "Updating existing file [$urlpath] in branch [$branch]" | Write-MyDebug -section "repofile"
        gh api -X PUT "$urlpath" `
        -f message="Update $path" `
        -f content="$b64" `
        -f branch="$branch" `
        -f sha="$fileSha"
    } else {
        "Adding  file [$urlpath] in branch [$branch]" | Write-MyDebug -section "repofile"
        gh api -X PUT "$urlpath" `
            -f message="Add $path" `
            -f content="$b64" `
            -f branch="$branch"
    }

    "Set-RepoFile for [$Owner/$Repo/$path] on branch [$branch] <<<" | Write-MyDebug -section "repofile"
    "Set-RepoFile for [$urlpath] on branch [$branch] <<<" | Write-MyDebug -section "repofile"

} Export-ModuleMember -Function Set-RepoFile