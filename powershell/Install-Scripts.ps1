<#
.SYNOPSIS
    Installs PowerShell scripts to system PATH for global access.

.DESCRIPTION
    This installer script adds PowerShell script directories to the user's PATH
    environment variable, allowing scripts to be run from any directory.
    
    Features:
    - Adds script directories to User PATH (no admin required)
    - Creates wrapper scripts for .ps1 files in system PATH
    - Validates installations
    - Supports multiple script directories
    - Can uninstall/remove scripts from PATH

.PARAMETER Action
    Action to perform: Install, Uninstall, or Verify

.PARAMETER ScriptPath
    Path to the script directory or specific script to install.
    If not provided, installs all scripts in current directory.

.PARAMETER Global
    If specified, installs to System PATH (requires admin).
    Default is User PATH (no admin required).

.EXAMPLE
    .\Install-Scripts.ps1 -Action Install
    Install all scripts in current directory to User PATH

.EXAMPLE
    .\Install-Scripts.ps1 -Action Install -ScriptPath "C:\Scripts\Convert-UmlToSvg"
    Install specific script directory to User PATH

.EXAMPLE
    .\Install-Scripts.ps1 -Action Verify
    Verify all installed scripts

.EXAMPLE
    .\Install-Scripts.ps1 -Action Uninstall -ScriptPath "C:\Scripts\Convert-UmlToSvg"
    Remove script directory from PATH

.NOTES
    Author: GitHub Copilot
    Version: 1.0.0
    Requires: PowerShell 5.1+
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("Install", "Uninstall", "Verify", "List")]
    [string]$Action = "Install",

    [Parameter(Mandatory = $false)]
    [string]$ScriptPath,

    [Parameter(Mandatory = $false)]
    [switch]$Global,

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# Script version
$script:Version = "1.0.0"

# Import Logger module
$modulePath = Join-Path $PSScriptRoot "modules\Logger.psm1"
if (Test-Path $modulePath) {
    Import-Module $modulePath -Force
} else {
    # Fallback to simple Write-Host if module not found
    function Write-Log {
        param(
            [string]$Message,
            [ValidateSet("INFO", "WARNING", "ERROR")]
            [string]$Level = "INFO"
        )
        $color = switch ($Level) {
            "INFO"    { "Cyan" }
            "WARNING" { "Yellow" }
            "ERROR"   { "Red" }
        }
        Write-Host "[$Level] $Message" -ForegroundColor $color
    }
}

# Configuration
$script:Config = @{
    WrapperDir = "$env:USERPROFILE\.powershell-scripts"
    ConfigFile = "$env:USERPROFILE\.powershell-scripts\installed-scripts.json"
}

#region Helper Functions

function Get-EnvironmentPath {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("User", "Machine")]
        [string]$Scope
    )
    
    $target = if ($Scope -eq "User") { 
        [System.EnvironmentVariableTarget]::User 
    } else { 
        [System.EnvironmentVariableTarget]::Machine 
    }
    
    return [Environment]::GetEnvironmentVariable("PATH", $target)
}

function Set-EnvironmentPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$NewPath,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet("User", "Machine")]
        [string]$Scope
    )
    
    $target = if ($Scope -eq "User") { 
        [System.EnvironmentVariableTarget]::User 
    } else { 
        [System.EnvironmentVariableTarget]::Machine 
    }
    
    [Environment]::SetEnvironmentVariable("PATH", $NewPath, $target)
    
    # Update current session
    $env:PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + 
                [Environment]::GetEnvironmentVariable("PATH", "User")
}

function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-InstalledScripts {
    if (Test-Path $script:Config.ConfigFile) {
        $content = Get-Content $script:Config.ConfigFile | ConvertFrom-Json
        # Ensure we always return an array
        if ($content -is [array]) {
            return $content
        } elseif ($null -ne $content) {
            return @($content)
        }
    }
    return @()
}

