# MCP (Model Context Protocol) Configuration

This directory contains the MCP (Model Context Protocol) configuration for the RepoHelper module, enabling GitHub API access and .NET MCP server integration.

## Configuration Files

- `mcp-config.json` - Main MCP configuration file
- `public/mcp-config.ps1` - PowerShell helper functions for MCP management

## Setup Instructions

### 1. Install Prerequisites

- Node.js (for GitHub MCP server)
- Docker (for .NET MCP server)
- PowerShell 7+ (for RepoHelper module)

### 2. Configure GitHub Personal Access Token

```powershell
# Import the RepoHelper module
Import-Module ./RepoHelper.psd1

# Set up MCP configuration with your GitHub token
$token = Read-Host "Enter your GitHub Personal Access Token" -AsSecureString
Set-MCPConfiguration -GitHubToken $token
```

### 3. Test Configuration

```powershell
# Test the MCP configuration
Test-MCPConfiguration

# View current configuration
Get-MCPConfiguration
```

### 4. Start MCP Servers

```powershell
# Start all MCP servers
Start-MCPServers

# Start specific server
Start-MCPServers -ServerName "github"
```

## GitHub Personal Access Token Requirements

Your GitHub Personal Access Token needs the following permissions:

- `repo` - Full repository access
- `read:org` - Read organization membership
- `read:user` - Read user profile information
- `read:project` - Read project information

## MCP Server Configuration

### GitHub Server

The GitHub MCP server provides:
- Repository management tools
- Issue and pull request access
- Organization and user information
- Repository properties and settings

### .NET MCP Server

The .NET MCP server runs in a Docker container and provides:
- Extended functionality for repository operations
- Custom tools and resources
- Integration with .NET ecosystem

## Troubleshooting

### Common Issues

1. **GitHub Token Not Set**
   ```
   Error: GitHub Personal Access Token not configured
   ```
   Solution: Use `Set-MCPConfiguration` to set your token

2. **Docker Not Available**
   ```
   Warning: Docker is not available. .NET MCP server will not work.
   ```
   Solution: Install Docker and ensure it's running

3. **Node.js Not Found**
   ```
   Error: npx command not found
   ```
   Solution: Install Node.js and npm

### Logging

MCP server logs are stored in `./logs/mcp.log` by default. You can check this file for detailed error information.

## Security Notes

- The GitHub Personal Access Token is stored as an environment variable for the current session only
- Never commit your actual token to version control
- Use secure methods to store and retrieve your token
- Consider using GitHub Apps for production deployments

## Configuration Schema

The `mcp-config.json` file follows this schema:

```json
{
  "mcpServers": {
    "server-name": {
      "command": "executable-command",
      "args": ["array", "of", "arguments"],
      "env": {
        "ENV_VAR": "value"
      },
      "description": "Server description",
      "capabilities": ["tools", "resources", "prompts"]
    }
  },
  "defaults": {
    "timeout": 30000,
    "maxRetries": 3
  },
  "logging": {
    "level": "info",
    "file": "./logs/mcp.log"
  }
}
```

## Contributing

When adding new MCP servers:

1. Add the server configuration to `mcp-config.json`
2. Update the PowerShell helper functions in `public/mcp-config.ps1`
3. Add tests for the new functionality
4. Update this documentation