# Quick Start Guide - Convert-UmlToSvg

## Installation & Setup (5 minutes)

### Step 1: Clone/Download the Script
Navigate to the script directory:
```powershell
cd "C:\Users\hoang\Desktop\scripts-for-work\powershell\Convert-UmlToSvg"
```

### Step 2: Check Dependencies
```powershell
.\Convert-UmlToSvg.ps1 -Check
```

### Step 3: Install Dependencies

#### Automatic (PlantUML only)
```powershell
.\Convert-UmlToSvg.ps1 -Check -Download
```

#### Manual Installation Required

**Java (Required):**
1. Download Java from: https://adoptium.net/
2. Install and restart PowerShell
3. Verify: `java -version`

**Graphviz (Required for complex diagrams):**
```powershell
# Option 1: Chocolatey
choco install graphviz

# Option 2: Scoop
scoop install graphviz

# Option 3: Manual download
# Visit: https://graphviz.org/download/
```

After installation, restart PowerShell.

### Step 4: Verify Installation
```powershell
.\Convert-UmlToSvg.ps1 -Check
```

You should see all dependencies marked as `[OK]`.

---

## Basic Usage

### Convert a Single File
```powershell
.\Convert-UmlToSvg.ps1 -Path "examples\sequence-example.puml"
```

The SVG file will be created in the same directory as the input file.

### Convert with Custom Output
```powershell
.\Convert-UmlToSvg.ps1 -Path "examples\class-example.puml" -Out "C:\output"
```

### Convert All Files in a Directory
```powershell
.\Convert-UmlToSvg.ps1 -Path "examples" -Out "output" -Force
```

### Convert and Preview
```powershell
.\Convert-UmlToSvg.ps1 -Path "examples\sequence-example.puml" -Preview
```

The SVG will open automatically in your default browser.

---

## Common Workflows

### Workflow 1: Validate Before Converting
```powershell
# Step 1: Validate syntax
.\Convert-UmlToSvg.ps1 -Path "examples" -Validate

# Step 2: Convert if valid
.\Convert-UmlToSvg.ps1 -Path "examples" -Out "output"
```

### Workflow 2: Batch Conversion with Force Overwrite
```powershell
.\Convert-UmlToSvg.ps1 -Path ".\diagrams" -Out ".\svg-output" -Force -Verbose
```

### Workflow 3: Quick Test & View
```powershell
# Create a test diagram
$diagram = @"
@startuml
Alice -> Bob: Hello
Bob --> Alice: Hi!
@enduml
"@
Set-Content -Path "test.puml" -Value $diagram

# Convert and preview
.\Convert-UmlToSvg.ps1 -Path "test.puml" -Preview
```

---

## Troubleshooting Quick Fixes

### Problem: "Java not found"
```powershell
# Check Java installation
java -version

# If not installed, download from: https://adoptium.net/
# Then restart PowerShell
```

### Problem: "PlantUML JAR not found"
```powershell
# Auto-download PlantUML
.\Convert-UmlToSvg.ps1 -Check -Download
```

### Problem: "Graphviz not found" or blank diagrams
```powershell
# Install Graphviz
choco install graphviz

# Verify installation
dot -V

# Restart PowerShell
```

### Problem: Conversion fails
```powershell
# Validate syntax first
.\Convert-UmlToSvg.ps1 -Path "your-file.puml" -Validate

# Use verbose mode to see detailed errors
.\Convert-UmlToSvg.ps1 -Path "your-file.puml" -Verbose
```

---

## Examples to Try

All example files are in the `examples\` directory:

1. **Sequence Diagram**: `sequence-example.puml`
2. **Class Diagram**: `class-example.puml`
3. **Activity Diagram**: `activity-example.puml`
4. **Use Case Diagram**: `usecase-example.puml`
5. **Component Diagram**: `component-example.puml`

Try converting them:
```powershell
.\Convert-UmlToSvg.ps1 -Path "examples" -Out "output" -Force
```

---

## Getting Help

### View Script Help
```powershell
Get-Help .\Convert-UmlToSvg.ps1 -Full
```

### Test Results
```powershell
Invoke-Pester -Path ".\tests\Convert-UmlToSvg.Tests.ps1"
```

### Verbose Logging
```powershell
.\Convert-UmlToSvg.ps1 -Path "file.puml" -Verbose
```

Log files are saved to: `..\..\logs\`

---

## Next Steps

1. ✅ Install all dependencies
2. ✅ Try converting example files
3. ✅ Create your own PlantUML diagrams
4. ✅ Integrate with your workflow

For complete documentation, see [README.md](README.md)
