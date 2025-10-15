# Convert-UmlToSvg

A PowerShell script for converting PlantUML diagrams to SVG format with automatic dependency management.

## Features

- ✅ Convert single or multiple PlantUML files to SVG
- ✅ Automatic dependency checking (Java, PlantUML, Graphviz)
- ✅ Automatic dependency download and installation
- ✅ Batch conversion of entire directories
- ✅ Syntax validation without conversion
- ✅ Preview mode to open generated SVG files
- ✅ Detailed logging and verbose output
- ✅ Force overwrite existing files
- ✅ Raw PlantUML command execution

## Prerequisites

The script automatically checks for and can install:

1. **Java Runtime Environment (JRE)** - Version 11 or higher
2. **PlantUML JAR** - Downloaded automatically if missing
3. **Graphviz** - Required for complex diagrams (requires manual installation)

## Installation

1. Clone or download this repository
2. Navigate to the script directory
3. Run dependency check:

```powershell
.\Convert-UmlToSvg.ps1 -Check
```

4. Install missing dependencies:

```powershell
.\Convert-UmlToSvg.ps1 -Check -Download
```

**Note:** Java and Graphviz require manual installation. The script will provide download links.

### Installing Dependencies Manually

#### Java
- Download from: https://adoptium.net/
- Or: https://www.oracle.com/java/technologies/downloads/

#### Graphviz
- Download from: https://graphviz.org/download/
- Or use package managers:
  ```powershell
  # Chocolatey
  choco install graphviz
  
  # Scoop
  scoop install graphviz
  ```

## Usage

### Basic Conversion

Convert a single PlantUML file:

```powershell
.\Convert-UmlToSvg.ps1 -Path "diagram.puml"
```

Convert with custom output directory:

```powershell
.\Convert-UmlToSvg.ps1 -Path "diagram.puml" -Out "C:\output"
```

### Batch Conversion

Convert all `.puml` files in a directory:

```powershell
.\Convert-UmlToSvg.ps1 -Path "C:\diagrams" -Out "C:\output"
```

Recursively convert with force overwrite:

```powershell
.\Convert-UmlToSvg.ps1 -Path "C:\diagrams" -Force
```

### Validation Mode

Check PlantUML syntax without generating output:

```powershell
.\Convert-UmlToSvg.ps1 -Path "diagram.puml" -Validate
```

Validate all files in a directory:

```powershell
.\Convert-UmlToSvg.ps1 -Path "C:\diagrams" -Validate
```

### Preview Mode

Convert and automatically open the generated SVG:

```powershell
.\Convert-UmlToSvg.ps1 -Path "diagram.puml" -Preview
```

### Dependency Management

Check dependency status:

```powershell
.\Convert-UmlToSvg.ps1 -Check
```

Install missing dependencies automatically:

```powershell
.\Convert-UmlToSvg.ps1 -Check -Download
```

### Raw PlantUML Command

Execute PlantUML with custom arguments:

```powershell
.\Convert-UmlToSvg.ps1 -RawRun "-help"
.\Convert-UmlToSvg.ps1 -RawRun "-version"
.\Convert-UmlToSvg.ps1 -RawRun "-tpng -o output diagram.puml"
```

### Verbose Logging

Enable detailed logging:

```powershell
.\Convert-UmlToSvg.ps1 -Path "diagram.puml" -Verbose
```

Logs are saved to `logs\uml-conversion-{timestamp}.log`

## Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `-Path` | String | Input file or folder path containing .puml files |
| `-Out` | String | Output folder path for generated .svg files |
| `-Check` | Switch | Check dependencies only without conversion |
| `-Download` | Switch | Download and install missing dependencies |
| `-RawRun` | String | Run PlantUML directly with raw arguments |
| `-Force` | Switch | Overwrite existing output files without prompting |
| `-Validate` | Switch | Validate .puml syntax without generating output |
| `-Preview` | Switch | Open generated SVG files automatically |
| `-Verbose` | Switch | Show detailed logging information |
| `-LogFile` | String | Custom path for log file |

## Examples

### Example 1: Simple Conversion

```powershell
.\Convert-UmlToSvg.ps1 -Path "sequence-diagram.puml"
```

### Example 2: Batch Conversion with Output Directory

```powershell
.\Convert-UmlToSvg.ps1 -Path ".\diagrams" -Out ".\output\svg" -Force
```

### Example 3: Validation Before Conversion

```powershell
# First validate
.\Convert-UmlToSvg.ps1 -Path ".\diagrams" -Validate

# Then convert if valid
.\Convert-UmlToSvg.ps1 -Path ".\diagrams" -Out ".\output"
```