function Save-InstalledScripts {
    param([array]$Scripts)
    
    $configDir = Split-Path $script:Config.ConfigFile -Parent
    if (-not (Test-Path $configDir)) {
        New-Item -Path $configDir -ItemType Directory -Force | Out-Null
    }
    
    $Scripts | ConvertTo-Json | Set-Content $script:Config.ConfigFile
}

function Add-ToPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Directory,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("User", "Machine")]
        [string]$Scope = "User"
    )
    
    # Validate directory exists
    if (-not (Test-Path $Directory)) {
        throw "Directory does not exist: $Directory"
    }
    
    # Get current PATH
    $currentPath = Get-EnvironmentPath -Scope $Scope
    $pathDirs = $currentPath -split ';' | Where-Object { $_ }
    
    # Check if already in PATH
    $normalizedDir = $Directory.TrimEnd('\')
    $alreadyExists = $pathDirs | Where-Object { 
        $_.TrimEnd('\') -eq $normalizedDir 
    }
    
    if ($alreadyExists) {
        Write-Log "Directory already in PATH: $Directory" -Level WARNING
        return $false
    }
    
    # Add to PATH
    $newPath = "$currentPath;$Directory"
    Set-EnvironmentPath -NewPath $newPath -Scope $Scope
    
    Write-Log "Added to $Scope PATH: $Directory" -Level SUCCESS
    return $true
}

function Remove-FromPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Directory,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("User", "Machine")]
        [string]$Scope = "User"
    )
    
    # Get current PATH
    $currentPath = Get-EnvironmentPath -Scope $Scope
    $pathDirs = $currentPath -split ';' | Where-Object { $_ }
    
    # Remove directory from PATH
    $normalizedDir = $Directory.TrimEnd('\')
    $newPathDirs = $pathDirs | Where-Object { 
        $_.TrimEnd('\') -ne $normalizedDir 
    }
    
    if ($pathDirs.Count -eq $newPathDirs.Count) {
        Write-Log "Directory not found in PATH: $Directory" -Level WARNING
        return $false
    }
    
    # Update PATH
    $newPath = $newPathDirs -join ';'
    Set-EnvironmentPath -NewPath $newPath -Scope $Scope
    
    Write-Log "Removed from $Scope PATH: $Directory" -Level SUCCESS
    return $true
}

function New-ScriptWrapper {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,
        
        [Parameter(Mandatory = $true)]
        [string]$WrapperDir
    )
    
    $scriptName = Split-Path $ScriptPath -Leaf
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($scriptName)
    $wrapperPath = Join-Path $WrapperDir "$baseName.ps1"
    
    # Create wrapper script
    $wrapperContent = @"
# Wrapper for: $ScriptPath
# Generated by Install-Scripts.ps1 v$($script:Version)

param(
    [Parameter(ValueFromRemainingArguments=`$true)]
    `$Arguments
)

`$scriptPath = "$ScriptPath"

if (-not (Test-Path `$scriptPath)) {
    Write-Error "Script not found: `$scriptPath"
    exit 1
}

# Execute the actual script with all arguments
& `$scriptPath @Arguments
"@
    
    Set-Content -Path $wrapperPath -Value $wrapperContent -Force
    Write-Log "Created wrapper: $wrapperPath" -Level SUCCESS
    
    return $wrapperPath
}

#endregion

#region Main Functions

function Install-Script {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    
    Write-Log "Installing script: $Path" -Level INFO
    
    # Validate path
    if (-not (Test-Path $Path)) {
        Write-Log "Path not found: $Path" -Level ERROR
        return $false
    }
    
    # Resolve to absolute path
    $Path = (Resolve-Path $Path).Path
    
    # Determine if it's a file or directory
    $item = Get-Item $Path
    
    if ($item -is [System.IO.DirectoryInfo]) {
        # It's a directory - install all .ps1 files
        $scripts = Get-ChildItem -Path $Path -Filter "*.ps1" -File
        
        if ($scripts.Count -eq 0) {
            Write-Log "No PowerShell scripts found in: $Path" -Level WARNING
            return $false
        }
        
        # Add directory to PATH
        $scope = if ($Global) { 
            if (-not (Test-IsAdmin)) {
                Write-Log "Admin rights required for -Global installation" -Level ERROR
                return $false
            }
            "Machine" 
        } else { 
            "User" 
        }
        
        $added = Add-ToPath -Directory $Path -Scope $scope
        
        # Save to config
        $installed = [System.Collections.ArrayList]@(Get-InstalledScripts)
        $null = $installed.Add(@{
            Path = $Path
            Type = "Directory"
            Scope = $scope
            Scripts = @($scripts.Name)
            InstalledDate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        })
        Save-InstalledScripts -Scripts $installed
        
        Write-Log "Installed $($scripts.Count) scripts from: $Path" -Level SUCCESS
        return $true
        
    } else {
        # It's a file - create wrapper
        $wrapperDir = $script:Config.WrapperDir
        
        if (-not (Test-Path $wrapperDir)) {
            New-Item -Path $wrapperDir -ItemType Directory -Force | Out-Null
        }
        
        $wrapper = New-ScriptWrapper -ScriptPath $Path -WrapperDir $wrapperDir
        
        # Add wrapper directory to PATH
        $scope = if ($Global) { 
            if (-not (Test-IsAdmin)) {
                Write-Log "Admin rights required for -Global installation" -Level ERROR
                return $false
            }
            "Machine" 
        } else { 
            "User" 
        }
        
        Add-ToPath -Directory $wrapperDir -Scope $scope
        
        # Save to config
        $installed = [System.Collections.ArrayList]@(Get-InstalledScripts)
        $null = $installed.Add(@{
            Path = $Path
            Type = "File"
            Scope = $scope
            Wrapper = $wrapper
            InstalledDate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        })
        Save-InstalledScripts -Scripts $installed
        
        Write-Log "Installed script: $Path" -Level SUCCESS
        return $true
    }
}

function Uninstall-Script {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    
    Write-Log "Uninstalling script: $Path" -Level INFO
    
    # Get installed scripts
    $installed = Get-InstalledScripts
    $normalizedPath = (Resolve-Path $Path -ErrorAction SilentlyContinue).Path
    
    if (-not $normalizedPath) {
        $normalizedPath = $Path
    }
    
    # Find matching installation
    $match = $installed | Where-Object { $_.Path -eq $normalizedPath }
    
    if (-not $match) {
        Write-Log "Script not found in installed list: $Path" -Level WARNING
        return $false
    }
    
    # Remove from PATH
    if ($match.Type -eq "Directory") {
        Remove-FromPath -Directory $match.Path -Scope $match.Scope
    } else {
        # Remove wrapper
        if (Test-Path $match.Wrapper) {
            Remove-Item $match.Wrapper -Force
            Write-Log "Removed wrapper: $($match.Wrapper)" -Level SUCCESS
        }
    }
    
    # Update config
    $remaining = $installed | Where-Object { $_.Path -ne $normalizedPath }
    Save-InstalledScripts -Scripts $remaining
    
    Write-Log "Uninstalled: $Path" -Level SUCCESS
    return $true
}

function Test-Installation {
    Write-Log "Verifying installations..." -Level INFO
    
    $installed = Get-InstalledScripts
    
    if ($installed.Count -eq 0) {
        Write-Log "No scripts installed" -Level WARNING
        return $true
    }
    
    $allValid = $true
    
    foreach ($item in $installed) {
        Write-Host "`nChecking: $($item.Path)" -ForegroundColor Cyan
        
        # Check if path exists
        if (-not (Test-Path $item.Path)) {
            Write-Log "Path not found: $($item.Path)" -Level ERROR
            $allValid = $false
            continue
        }
        
        # Check if in PATH
        $currentPath = Get-EnvironmentPath -Scope $item.Scope
        $pathDirs = $currentPath -split ';' | Where-Object { $_ }
        
        if ($item.Type -eq "Directory") {
            $inPath = $pathDirs | Where-Object { 
                $_.TrimEnd('\') -eq $item.Path.TrimEnd('\') 
            }
            
            if ($inPath) {
                Write-Log "✓ In $($item.Scope) PATH" -Level SUCCESS
                Write-Log "✓ Scripts: $($item.Scripts -join ', ')" -Level INFO
            } else {
                Write-Log "✗ Not in $($item.Scope) PATH" -Level ERROR
                $allValid = $false
            }
        } else {
            # Check wrapper
            if (Test-Path $item.Wrapper) {
                Write-Log "✓ Wrapper exists: $($item.Wrapper)" -Level SUCCESS
            } else {
                Write-Log "✗ Wrapper missing: $($item.Wrapper)" -Level ERROR
                $allValid = $false
            }
        }
        
        Write-Log "Installed: $($item.InstalledDate)" -Level INFO
    }
    
    return $allValid
}

