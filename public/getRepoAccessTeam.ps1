
Set-MyInvokeCommandAlias -Alias "GetUser" -Command "gh api users/{login}"

<#
.SYNOPSIS
    Get the list of users with access in descriptive format
#>

function Get-RepoAccessTeam{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter()] [string]$Owner,
        [Parameter()] [string]$Repo,
        [Parameter()] [switch]$NoHeaders,
        [Parameter()] [string]$Role
    )

    # Resolve repo name from parameters or environment
    $owner,$repo = Get-Environment $owner $repo
    
    # Error if parameters not set. No need to check repo too.
    if([string]::IsNullOrEmpty($Owner)){
        "Owner and Repo parameters are required" | Write-Error
        return $null
    }
    $ret = @()

    # HEADER
    if(-not $NoHeaders){
        $ret += "| Photo                      | Name   | Access   | Email   | Handle | Company    |"
        $ret += "|----------------------------|--------|----------|---------|--------|------------|" 
    }
    
    # Get access Control
    $accessList = Get-RepoAccess -Owner $owner -Repo $repo -Role:$Role
    

    # Sort by access
    $accessList = $accessList.GetEnumerator() | Sort-Object -Property  Value
    
    # Create lines for each access
    # Foreach($access in $accessList){
        #     $login = $access.Name
        #     $value = $access.Value
        
    #     $templateLine ="| {avatar} | {name} | {access} | {email} |  [@{login}](https://https://github.com/{login}) | {company}  |"
    #     $user = Get-RepoUser -Login $login
    #     $avatar =  '<img alt="" width="100" height="100" class="avatar width-full height-full avatar-before-user-status" src="https://avatars.githubusercontent.com/{login}">' -replace '{login}',$login

    #     $userline = $templateLine
    #     $userline = $userline -replace '{login}',   $user.login
    #     $userline = $userline -replace '{avatar}',  $avatar
    #     $userline = $userline -replace '{name}',    $user.name
    #     $userline = $userline -replace '{access}',  $value
    #     $userline = $userline -replace '{email}',   $user.email
    #     $userline = $userline -replace '{company}', $user.company

    #     $ret+= $userline
    # }

    $ret+= $accessList | ForEach-Object {New-UserAccessLine -Login $_.Name -Access $_.Value}

    return $ret
} Export-ModuleMember -Function Get-RepoAccessTeam

function New-UserAccessLine{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,ValueFromPipeline)][string]$Login,
        [Parameter(Position=1,ValueFromPipeline)][string]$Access
    )

    process{

        $user = Get-RepoUser -Login $login

        if($null -eq $user){
            "Error: $login not found" | Write-Error
            return
        }

        $user | Write-Verbose

        $templateLine ="| {avatar} | {name} | {access} | {email} |  [@{login}](https://github.com/{login}) | {company}  |"

        $avatar =  '<img alt="" width="100" height="100" class="avatar width-full height-full avatar-before-user-status" src="https://avatars.githubusercontent.com/{login}">' -replace '{login}',$login

        $userline = $templateLine
        $userline = $userline -replace '{login}',   $user.login
        $userline = $userline -replace '{avatar}',  $avatar
        $userline = $userline -replace '{name}',    $user.name
        $userline = $userline -replace '{access}',  $Access
        $userline = $userline -replace '{email}',   $user.email
        $userline = $userline -replace '{company}', $user.company

        return $userline
    }
} Export-ModuleMember -Function New-UserAccessLine

function Get-RepoUser{
    [CmdletBinding()]
    param (
        [Parameter(Position=0,ValueFromPipeline)][string]$Login
    )

    process{

        $result = Get-UserInfo -Login $Login

        if($null -eq $result){
            "Error: $Login not found" | Write-Error
            return
        }
        $ret = [PSCustomObject]@{
            login = $result.login
            name = $result.name
            avatar_url = $result.avatar_url
            company = $result.company
            email = $result.email
            location = $result.location
            html_url = $result.html_url
            created_at = $result.created_at
        }

        return $ret
    }
} Export-ModuleMember -Function Get-RepoUser

function Get-UserInfo{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Position=0,ValueFromPipeline)][string]$Login
    )

    process{
        $user = Invoke-MyCommandJson -Command GetUser -Parameters @{login = $Login}

        if($user.login -ne $Login){
            "Error: $login not found" | Write-Error
            return $null
        }

        return $user
    }
} Export-ModuleMember -Function Get-UserInfo

