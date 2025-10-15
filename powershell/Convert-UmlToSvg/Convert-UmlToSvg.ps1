<#
.SYNOPSIS
    Converts PlantUML files to SVG format with automatic dependency management.

.DESCRIPTION
    This script converts .puml files to .svg format using PlantUML.
    It automatically checks for required dependencies (Java, PlantUML, Graphviz)
    and can download/install them if missing.

.PARAMETER Path
    Input file or folder path containing .puml files.

.PARAMETER Out
    Output folder path for generated .svg files. Defaults to input folder.

.PARAMETER Check
    Check dependencies only without performing conversion.

.PARAMETER Download
    Download and install missing dependencies automatically.

.PARAMETER RawRun
    Pass raw arguments directly to PlantUML command.

.PARAMETER Force
    Overwrite existing output files without prompting.

.PARAMETER Verbose
    Show detailed logging information.

.PARAMETER Validate
    Validate .puml syntax without generating output.

.PARAMETER Preview
    Open generated SVG files automatically after conversion.

.PARAMETER LogFile
    Path to save detailed logs. Defaults to logs folder.

.EXAMPLE
    .\Convert-UmlToSvg.ps1 -Path "diagram.puml"
    Convert a single PlantUML file to SVG.

.EXAMPLE
    .\Convert-UmlToSvg.ps1 -Path ".\diagrams" -Out ".\output" -Force
    Convert all .puml files in a folder to SVG, overwriting existing files.

.EXAMPLE
    .\Convert-UmlToSvg.ps1 -Check
    Check if all dependencies are installed.

.EXAMPLE
    .\Convert-UmlToSvg.ps1 -Check -Download
    Check dependencies and download/install if missing.

.EXAMPLE
    .\Convert-UmlToSvg.ps1 -Path "diagram.puml" -Validate
    Validate PlantUML syntax without generating output.

.EXAMPLE
    .\Convert-UmlToSvg.ps1 -Path "diagram.puml" -Preview
    Convert and open the generated SVG automatically.

.NOTES
    Author: Automation Scripts
    Date: 2025-10-15
    Requires: PowerShell 5.1 or higher
#>

[CmdletBinding(DefaultParameterSetName = 'Convert')]
param(
    [Parameter(ParameterSetName = 'Convert', Position = 0)]
    [Parameter(ParameterSetName = 'Validate')]
    [Parameter(ParameterSetName = 'RawRun')]
    [string]$Path,

    [Parameter(ParameterSetName = 'Convert')]
    [Parameter(ParameterSetName = 'Validate')]
    [string]$Out,

    [Parameter(ParameterSetName = 'Check', Mandatory = $true)]
    [switch]$Check,

    [Parameter(ParameterSetName = 'Check')]
    [Parameter(ParameterSetName = 'Convert')]
    [switch]$Download,

    [Parameter(ParameterSetName = 'RawRun', Mandatory = $true)]
    [string]$RawRun,

    [Parameter(ParameterSetName = 'Convert')]
    [switch]$Force,

    [Parameter(ParameterSetName = 'Validate', Mandatory = $true)]
    [switch]$Validate,

    [Parameter(ParameterSetName = 'Convert')]
    [switch]$Preview,

    [Parameter()]
    [string]$LogFile
)

# Script root directory
$ScriptRoot = $PSScriptRoot

# Import modules
Import-Module "$ScriptRoot\modules\DependencyManager.psm1" -Force
Import-Module "$ScriptRoot\modules\UmlConverter.psm1" -Force

# Import Logger module from parent directory
$LoggerModulePath = Join-Path (Split-Path (Split-Path $ScriptRoot -Parent) -Parent) "modules\Logger.psm1"
if (Test-Path $LoggerModulePath) {
    Import-Module $LoggerModulePath -Force
} else {
    # Fallback: Create minimal Write-Log function if logger not available
    function Write-Log {
        param([string]$Message, [string]$Level = 'INFO')
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $color = switch ($Level) {
            'ERROR' { 'Red' }
            'WARNING' { 'Yellow' }
            default { 'Green' }
        }
        Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
    }
}