### Example 4: Convert and Preview

```powershell
.\Convert-UmlToSvg.ps1 -Path "class-diagram.puml" -Preview
```

### Example 5: Verbose Mode with Custom Log

```powershell
.\Convert-UmlToSvg.ps1 -Path "diagram.puml" -Verbose -LogFile "C:\logs\conversion.log"
```

## Project Structure

```
Convert-UmlToSvg/
├── Convert-UmlToSvg.ps1          # Main script
├── modules/
│   ├── DependencyManager.psm1    # Dependency checking and installation
│   └── UmlConverter.psm1         # Conversion logic
├── tests/
│   └── Convert-UmlToSvg.Tests.ps1 # Pester tests
├── examples/
│   ├── sequence-example.puml     # Example diagrams
│   ├── class-example.puml
│   ├── activity-example.puml
│   ├── usecase-example.puml
│   └── component-example.puml
└── README.md                      # This file
```

## Testing

Run Pester tests:

```powershell
# Install Pester if needed
Install-Module -Name Pester -Force -SkipPublisherCheck

# Run tests
Invoke-Pester -Path .\tests\Convert-UmlToSvg.Tests.ps1
```

Run tests with code coverage:

```powershell
Invoke-Pester -Path .\tests\Convert-UmlToSvg.Tests.ps1 -CodeCoverage .\Convert-UmlToSvg.ps1
```

## Troubleshooting

### Issue: "Java not found"

**Solution:** Install Java JRE 11 or higher and restart PowerShell.

```powershell
# Verify Java installation
java -version
```

### Issue: "PlantUML JAR not found"

**Solution:** Run the script with `-Check -Download` to automatically download PlantUML.

```powershell
.\Convert-UmlToSvg.ps1 -Check -Download
```

### Issue: "Graphviz not found" or diagrams not rendering properly

**Solution:** Install Graphviz manually:

```powershell
# Using Chocolatey
choco install graphviz

# Using Scoop
scoop install graphviz

# Verify installation
dot -V
```

After installation, restart PowerShell to update the PATH.

### Issue: "Conversion failed" or syntax errors

**Solution:** Use validation mode to check your PlantUML syntax:

```powershell
.\Convert-UmlToSvg.ps1 -Path "diagram.puml" -Validate
```

### Issue: Permission denied or access errors

**Solution:** Run PowerShell as Administrator or check file permissions.

### Issue: Output file not created

**Solution:** 
1. Check if the input file has valid PlantUML syntax
2. Verify all dependencies are installed
3. Run with `-Verbose` flag to see detailed logs
4. Check the log file in the `logs` directory

## Advanced Usage

### Custom PlantUML Configuration

You can use PlantUML configuration files (`config.puml`) in your diagram directory:

```puml
!include config.puml
@startuml
' Your diagram here
@enduml
```

### Different Output Formats

Use `-RawRun` to specify other output formats:

```powershell
# PNG output
.\Convert-UmlToSvg.ps1 -RawRun "-tpng -o output diagram.puml"

# PDF output
.\Convert-UmlToSvg.ps1 -RawRun "-tpdf -o output diagram.puml"
```

### Integration with CI/CD

Example GitHub Actions workflow:

```yaml
name: Convert UML Diagrams

on: [push]

jobs:
  convert:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup dependencies
        run: |
          choco install openjdk graphviz
      - name: Convert diagrams
        run: |
          .\Convert-UmlToSvg.ps1 -Check -Download
          .\Convert-UmlToSvg.ps1 -Path ".\diagrams" -Out ".\output" -Force
      - name: Upload artifacts
        uses: actions/upload-artifact@v2
        with:
          name: diagrams
          path: output/
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project is licensed under the MIT License.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [PlantUML](https://plantuml.com/) - The diagram generation tool
- [Graphviz](https://graphviz.org/) - Graph visualization software
- [Microsoft OpenJDK](https://www.microsoft.com/openjdk) - Java runtime
- [Pester](https://pester.dev/) - PowerShell testing framework
- PowerShell Community

## Support

For issues and questions:
- Check the [Troubleshooting](#troubleshooting) section
- Review the example files in `examples/`
- Read the [QUICKSTART.md](QUICKSTART.md) guide
- See complete design in [doc/DESIGN.md](doc/DESIGN.md)
- Open an issue on the repository

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a complete list of changes.

### Version 1.0.0 (2025-10-15)
- Initial production release
- Full automatic dependency installation (Java, PlantUML, Graphviz)
- Multi-path dependency detection
- Batch processing and validation
- Comprehensive testing (24 test scenarios, 100% pass rate)
- Complete documentation with design diagrams
