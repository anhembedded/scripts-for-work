<#
.SYNOPSIS
    Module for UML to SVG conversion operations.

.DESCRIPTION
    This module provides functions for converting PlantUML files to SVG,
    including batch processing, validation, and preview functionality.
#>

function Convert-UmlToSvg {
    <#
    .SYNOPSIS
    Convert PlantUML file(s) to SVG format.
    
    .PARAMETER Path
    Input file or folder path containing .puml files.
    
    .PARAMETER OutputPath
    Output folder path for generated .svg files.
    
    .PARAMETER Force
    Overwrite existing output files without prompting.
    
    .OUTPUTS
    Hashtable with conversion results
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter()]
        [string]$OutputPath,

        [Parameter()]
        [switch]$Force
    )

    Write-Verbose "Starting UML to SVG conversion..."
    Write-Verbose "Input path: $Path"

    # Validate input path
    if (-not (Test-Path $Path)) {
        throw "Input path does not exist: $Path"
    }

    # Get PlantUML JAR path
    $plantUmlJar = Get-PlantUmlPath

    # Determine if input is file or directory
    $inputItem = Get-Item $Path
    $pumlFiles = @()

    if ($inputItem.PSIsContainer) {
        # Directory - get all .puml files
        Write-Verbose "Input is directory, searching for .puml files..."
        $pumlFiles = Get-ChildItem -Path $Path -Filter "*.puml" -Recurse -File
        Write-Verbose "Found $($pumlFiles.Count) .puml file(s)"
    } else {
        # Single file
        if ($inputItem.Extension -ne ".puml") {
            throw "Input file must have .puml extension: $Path"
        }
        $pumlFiles = @($inputItem)
        Write-Verbose "Input is single file"
    }

    if ($pumlFiles.Count -eq 0) {
        Write-Warning "No .puml files found in: $Path"
        return @{
            SuccessCount = 0
            FailureCount = 0
            OutputFiles = @()
            Errors = @()
        }
    }

    # Determine output directory
    if ($OutputPath) {
        # Convert to absolute path
        $outputDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
        if (-not (Test-Path $outputDir)) {
            Write-Verbose "Creating output directory: $outputDir"
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        }
    }

    # Convert each file
    $results = @{
        SuccessCount = 0
        FailureCount = 0
        OutputFiles = @()
        Errors = @()
    }

    foreach ($file in $pumlFiles) {
        Write-Verbose "Processing: $($file.Name)"
        
        # Determine output file path
        if ($OutputPath) {
            $outputFile = Join-Path $outputDir ($file.BaseName + ".svg")
        } else {
            $outputFile = Join-Path $file.DirectoryName ($file.BaseName + ".svg")
        }

        # Check if output exists
        if ((Test-Path $outputFile) -and -not $Force) {
            Write-Warning "Output file already exists (use -Force to overwrite): $outputFile"
            $results.FailureCount++
            $results.Errors += "File exists: $outputFile"
            continue
        }

        # Run PlantUML conversion
        try {
            $outputDirForPlantUml = if ($OutputPath) { $outputDir } else { $file.DirectoryName }
            
            # Find Java executable (local or PATH)
            $javaExe = "$env:USERPROFILE\.java\jdk\bin\java.exe"
            if (-not (Test-Path $javaExe)) {
                $javaExe = "java"
            }
            
            $arguments = @(
                "-jar", $plantUmlJar,
                "-tsvg",
                "-o", $outputDirForPlantUml,
                $file.FullName
            )

            Write-Verbose "Running: $javaExe $($arguments -join ' ')"
            
            $process = Start-Process -FilePath $javaExe -ArgumentList $arguments -NoNewWindow -Wait -PassThru -RedirectStandardOutput "$env:TEMP\plantuml_out.txt" -RedirectStandardError "$env:TEMP\plantuml_err.txt"
            
            if ($process.ExitCode -eq 0) {
                if (Test-Path $outputFile) {
                    Write-Verbose "Successfully converted: $($file.Name) -> $outputFile"
                    $results.SuccessCount++
                    $results.OutputFiles += $outputFile
                } else {
                    throw "Output file was not created: $outputFile"
                }
            } else {
                $errorOutput = Get-Content "$env:TEMP\plantuml_err.txt" -Raw -ErrorAction SilentlyContinue
                throw "PlantUML conversion failed with exit code $($process.ExitCode). Error: $errorOutput"
            }
        } catch {
            Write-Warning "Failed to convert $($file.Name): $_"
            $results.FailureCount++
            $results.Errors += "$($file.Name): $_"
        }
    }

    Write-Verbose "Conversion completed: $($results.SuccessCount) succeeded, $($results.FailureCount) failed"
    return $results
}

