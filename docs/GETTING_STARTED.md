# Getting Started

Welcome to the automation scripts repository! This guide will help you get started with creating and using automation scripts.

## Project Structure

```
scripts-for-work/
├── powershell/          # PowerShell scripts for Windows
│   ├── modules/         # Reusable PowerShell modules
│   ├── utils/           # Utility scripts
│   └── automation/      # Main automation scripts
├── bash/                # Bash scripts for Linux/Unix
│   ├── lib/             # Reusable bash libraries
│   ├── utils/           # Utility scripts
│   └── automation/      # Main automation scripts
├── python/              # Python scripts (cross-platform)
│   ├── modules/         # Python modules
│   ├── utils/           # Utility scripts
│   └── automation/      # Main automation scripts
├── config/              # Configuration files
├── docs/                # Documentation
└── logs/                # Log files (auto-generated)
```

## Quick Start

### PowerShell Scripts
1. Navigate to the powershell directory
2. Run a script:
   ```powershell
   .\automation\example-backup.ps1 -SourcePath "C:\Data" -BackupPath "C:\Backup"
   ```

### Bash Scripts
1. Make the script executable:
   ```bash
   chmod +x bash/automation/example-cleanup.sh
   ```
2. Run the script:
   ```bash
   ./bash/automation/example-cleanup.sh /path/to/directory 30
   ```

### Python Scripts
1. Setup virtual environment:
   ```bash
   cd python
   python -m venv venv
   venv\Scripts\activate  # Windows
   # source venv/bin/activate  # Linux/Mac
   pip install -r requirements.txt
   ```
2. Run a script:
   ```bash
   python automation/example_file_organizer.py /path/to/directory
   ```

## Best Practices

1. **Use logging**: All scripts should use the provided logging modules
2. **Error handling**: Implement proper error handling and validation
3. **Configuration**: Store sensitive data in config files (not in git)
4. **Documentation**: Comment your code and update documentation
5. **Testing**: Test scripts in a safe environment before production use

## Creating New Scripts

1. Choose the appropriate language directory
2. Place scripts in the `automation/` subdirectory
3. Use the provided logger modules
4. Follow the naming convention: `verb-noun.ext` (e.g., `backup-database.ps1`)
5. Add documentation at the top of the script

## Need Help?

- Check the example scripts in each language directory
- Review the logger modules for reusable functions
- Update the main README.md with your custom scripts