function Show-InstalledScripts {
    Write-Log "Installed PowerShell Scripts:" -Level INFO
    
    $installed = Get-InstalledScripts
    
    if ($installed.Count -eq 0) {
        Write-Log "No scripts installed" -Level WARNING
        return
    }
    
    Write-Host "`n" -NoNewline
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Installed Scripts Summary" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    $index = 1
    foreach ($item in $installed) {
        Write-Host "`n[$index] " -NoNewline -ForegroundColor Yellow
        Write-Host "$($item.Path)" -ForegroundColor White
        Write-Host "    Type: " -NoNewline -ForegroundColor Gray
        Write-Host $item.Type -ForegroundColor Cyan
        Write-Host "    Scope: " -NoNewline -ForegroundColor Gray
        Write-Host $item.Scope -ForegroundColor Cyan
        
        if ($item.Type -eq "Directory") {
            Write-Host "    Scripts: " -NoNewline -ForegroundColor Gray
            Write-Host ($item.Scripts -join ', ') -ForegroundColor White
        } else {
            Write-Host "    Wrapper: " -NoNewline -ForegroundColor Gray
            Write-Host $item.Wrapper -ForegroundColor White
        }
        
        Write-Host "    Installed: " -NoNewline -ForegroundColor Gray
        Write-Host $item.InstalledDate -ForegroundColor Green
        
        $index++
    }
    
    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Total: $($installed.Count) installation(s)" -ForegroundColor Yellow
    Write-Host ""
}