# Setup logging
if (-not $LogFile) {
    $LogDir = Join-Path $ScriptRoot "..\..\logs"
    if (-not (Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }
    $LogFile = Join-Path $LogDir "uml-conversion-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
}

# Start transcript for detailed logging
if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
    Start-Transcript -Path $LogFile -Append | Out-Null
    Write-Log "Verbose logging enabled. Transcript saved to: $LogFile" -Level INFO
}

try {
    Write-Log "=== Convert-UmlToSvg Script Started ===" -Level INFO

    # Parameter Set: Check dependencies
    if ($Check) {
        Write-Log "Checking dependencies..." -Level INFO
        $deps = Test-Dependencies -Verbose:$VerbosePreference
        
        Write-Host "`nDependency Status:" -ForegroundColor Cyan
        Write-Host "  Java:     $(if ($deps.Java.Installed) { '[OK]' } else { '[MISSING]' })" -ForegroundColor $(if ($deps.Java.Installed) { 'Green' } else { 'Red' })
        if ($deps.Java.Installed) {
            Write-Host "            Version: $($deps.Java.Version)" -ForegroundColor Gray
            Write-Host "            Path: $($deps.Java.Path)" -ForegroundColor Gray
        }
        
        Write-Host "  PlantUML: $(if ($deps.PlantUML.Installed) { '[OK]' } else { '[MISSING]' })" -ForegroundColor $(if ($deps.PlantUML.Installed) { 'Green' } else { 'Red' })
        if ($deps.PlantUML.Installed) {
            Write-Host "            Path: $($deps.PlantUML.Path)" -ForegroundColor Gray
        }
        
        Write-Host "  Graphviz: $(if ($deps.Graphviz.Installed) { '[OK]' } else { '[MISSING]' })" -ForegroundColor $(if ($deps.Graphviz.Installed) { 'Green' } else { 'Red' })
        if ($deps.Graphviz.Installed) {
            Write-Host "            Version: $($deps.Graphviz.Version)" -ForegroundColor Gray
            Write-Host "            Path: $($deps.Graphviz.Path)" -ForegroundColor Gray
        }

        if ($Download) {
            $missingDeps = @()
            if (-not $deps.Java.Installed) { $missingDeps += 'Java' }
            if (-not $deps.PlantUML.Installed) { $missingDeps += 'PlantUML' }
            if (-not $deps.Graphviz.Installed) { $missingDeps += 'Graphviz' }

            if ($missingDeps.Count -gt 0) {
                Write-Log "Installing missing dependencies: $($missingDeps -join ', ')" -Level INFO
                Install-Dependencies -Verbose:$VerbosePreference
                Write-Log "Dependencies installed successfully!" -Level INFO
                Write-Host "`nPlease restart your PowerShell session to use the updated PATH." -ForegroundColor Yellow
            } else {
                Write-Log "All dependencies are already installed." -Level INFO
            }
        }

        return
    }

    # Ensure dependencies are installed for conversion operations
    if (-not $Check) {
        Write-Log "Verifying dependencies..." -Level INFO
        $deps = Test-Dependencies
        
        $missingDeps = @()
        if (-not $deps.Java.Installed) { $missingDeps += 'Java' }
        if (-not $deps.PlantUML.Installed) { $missingDeps += 'PlantUML' }
        if (-not $deps.Graphviz.Installed) { $missingDeps += 'Graphviz' }

        if ($missingDeps.Count -gt 0) {
            Write-Log "Missing dependencies: $($missingDeps -join ', ')" -Level ERROR
            Write-Host "`nMissing required dependencies: $($missingDeps -join ', ')" -ForegroundColor Red
            Write-Host "Run the following command to install them:" -ForegroundColor Yellow
            Write-Host "  .\Convert-UmlToSvg.ps1 -Check -Download" -ForegroundColor Cyan
            
            if ($Download) {
                Write-Log "Auto-installing dependencies..." -Level INFO
                Install-Dependencies -Verbose:$VerbosePreference
                Write-Log "Dependencies installed. Please restart PowerShell and run the script again." -Level INFO
                Write-Host "`nDependencies installed. Please restart your PowerShell session and run the script again." -ForegroundColor Yellow
                return
            }
            
            throw "Required dependencies are not installed. Use -Download flag to install automatically."
        }

        Write-Log "All dependencies are installed." -Level INFO
    }

    # Parameter Set: RawRun
    if ($RawRun) {
        Write-Log "Running PlantUML with raw arguments: $RawRun" -Level INFO
        Invoke-PlantUmlRaw -Arguments $RawRun -Verbose:$VerbosePreference
        Write-Log "Raw command completed." -Level INFO
        return
    }

    # Parameter Set: Validate
    if ($Validate) {
        if (-not $Path) {
            throw "Path parameter is required for validation."
        }

        Write-Log "Validating PlantUML file(s): $Path" -Level INFO
        $result = Test-PlantUmlSyntax -Path $Path -Verbose:$VerbosePreference
        
        if ($result.IsValid) {
            Write-Log "Validation successful: All files are valid." -Level INFO
            Write-Host "`nValidation Result: " -NoNewline
            Write-Host "PASSED" -ForegroundColor Green
        } else {
            Write-Log "Validation failed. Errors found." -Level ERROR
            Write-Host "`nValidation Result: " -NoNewline
            Write-Host "FAILED" -ForegroundColor Red
            Write-Host "`nErrors:" -ForegroundColor Red
            foreach ($err in $result.Errors) {
                Write-Host "  - $err" -ForegroundColor Red
            }
            throw "Validation failed."
        }
        return
    }

    # Parameter Set: Convert
    if (-not $Path) {
        throw "Path parameter is required for conversion."
    }

    Write-Log "Starting UML to SVG conversion..." -Level INFO
    Write-Log "Input: $Path" -Level INFO
    if ($Out) {
        Write-Log "Output: $Out" -Level INFO
    }

    $convertParams = @{
        Path = $Path
        Force = $Force
        Verbose = $VerbosePreference
    }

    if ($Out) {
        $convertParams['OutputPath'] = $Out
    }

    $result = Convert-UmlToSvg @convertParams

    Write-Log "Conversion completed: $($result.SuccessCount) succeeded, $($result.FailureCount) failed." -Level INFO
    
    Write-Host "`nConversion Results:" -ForegroundColor Cyan
    Write-Host "  Succeeded: $($result.SuccessCount)" -ForegroundColor Green
    Write-Host "  Failed:    $($result.FailureCount)" -ForegroundColor $(if ($result.FailureCount -gt 0) { 'Red' } else { 'Gray' })
    
    if ($result.OutputFiles.Count -gt 0) {
        Write-Host "`nGenerated Files:" -ForegroundColor Cyan
        foreach ($file in $result.OutputFiles) {
            Write-Host "  - $file" -ForegroundColor Gray
        }
    }

    if ($result.FailureCount -gt 0) {
        Write-Host "`nErrors:" -ForegroundColor Red
        foreach ($err in $result.Errors) {
            Write-Host "  - $err" -ForegroundColor Red
        }
    }

    # Preview generated files
    if ($Preview -and $result.SuccessCount -gt 0) {
        Write-Log "Opening preview for generated SVG files..." -Level INFO
        foreach ($file in $result.OutputFiles) {
            Start-Process $file
        }
    }

    Write-Log "=== Convert-UmlToSvg Script Completed ===" -Level INFO

} catch {
    Write-Log "Script failed: $_" -Level ERROR
    Write-Host "`nError: $_" -ForegroundColor Red
    exit 1
} finally {
    if ($VerbosePreference -eq 'Continue' -or $PSBoundParameters.ContainsKey('Verbose')) {
        Stop-Transcript | Out-Null
    }
}
