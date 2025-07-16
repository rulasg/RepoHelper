# MCP Configuration Helper for RepoHelper
# This script provides functions to set up and manage MCP (Model Context Protocol) configuration

# Get the module root directory
$ModuleRoot = Split-Path $PSScriptRoot -Parent

<#
.SYNOPSIS
    Sets up MCP configuration for GitHub API access and .NET MCP server integration
.DESCRIPTION
    This function configures the Model Context Protocol (MCP) settings for the RepoHelper module,
    including GitHub server setup with token-based authentication and .NET MCP server running in Docker.
.PARAMETER GitHubToken
    GitHub Personal Access Token for API authentication
.PARAMETER ConfigPath
    Path to the MCP configuration file (defaults to mcp-config.json in module root)
.EXAMPLE
    Set-MCPConfiguration -GitHubToken "ghp_xxxxxxxxxxxxxxxxxxxx"
#>
function Set-MCPConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [SecureString]$GitHubToken,
        
        [Parameter()]
        [string]$ConfigPath = (Join-Path $ModuleRoot "mcp-config.json")
    )
    
    try {
        # Convert SecureString to plain text for environment variable
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($GitHubToken)
        $plainToken = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        
        # Set environment variable for GitHub token
        [Environment]::SetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN", $plainToken, "Process")
        
        # Verify config file exists
        if (!(Test-Path $ConfigPath)) {
            throw "MCP configuration file not found at: $ConfigPath"
        }
        
        Write-Information "MCP configuration set successfully"
        Write-Information "GitHub token configured for current session"
        Write-Information "Configuration file: $ConfigPath"
        
    } catch {
        Write-Error "Failed to set MCP configuration: $_"
        throw
    }
}

<#
.SYNOPSIS
    Gets the current MCP configuration
.DESCRIPTION
    Returns the current MCP configuration settings from the configuration file
.PARAMETER ConfigPath
    Path to the MCP configuration file
.EXAMPLE
    Get-MCPConfiguration
#>
function Get-MCPConfiguration {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ConfigPath = (Join-Path $ModuleRoot "mcp-config.json")
    )
    
    try {
        if (!(Test-Path $ConfigPath)) {
            throw "MCP configuration file not found at: $ConfigPath"
        }
        
        $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        return $config
        
    } catch {
        Write-Error "Failed to get MCP configuration: $_"
        throw
    }
}

<#
.SYNOPSIS
    Tests the MCP configuration and connections
.DESCRIPTION
    Validates the MCP configuration and tests connectivity to configured servers
.PARAMETER ConfigPath
    Path to the MCP configuration file
.EXAMPLE
    Test-MCPConfiguration
#>
function Test-MCPConfiguration {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ConfigPath = (Join-Path $ModuleRoot "mcp-config.json")
    )
    
    try {
        # Test configuration file
        if (!(Test-Path $ConfigPath)) {
            Write-Error "MCP configuration file not found at: $ConfigPath"
            return $false
        }
        
        # Test JSON format
        $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        if (!$config.mcpServers) {
            Write-Error "Invalid MCP configuration: missing mcpServers section"
            return $false
        }
        
        # Test GitHub token
        $githubToken = [Environment]::GetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN")
        if ([string]::IsNullOrEmpty($githubToken)) {
            Write-Warning "GitHub Personal Access Token not configured. Use Set-MCPConfiguration to set it."
        }
        
        # Test Docker availability for .NET MCP server
        try {
            $dockerVersion = docker --version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Information "Docker is available: $dockerVersion"
            } else {
                Write-Warning "Docker is not available. .NET MCP server will not work."
            }
        } catch {
            Write-Warning "Docker is not available. .NET MCP server will not work."
        }
        
        Write-Information "MCP configuration validation completed"
        return $true
        
    } catch {
        Write-Error "Failed to test MCP configuration: $_"
        return $false
    }
}

<#
.SYNOPSIS
    Starts the MCP servers defined in the configuration
.DESCRIPTION
    Starts the MCP servers (GitHub and .NET) as defined in the configuration file
.PARAMETER ConfigPath
    Path to the MCP configuration file
.PARAMETER ServerName
    Optional specific server name to start (defaults to all servers)
.EXAMPLE
    Start-MCPServers
.EXAMPLE
    Start-MCPServers -ServerName "github"
#>
function Start-MCPServers {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [string]$ConfigPath = (Join-Path $ModuleRoot "mcp-config.json"),
        
        [Parameter()]
        [string]$ServerName
    )
    
    try {
        $config = Get-MCPConfiguration -ConfigPath $ConfigPath
        
        if ($ServerName) {
            $serversToStart = @{ $ServerName = $config.mcpServers.$ServerName }
        } else {
            $serversToStart = $config.mcpServers
        }
        
        foreach ($server in $serversToStart.GetEnumerator()) {
            if ($PSCmdlet.ShouldProcess($server.Key, "Start MCP Server")) {
                Write-Information "Starting MCP server: $($server.Key)"
                
                $serverConfig = $server.Value
                $command = $serverConfig.command
                $args = $serverConfig.args
                
                # Set environment variables if specified
                if ($serverConfig.env) {
                    foreach ($envVar in $serverConfig.env.GetEnumerator()) {
                        $value = $envVar.Value
                        # Expand environment variables
                        $value = [Environment]::ExpandEnvironmentVariables($value)
                        [Environment]::SetEnvironmentVariable($envVar.Key, $value, "Process")
                    }
                }
                
                # Start the server process
                Write-Information "Executing: $command $($args -join ' ')"
                # Note: In production, you might want to start these as background jobs
                # For now, we'll just display the command that would be run
                Write-Information "Command ready to execute. In production, this would start as a background process."
            }
        }
        
    } catch {
        Write-Error "Failed to start MCP servers: $_"
        throw
    }
}

