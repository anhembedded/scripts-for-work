# Automation Scripts for Work

A collection of automation scripts in PowerShell, Bash, and Python to streamline repetitive work tasks.

## 📁 Project Structure

```
scripts-for-work/
├── powershell/          # Windows PowerShell automation scripts
│   ├── modules/         # Reusable modules (Logger, etc.)
│   ├── utils/           # Utility functions
│   └── automation/      # Main automation scripts
├── bash/                # Linux/Unix Bash automation scripts
│   ├── lib/             # Reusable bash libraries
│   ├── utils/           # Utility scripts
│   └── automation/      # Main automation scripts
├── python/              # Cross-platform Python scripts
│   ├── modules/         # Python modules (logger, etc.)
│   ├── utils/           # Utility functions
│   └── automation/      # Main automation scripts
├── config/              # Configuration files
├── docs/                # Documentation
└── logs/                # Generated log files
```

## 🚀 Getting Started

See [docs/GETTING_STARTED.md](docs/GETTING_STARTED.md) for detailed setup instructions.

### Quick Setup

**PowerShell (Windows):**
```powershell
cd powershell
.\automation\example-backup.ps1
```

**Bash (Linux/Mac):**
```bash
chmod +x bash/automation/example-cleanup.sh
./bash/automation/example-cleanup.sh
```

**Python (Cross-platform):**
```bash
cd python
python -m venv venv
venv\Scripts\activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python automation/example_file_organizer.py
```

## 📝 Example Scripts

- **PowerShell**: `example-backup.ps1` - Automated backup with compression
- **Bash**: `example-cleanup.sh` - Clean up old files
- **Python**: `example_file_organizer.py` - Organize files by extension

## 🛠️ Features

- **Multi-language support**: PowerShell, Bash, and Python
- **Logging**: Built-in logging modules for all languages
- **Configuration management**: Centralized config files
- **Error handling**: Robust error handling and validation
- **Cross-platform**: Python scripts work on Windows, Linux, and Mac

## 📚 Documentation

- Configuration examples in `config/`
- Language-specific READMEs in each directory
- Getting started guide in `docs/GETTING_STARTED.md`

## 🔒 Security

- Never commit sensitive data (credentials, API keys, etc.)
- Use environment variables or config files for sensitive information
- Keep `config/secrets.json` and `config/credentials.json` in `.gitignore`

## 📄 License

This is a personal work automation project.

## 🤝 Contributing

This is a personal repository, but feel free to use these scripts as templates for your own automation needs!
scripts-for-work
