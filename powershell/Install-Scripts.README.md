# Install-Scripts.ps1

Universal PowerShell script installer for system-wide access.

## 🎯 Purpose

Enables running PowerShell scripts from any directory by adding them to system PATH without manual PATH editing.

## ⚡ Quick Start

```powershell
# Install a script directory
.\Install-Scripts.ps1 -Action Install -ScriptPath "Convert-UmlToSvg"

# Restart PowerShell or refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")

# Run from anywhere
cd ~
Convert-UmlToSvg.ps1 -Check
```

## 📖 Commands

### Install
```powershell
# Install directory (all .ps1 files accessible)
.\Install-Scripts.ps1 -Action Install -ScriptPath "Convert-UmlToSvg"

# Install single file (creates wrapper)
.\Install-Scripts.ps1 -Action Install -ScriptPath "script.ps1"

# Install globally (requires admin)
.\Install-Scripts.ps1 -Action Install -ScriptPath "Convert-UmlToSvg" -Global
```

### List
```powershell
# Show all installed scripts
.\Install-Scripts.ps1 -Action List
```

### Verify
```powershell
# Check all installations are working
.\Install-Scripts.ps1 -Action Verify
```

### Uninstall
```powershell
# Remove from PATH
.\Install-Scripts.ps1 -Action Uninstall -ScriptPath "Convert-UmlToSvg"
```

## 🔧 How It Works

### Directory Installation
1. Resolves path to absolute
2. Adds directory to User PATH (or System PATH with `-Global`)
3. Saves config to `~\.powershell-scripts\installed-scripts.json`
4. All `.ps1` files in directory become globally accessible

### File Installation
1. Creates wrapper script in `~\.powershell-scripts\`
2. Wrapper forwards all arguments to original script
3. Adds wrapper directory to PATH
4. Single script becomes globally accessible

## 📋 Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Action` | String | Install | `Install`, `Uninstall`, `Verify`, `List` |
| `-ScriptPath` | String | Current dir | Path to script directory or file |
| `-Global` | Switch | False | Install to System PATH (requires admin) |
| `-Force` | Switch | False | Force installation |

## 💾 Configuration

**Location:** `%USERPROFILE%\.powershell-scripts\`

**Files:**
- `installed-scripts.json` - Installation tracking
- `*.ps1` - Wrapper scripts (for file installations)

**Example Config:**
```json
[
  {
    "Path": "C:\\Scripts\\Convert-UmlToSvg",
    "Type": "Directory",
    "Scope": "User",
    "Scripts": ["Convert-UmlToSvg.ps1"],
    "InstalledDate": "2025-10-15 12:28:05"
  }
]
```

## 🔍 Examples

### Example 1: Basic Installation
```powershell
cd scripts-for-work\powershell
.\Install-Scripts.ps1 -Action Install -ScriptPath "Convert-UmlToSvg"
# Restart PowerShell
Convert-UmlToSvg.ps1 -Check  # Works from any directory!
```

### Example 2: Multiple Scripts
```powershell
.\Install-Scripts.ps1 -Action Install -ScriptPath "Convert-UmlToSvg"
.\Install-Scripts.ps1 -Action Install -ScriptPath "Some-OtherScriptProject"
.\Install-Scripts.ps1 -Action List
```

### Example 3: Single File
```powershell
.\Install-Scripts.ps1 -Action Install -ScriptPath "automation\backup.ps1"
# Creates wrapper at: ~\.powershell-scripts\backup.ps1
backup.ps1 -Source "C:\Data"  # Works from anywhere!
```

### Example 4: System-Wide (Admin)
```powershell
# Run PowerShell as Administrator
.\Install-Scripts.ps1 -Action Install -ScriptPath "Convert-UmlToSvg" -Global
# Available for all users on the system
```

## 🐛 Troubleshooting

### Script Not Found
**Problem:** `Convert-UmlToSvg.ps1: The term is not recognized...`

**Solution:** Refresh PATH or restart PowerShell
```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
```

### Already Installed Warning
**Problem:** "Directory already in PATH"

**Solution:** Use `-Force` or uninstall first
```powershell
.\Install-Scripts.ps1 -Action Uninstall -ScriptPath "Convert-UmlToSvg"
.\Install-Scripts.ps1 -Action Install -ScriptPath "Convert-UmlToSvg"
```

### Permission Denied
**Problem:** Access denied when using `-Global`

**Solution:** Run PowerShell as Administrator

## ✅ Features

- ✅ No admin required (User PATH default)
- ✅ Install directories or single files
- ✅ Automatic absolute path resolution
- ✅ Configuration tracking (JSON)
- ✅ Wrapper script generation
- ✅ Installation verification
- ✅ Color-coded logging (Logger module)
- ✅ User/System PATH support
- ✅ Safe uninstallation

## 📦 Dependencies

- **Logger Module**: `modules\Logger.psm1`
  - Provides: `Write-Log` with INFO, SUCCESS, WARNING, ERROR levels
  - Auto-imported by Install-Scripts.ps1

## 🧪 Testing

```powershell
# Run Pester tests
Invoke-Pester -Path "tests\Install-Scripts.Tests.ps1"
```

## 🔒 Requirements

- PowerShell 5.1+
- Windows 10/11
- Admin rights (only for `-Global`)

## 📚 Full Documentation

See [powershell/README.md](./README.md) for complete documentation.

---

**Version:** 1.0.0  
**Author:** GitHub Copilot  
**License:** MIT
