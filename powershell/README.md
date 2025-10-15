# PowerShell Scripts Collection

A collection of PowerShell automation scripts with a universal installer for system-wide access.

## 📦 Projects

### [Convert-UmlToSvg](./Convert-UmlToSvg/)
PowerShell automation tool for converting PlantUML diagrams to SVG with automatic dependency management.

**Features:**
- Auto-install Java, PlantUML, Graphviz
- Multi-path dependency detection
- Batch conversion support
- Syntax validation and preview modes
- 24 test scenarios, 100% passing

[📖 Full Documentation](./Convert-UmlToSvg/README.md)

---

## 🚀 Quick Start - Install Scripts Globally

Use `Install-Scripts.ps1` to install any PowerShell script for global access from any directory.

### Installation

```powershell
# Navigate to powershell directory
cd scripts-for-work\powershell

# Install a script directory (recommended)
.\Install-Scripts.ps1 -Action Install -ScriptPath "Convert-UmlToSvg"

# Install a single script file
.\Install-Scripts.ps1 -Action Install -ScriptPath "path\to\script.ps1"
```

### Usage After Installation

Once installed, run the script from **any directory**:

```powershell
# Run from anywhere
cd ~
Convert-UmlToSvg.ps1 -Check

# Or with parameters
Convert-UmlToSvg.ps1 -Path "diagrams" -Out "output"
```

### Management Commands

```powershell
# List all installed scripts
.\Install-Scripts.ps1 -Action List

# Verify installations
.\Install-Scripts.ps1 -Action Verify

# Uninstall a script
.\Install-Scripts.ps1 -Action Uninstall -ScriptPath "Convert-UmlToSvg"
```

---

## 📚 Install-Scripts.ps1 Documentation

### Overview

`Install-Scripts.ps1` is a universal installer that adds PowerShell scripts to your system PATH, enabling global access without needing to navigate to script directories.

### How It Works

**For Directories:**
- Adds the entire directory to User or System PATH
- All `.ps1` files in that directory become globally accessible
- No admin rights required for User PATH (default)

**For Single Files:**
- Creates a wrapper script in `~\.powershell-scripts\`
- Adds wrapper directory to PATH
- Wrapper forwards all arguments to original script

### Features

✅ **No Admin Required** - Installs to User PATH by default  
✅ **Multiple Scripts** - Install multiple script directories  
✅ **Wrapper Support** - Install individual `.ps1` files  
✅ **Configuration Tracking** - Stores installation info in JSON  
✅ **Verification** - Verify all installations are working  
✅ **Easy Uninstall** - Remove scripts from PATH cleanly  
✅ **Logging** - Uses centralized Logger module

### Command Reference

#### Install Action

```powershell
# Install current directory
.\Install-Scripts.ps1 -Action Install

# Install specific directory
.\Install-Scripts.ps1 -Action Install -ScriptPath "Convert-UmlToSvg"

# Install single file
.\Install-Scripts.ps1 -Action Install -ScriptPath "script.ps1"

# Install globally (requires admin)
.\Install-Scripts.ps1 -Action Install -ScriptPath "Convert-UmlToSvg" -Global
```

#### List Action

```powershell
# Show all installed scripts
.\Install-Scripts.ps1 -Action List
```

#### Verify Action

```powershell
# Verify all installations
.\Install-Scripts.ps1 -Action Verify
```

#### Uninstall Action

```powershell
# Uninstall by path
.\Install-Scripts.ps1 -Action Uninstall -ScriptPath "Convert-UmlToSvg"
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Action` | String | No | `Install`, `Uninstall`, `Verify`, or `List` (default: Install) |
| `-ScriptPath` | String | No | Path to script directory or file (default: current directory) |
| `-Global` | Switch | No | Install to System PATH (requires admin) |
| `-Force` | Switch | No | Force installation even if already installed |

### Configuration

**Config Directory:** `%USERPROFILE%\.powershell-scripts\`

**Files:**
- `installed-scripts.json` - Tracks all installations
- `*.ps1` - Wrapper scripts for individual file installations

### Refreshing PATH

After installation, refresh your PowerShell session:

```powershell
# Option 1: Restart PowerShell (recommended)

# Option 2: Refresh in current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
```

### Examples

#### Example 1: Install Convert-UmlToSvg

```powershell
# Navigate to scripts directory
cd scripts-for-work\powershell

# Install
.\Install-Scripts.ps1 -Action Install -ScriptPath "Convert-UmlToSvg"

# Restart PowerShell or refresh PATH

# Test from any directory
cd ~
Convert-UmlToSvg.ps1 -Check
```

#### Example 2: Install Multiple Scripts

```powershell
# Install first script
.\Install-Scripts.ps1 -Action Install -ScriptPath "Convert-UmlToSvg"

# Install second script
.\Install-Scripts.ps1 -Action Install -ScriptPath "Some-OtherScriptProject"

# List all
.\Install-Scripts.ps1 -Action List
```

### Troubleshooting

**Script Not Found After Installation**
```powershell
# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")

# Or restart PowerShell
```

**Permission Denied**
```powershell
# Run PowerShell as Administrator for -Global installations
```

**Verify Installation**
```powershell
# Check installation
.\Install-Scripts.ps1 -Action Verify

# Check if script is in PATH
Get-Command Convert-UmlToSvg.ps1
```

---

## 🔧 Structure

```
powershell/
├── Install-Scripts.ps1          # Universal installer
├── README.md                    # This file
├── modules/
│   └── Logger.psm1             # Logging module
├── tests/
│   └── Install-Scripts.Tests.ps1  # Tests
├── Convert-UmlToSvg/           # Script project
│   ├── Convert-UmlToSvg.ps1
│   └── README.md
└── automation/                  # Other scripts
```

## 📝 Requirements

- PowerShell 5.1 or higher
- Windows 10/11
- Admin rights (only for `-Global` installations)

## 🤝 Contributing

1. Create script directory under `powershell/`
2. Add comprehensive README.md
3. Test with Install-Scripts.ps1
4. Submit pull request

---

**Made with ❤️ by anhembedded**
