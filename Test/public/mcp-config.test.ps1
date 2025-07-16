BeforeAll {
    # Import the MCP functions directly since the module has dependency issues
    . "$PSScriptRoot/../../public/mcp-config.ps1"
}

Describe "MCP Configuration Tests" {
    Context "MCP Configuration File" {
        It "Should exist" {
            $configPath = Join-Path $PSScriptRoot "../../mcp-config.json"
            Test-Path $configPath | Should -Be $true
        }
        
        It "Should be valid JSON" {
            $configPath = Join-Path $PSScriptRoot "../../mcp-config.json"
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            $config | Should -Not -BeNullOrEmpty
        }
        
        It "Should have mcpServers section" {
            $configPath = Join-Path $PSScriptRoot "../../mcp-config.json"
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            $config.mcpServers | Should -Not -BeNullOrEmpty
        }
        
        It "Should have github server configuration" {
            $configPath = Join-Path $PSScriptRoot "../../mcp-config.json"
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            $config.mcpServers.github | Should -Not -BeNullOrEmpty
            $config.mcpServers.github.command | Should -Be "npx"
        }
        
        It "Should have dotnet-mcp server configuration" {
            $configPath = Join-Path $PSScriptRoot "../../mcp-config.json"
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            $config.mcpServers.'dotnet-mcp' | Should -Not -BeNullOrEmpty
            $config.mcpServers.'dotnet-mcp'.command | Should -Be "docker"
        }
    }
    
    Context "MCP Helper Functions" {
        It "Get-MCPConfiguration should work" {
            $config = Get-MCPConfiguration
            $config | Should -Not -BeNullOrEmpty
            $config.mcpServers | Should -Not -BeNullOrEmpty
        }
        
        It "Test-MCPConfiguration should validate config" {
            $result = Test-MCPConfiguration
            $result | Should -Be $true
        }
        
        It "Set-MCPConfiguration should accept SecureString token" {
            $token = ConvertTo-SecureString "test-token" -AsPlainText -Force
            { Set-MCPConfiguration -GitHubToken $token } | Should -Not -Throw
        }
    }
    
    Context "Environment Variables" {
        It "Should handle GitHub token environment variable" {
            $token = ConvertTo-SecureString "test-token-12345" -AsPlainText -Force
            Set-MCPConfiguration -GitHubToken $token
            
            $envToken = [Environment]::GetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN")
            $envToken | Should -Be "test-token-12345"
        }
    }
}

AfterAll {
    # Clean up environment variables
    [Environment]::SetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN", $null, "Process")
}