function Test-PlantUmlSyntax {
    <#
    .SYNOPSIS
    Validate PlantUML file syntax without generating output.
    
    .PARAMETER Path
    Input file or folder path containing .puml files.
    
    .OUTPUTS
    Hashtable with validation results
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    Write-Verbose "Validating PlantUML syntax for: $Path"

    # Validate input path
    if (-not (Test-Path $Path)) {
        throw "Input path does not exist: $Path"
    }

    # Get PlantUML JAR path
    $plantUmlJar = Get-PlantUmlPath

    # Determine if input is file or directory
    $inputItem = Get-Item $Path
    $pumlFiles = @()

    if ($inputItem.PSIsContainer) {
        $pumlFiles = Get-ChildItem -Path $Path -Filter "*.puml" -Recurse -File
        Write-Verbose "Found $($pumlFiles.Count) .puml file(s)"
    } else {
        if ($inputItem.Extension -ne ".puml") {
            throw "Input file must have .puml extension: $Path"
        }
        $pumlFiles = @($inputItem)
    }

    if ($pumlFiles.Count -eq 0) {
        Write-Warning "No .puml files found in: $Path"
        return @{
            IsValid = $true
            FileCount = 0
            Errors = @()
        }
    }

    # Validate each file
    $errors = @()

    foreach ($file in $pumlFiles) {
        Write-Verbose "Validating: $($file.Name)"
        
        try {
            # Find Java executable (local or PATH)
            $javaExe = "$env:USERPROFILE\.java\jdk\bin\java.exe"
            if (-not (Test-Path $javaExe)) {
                $javaExe = "java"
            }
            
            # Use PlantUML's syntax check mode
            $arguments = @(
                "-jar", $plantUmlJar,
                "-syntax",
                $file.FullName
            )

            Write-Verbose "Running: $javaExe $($arguments -join ' ')"
            
            $output = & $javaExe $arguments 2>&1 | Out-String
            
            if ($LASTEXITCODE -ne 0 -or $output -match "ERROR") {
                $errors += "$($file.Name): Syntax error detected"
                Write-Verbose "Syntax error in $($file.Name)"
            } else {
                Write-Verbose "Syntax valid for $($file.Name)"
            }
        } catch {
            $errors += "$($file.Name): $_"
            Write-Warning "Failed to validate $($file.Name): $_"
        }
    }

    return @{
        IsValid = ($errors.Count -eq 0)
        FileCount = $pumlFiles.Count
        Errors = $errors
    }
}

function Invoke-PlantUmlRaw {
    <#
    .SYNOPSIS
    Run PlantUML with raw command-line arguments.
    
    .PARAMETER Arguments
    Raw arguments to pass to PlantUML (without java -jar plantuml.jar).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Arguments
    )

    Write-Verbose "Running PlantUML with raw arguments: $Arguments"

    # Get PlantUML JAR path
    $plantUmlJar = Get-PlantUmlPath
    
    # Find Java executable (local or PATH)
    $javaExe = "$env:USERPROFILE\.java\jdk\bin\java.exe"
    if (-not (Test-Path $javaExe)) {
        $javaExe = "java"
    }

    # Split arguments (simple split by space - may need enhancement for quoted args)
    $argArray = $Arguments -split '\s+'

    # Prepare full command
    $fullArgs = @("-jar", $plantUmlJar) + $argArray

    Write-Verbose "Executing: $javaExe $($fullArgs -join ' ')"

    try {
        # Run with output to console
        & $javaExe $fullArgs
        
        if ($LASTEXITCODE -ne 0) {
            throw "PlantUML command failed with exit code: $LASTEXITCODE"
        }
    } catch {
        Write-Error "Failed to run PlantUML: $_"
        throw
    }
}

# Export functions
Export-ModuleMember -Function Convert-UmlToSvg, Test-PlantUmlSyntax, Invoke-PlantUmlRaw
