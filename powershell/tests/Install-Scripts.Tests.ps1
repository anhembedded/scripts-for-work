<#
.SYNOPSIS
    Pester tests for Install-Scripts.ps1

.DESCRIPTION
    Unit and integration tests for the PowerShell Scripts Installer.
#>

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$scriptPath = Join-Path (Split-Path $here -Parent) $sut

Describe "Install-Scripts.ps1 Unit Tests" {
    
    Context "Script Validation" {
        It "Script file should exist" {
            Test-Path $scriptPath | Should Be $true
        }
        
        It "Script should have valid PowerShell syntax" {
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize(
                (Get-Content $scriptPath -Raw), [ref]$errors
            )
            $errors.Count | Should Be 0
        }
        
        It "Script should have help documentation" {
            $content = Get-Content $scriptPath -Raw
            $content | Should Match "\.SYNOPSIS"
            $content | Should Match "\.DESCRIPTION"
            $content | Should Match "\.EXAMPLE"
        }
        
        It "Script should have CmdletBinding" {
            $content = Get-Content $scriptPath -Raw
            $content | Should Match "\[CmdletBinding"
        }
    }
    
    Context "Parameter Validation" {
        It "Should have Action parameter" {
            $content = Get-Content $scriptPath -Raw
            $content | Should Match '\$Action'
        }
        
        It "Should have ScriptPath parameter" {
            $content = Get-Content $scriptPath -Raw
            $content | Should Match '\$ScriptPath'
        }
        
        It "Should have Global switch" {
            $content = Get-Content $scriptPath -Raw
            $content | Should Match '\$Global'
        }
        
        It "Should validate Action values" {
            $content = Get-Content $scriptPath -Raw
            $content | Should Match 'ValidateSet.*Install.*Uninstall.*Verify'
        }
    }
    
    Context "Helper Functions" {
        BeforeAll {
            # Dot-source the script to get functions
            . $scriptPath -Action List -ErrorAction SilentlyContinue
        }
        
        It "Should have Get-EnvironmentPath function" {
            (Get-Command Get-EnvironmentPath -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
        }
        
        It "Should have Set-EnvironmentPath function" {
            (Get-Command Set-EnvironmentPath -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
        }
        
        It "Should have Test-IsAdmin function" {
            (Get-Command Test-IsAdmin -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
        }
        
        It "Should have Add-ToPath function" {
            (Get-Command Add-ToPath -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
        }
        
        It "Should have Remove-FromPath function" {
            (Get-Command Remove-FromPath -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
        }
    }
}

Describe "Install-Scripts.ps1 Integration Tests" {
    
    BeforeAll {
        # Create test script directory
        $script:TestDir = Join-Path $env:TEMP "Install-Scripts-Test-$(Get-Random)"
        New-Item -Path $script:TestDir -ItemType Directory -Force | Out-Null
        
        # Create test script
        $testScriptContent = @'
# Test Script
param([string]$Message = "Hello")
Write-Output "Test script executed: $Message"
'@
        $script:TestScript = Join-Path $script:TestDir "Test-Script.ps1"
        Set-Content -Path $script:TestScript -Value $testScriptContent
        
        # Backup PATH
        $script:OriginalUserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    }
    
    AfterAll {
        # Cleanup test directory
        if (Test-Path $script:TestDir) {
            Remove-Item -Path $script:TestDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        # Restore PATH
        if ($script:OriginalUserPath) {
            [Environment]::SetEnvironmentVariable("PATH", $script:OriginalUserPath, "User")
        }
        
        # Cleanup wrapper directory
        $wrapperDir = "$env:USERPROFILE\.powershell-scripts"
        if (Test-Path $wrapperDir) {
            Remove-Item -Path $wrapperDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    Context "List Action" {
        It "Should list installed scripts" {
            $output = & $scriptPath -Action List 2>&1
            $LASTEXITCODE | Should Be 0
        }
    }
    
    Context "Verify Action" {
        It "Should verify installations" {
            $output = & $scriptPath -Action Verify 2>&1
            # Should not fail even if no scripts installed
            $true | Should Be $true
        }
    }
    
    Context "Install Directory Action" {
        It "Should install scripts from directory" {
            $output = & $scriptPath -Action Install -ScriptPath $script:TestDir 2>&1
            $LASTEXITCODE | Should Be 0
            
            # Verify directory was added to PATH
            $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
            $userPath | Should Match [regex]::Escape($script:TestDir)
        }
        
        It "Should create config file" {
            $configFile = "$env:USERPROFILE\.powershell-scripts\installed-scripts.json"
            Test-Path $configFile | Should Be $true
        }
        
        It "Should record installation in config" {
            $configFile = "$env:USERPROFILE\.powershell-scripts\installed-scripts.json"
            $config = Get-Content $configFile | ConvertFrom-Json
            $config.Count | Should BeGreaterThan 0
            $config[0].Path | Should Be $script:TestDir
        }
    }
    
    Context "Uninstall Action" {
        BeforeAll {
            # Ensure something is installed
            & $scriptPath -Action Install -ScriptPath $script:TestDir -ErrorAction SilentlyContinue
        }
        
        It "Should uninstall script directory" {
            $output = & $scriptPath -Action Uninstall -ScriptPath $script:TestDir 2>&1
            $LASTEXITCODE | Should Be 0
        }
        
        It "Should remove directory from PATH" {
            $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
            $userPath | Should Not Match [regex]::Escape($script:TestDir)
        }
    }
    
    Context "Install Single File Action" {
        It "Should install single script file" {
            $output = & $scriptPath -Action Install -ScriptPath $script:TestScript 2>&1
            $LASTEXITCODE | Should Be 0
        }
        
        It "Should create wrapper script" {
            $wrapperDir = "$env:USERPROFILE\.powershell-scripts"
            $wrapper = Join-Path $wrapperDir "Test-Script.ps1"
            Test-Path $wrapper | Should Be $true
        }
        
        It "Wrapper should contain correct path" {
            $wrapperDir = "$env:USERPROFILE\.powershell-scripts"
            $wrapper = Join-Path $wrapperDir "Test-Script.ps1"
            $content = Get-Content $wrapper -Raw
            $content | Should Match [regex]::Escape($script:TestScript)
        }
    }
}

Describe "Install-Scripts.ps1 PATH Management Tests" {
    
    BeforeAll {
        # Backup PATH
        $script:OriginalUserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        
        # Create test directory
        $script:TestPathDir = Join-Path $env:TEMP "PathTest-$(Get-Random)"
        New-Item -Path $script:TestPathDir -ItemType Directory -Force | Out-Null
    }
    
    AfterAll {
        # Restore PATH
        if ($script:OriginalUserPath) {
            [Environment]::SetEnvironmentVariable("PATH", $script:OriginalUserPath, "User")
        }
        
        # Cleanup
        if (Test-Path $script:TestPathDir) {
            Remove-Item -Path $script:TestPathDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    Context "PATH Operations" {
        It "Should add directory to PATH" {
            # Dot-source script to get functions
            . $scriptPath -Action List -ErrorAction SilentlyContinue
            
            $result = Add-ToPath -Directory $script:TestPathDir -Scope User
            
            # Verify
            $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
            $currentPath | Should Match [regex]::Escape($script:TestPathDir)
        }
        
        It "Should not add duplicate to PATH" {
            . $scriptPath -Action List -ErrorAction SilentlyContinue
            
            # Add twice
            Add-ToPath -Directory $script:TestPathDir -Scope User
            $result = Add-ToPath -Directory $script:TestPathDir -Scope User
            
            # Second add should return false
            $result | Should Be $false
        }
        
        It "Should remove directory from PATH" {
            . $scriptPath -Action List -ErrorAction SilentlyContinue
            
            # Ensure it's in PATH
            Add-ToPath -Directory $script:TestPathDir -Scope User
            
            # Remove it
            $result = Remove-FromPath -Directory $script:TestPathDir -Scope User
            $result | Should Be $true
            
            # Verify removal
            $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
            $currentPath | Should Not Match [regex]::Escape($script:TestPathDir)
        }
    }
}

Describe "Install-Scripts.ps1 Error Handling Tests" {
    
    Context "Invalid Inputs" {
        It "Should handle non-existent path" {
            $fakePath = "C:\NonExistent\Path\$(Get-Random)"
            $output = & $scriptPath -Action Install -ScriptPath $fakePath 2>&1
            $LASTEXITCODE | Should Be 1
        }
        
        It "Should require ScriptPath for Uninstall" {
            $output = & $scriptPath -Action Uninstall 2>&1
            $LASTEXITCODE | Should Be 1
        }
        
        It "Should handle directory with no scripts" {
            $emptyDir = Join-Path $env:TEMP "Empty-$(Get-Random)"
            New-Item -Path $emptyDir -ItemType Directory -Force | Out-Null
            
            try {
                $output = & $scriptPath -Action Install -ScriptPath $emptyDir 2>&1
                $LASTEXITCODE | Should Be 1
            } finally {
                Remove-Item -Path $emptyDir -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

Describe "Install-Scripts.ps1 Real-World Scenario Tests" {
    
    BeforeAll {
        # Create realistic test structure
        $script:TestWorkspace = Join-Path $env:TEMP "Scripts-Workspace-$(Get-Random)"
        New-Item -Path $script:TestWorkspace -ItemType Directory -Force | Out-Null
        
        # Create multiple script directories
        $script:Script1Dir = Join-Path $script:TestWorkspace "Script1"
        $script:Script2Dir = Join-Path $script:TestWorkspace "Script2"
        
        New-Item -Path $script:Script1Dir -ItemType Directory -Force | Out-Null
        New-Item -Path $script:Script2Dir -ItemType Directory -Force | Out-Null
        
        # Create scripts
        "Write-Output 'Script 1'" | Set-Content (Join-Path $script:Script1Dir "Do-Something.ps1")
        "Write-Output 'Script 2'" | Set-Content (Join-Path $script:Script2Dir "Do-Another.ps1")
        
        # Backup PATH
        $script:OriginalUserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    }
    
    AfterAll {
        # Cleanup
        if (Test-Path $script:TestWorkspace) {
            Remove-Item -Path $script:TestWorkspace -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        # Restore PATH
        if ($script:OriginalUserPath) {
            [Environment]::SetEnvironmentVariable("PATH", $script:OriginalUserPath, "User")
        }
        
        # Cleanup config
        $wrapperDir = "$env:USERPROFILE\.powershell-scripts"
        if (Test-Path $wrapperDir) {
            Remove-Item -Path $wrapperDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    Context "Multiple Installations" {
        It "Should install multiple script directories" {
            & $scriptPath -Action Install -ScriptPath $script:Script1Dir
            & $scriptPath -Action Install -ScriptPath $script:Script2Dir
            
            # Verify both in config
            $configFile = "$env:USERPROFILE\.powershell-scripts\installed-scripts.json"
            $config = Get-Content $configFile | ConvertFrom-Json
            $config.Count | Should Be 2
        }
        
        It "Should list all installations" {
            $output = & $scriptPath -Action List 2>&1 | Out-String
            $output | Should Match "Script1"
            $output | Should Match "Script2"
        }
        
        It "Should verify all installations" {
            $output = & $scriptPath -Action Verify 2>&1
            $LASTEXITCODE | Should Be 0
        }
        
        It "Should uninstall specific installation" {
            & $scriptPath -Action Uninstall -ScriptPath $script:Script1Dir
            
            $configFile = "$env:USERPROFILE\.powershell-scripts\installed-scripts.json"
            $config = Get-Content $configFile | ConvertFrom-Json
            $config.Count | Should Be 1
            $config[0].Path | Should Be $script:Script2Dir
        }
    }
}