#endregion

#region Main Script

try {
    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  PowerShell Scripts Installer v$($script:Version)" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
    
    switch ($Action) {
        "Install" {
            if (-not $ScriptPath) {
                $ScriptPath = Get-Location
            }
            
            $result = Install-Script -Path $ScriptPath
            
            if ($result) {
                Write-Host "`n✓ Installation completed successfully!" -ForegroundColor Green
                Write-Host "  Restart PowerShell or run: " -ForegroundColor Yellow -NoNewline
                Write-Host "refreshenv" -ForegroundColor White
            } else {
                Write-Host "`n✗ Installation failed!" -ForegroundColor Red
                exit 1
            }
        }
        
        "Uninstall" {
            if (-not $ScriptPath) {
                Write-Log "ScriptPath required for uninstall" -Level ERROR
                exit 1
            }
            
            $result = Uninstall-Script -Path $ScriptPath
            
            if ($result) {
                Write-Host "`n✓ Uninstallation completed!" -ForegroundColor Green
            } else {
                Write-Host "`n✗ Uninstallation failed!" -ForegroundColor Red
                exit 1
            }
        }
        
        "Verify" {
            $result = Test-Installation
            
            if ($result) {
                Write-Host "`n✓ All installations verified successfully!" -ForegroundColor Green
            } else {
                Write-Host "`n✗ Some installations have issues!" -ForegroundColor Red
                exit 1
            }
        }
        
        "List" {
            Show-InstalledScripts
        }
    }
    
    Write-Host ""
    
} catch {
    Write-Log "Error: $_" -Level ERROR
    Write-Log $_.ScriptStackTrace -Level ERROR
    exit 1
}

#endregion
