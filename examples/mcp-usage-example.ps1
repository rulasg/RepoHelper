# MCP Configuration Usage Example
# This script demonstrates how to use the MCP configuration with RepoHelper

# Import the MCP functions
. ./public/mcp-config.ps1

# Example 1: Basic setup with GitHub token
Write-Host "=== MCP Configuration Example ===" -ForegroundColor Green

# Prompt for GitHub token (in real usage)
Write-Host "Example: Setting up GitHub token..." -ForegroundColor Yellow
$exampleToken = ConvertTo-SecureString "ghp_example_token_12345" -AsPlainText -Force
Set-MCPConfiguration -GitHubToken $exampleToken -InformationAction Continue

# Test the configuration
Write-Host "`nTesting configuration..." -ForegroundColor Yellow
$testResult = Test-MCPConfiguration -InformationAction Continue
Write-Host "Configuration test result: $testResult" -ForegroundColor Cyan

# View the configuration
Write-Host "`nCurrent MCP Configuration:" -ForegroundColor Yellow
$config = Get-MCPConfiguration
$serverNames = $config.mcpServers.PSObject.Properties.Name
Write-Host "Found $($serverNames.Count) MCP servers:" -ForegroundColor Cyan
foreach ($serverName in $serverNames) {
    $server = $config.mcpServers.$serverName
    Write-Host "  - ${serverName}: $($server.command)" -ForegroundColor White
}

# Example 2: Check environment variables
Write-Host "`nEnvironment Variables:" -ForegroundColor Yellow
$githubToken = [Environment]::GetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN")
if ($githubToken) {
    Write-Host "GitHub token is configured (length: $($githubToken.Length))" -ForegroundColor Green
} else {
    Write-Host "GitHub token is not configured" -ForegroundColor Red
}

# Example 3: Start specific server (demonstration)
Write-Host "`nStarting MCP servers (demonstration)..." -ForegroundColor Yellow
Start-MCPServers -ServerName "github" -InformationAction Continue -WhatIf

# Clean up (in real usage, you might want to keep the token)
Write-Host "`nCleaning up..." -ForegroundColor Yellow
[Environment]::SetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN", $null, "Process")
Write-Host "Example completed." -ForegroundColor Green