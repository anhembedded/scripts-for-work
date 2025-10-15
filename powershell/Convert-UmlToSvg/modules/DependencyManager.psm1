<#
.SYNOPSIS
    Module for managing PlantUML conversion dependencies.

.DESCRIPTION
    This module provides functions to check, download, and install
    required dependencies for PlantUML conversion: Java, PlantUML JAR, and Graphviz.
#>

# Dependencies configuration
$script:DependenciesConfig = @{
    Java = @{
        Name = "Java Runtime Environment (JRE)"
        MinVersion = "11.0"
        DownloadUrl = "https://download.oracle.com/java/21/latest/jdk-21_windows-x64_bin.exe"
        DownloadUrlAlt = "https://aka.ms/download-jdk/microsoft-jdk-17.0.9-windows-x64.msi"
        TestCommand = "java"
        TestArgs = "-version"
        VersionRegex = 'version "(\d+\.\d+)'
    }
    PlantUML = @{
        Name = "PlantUML JAR"
        DownloadUrl = "https://github.com/plantuml/plantuml/releases/download/v1.2023.13/plantuml-1.2023.13.jar"
        LatestUrl = "https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar"
        LocalPath = "$env:USERPROFILE\.plantuml"
        FileName = "plantuml.jar"
    }
    Graphviz = @{
        Name = "Graphviz"
        DownloadUrl = "https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/9.0.0/windows_10_cmake_Release_Graphviz-9.0.0-win64.zip"
        DownloadUrlAlt = "https://www2.graphviz.org/Packages/stable/windows/10/cmake/Release/x64/graphviz-install-9.0.0-win64.exe"
        TestCommand = "dot"
        TestArgs = "-V"
        VersionRegex = 'version (\d+\.\d+\.\d+)'
        LocalPath = "$env:USERPROFILE\.graphviz"
    }
}

function Test-Dependencies {
    <#
    .SYNOPSIS
    Check if all required dependencies are installed.
    
    .DESCRIPTION
    Checks for Java, PlantUML JAR, and Graphviz installation.
    
    .OUTPUTS
    Hashtable with dependency status
    #>
    [CmdletBinding()]
    param()

    Write-Verbose "Checking dependencies..."

    $result = @{
        Java = @{
            Installed = $false
            Version = $null
            Path = $null
        }
        PlantUML = @{
            Installed = $false
            Path = $null
        }
        Graphviz = @{
            Installed = $false
            Version = $null
            Path = $null
        }
    }

    # Check Java - try local installation first, then PATH
    $localJava = "$env:USERPROFILE\.java\jdk\bin\java.exe"
    $javaCmd = $null
    
    if (Test-Path $localJava) {
        $javaCmd = $localJava
        Write-Verbose "Found local Java installation: $localJava"
    } else {
        try {
            $javaCmd = (Get-Command java -ErrorAction SilentlyContinue).Source
            Write-Verbose "Found Java in PATH: $javaCmd"
        } catch {
            Write-Verbose "Java not found"
        }
    }
    
    if ($javaCmd) {
        try {
            $javaVersion = & $javaCmd -version 2>&1
            if ($LASTEXITCODE -eq 0) {
                $versionString = $javaVersion | Select-Object -First 1
                if ($versionString -match 'version "(\d+\.\d+)') {
                    $result.Java.Installed = $true
                    $result.Java.Version = $matches[1]
                    $result.Java.Path = $javaCmd
                    Write-Verbose "Java found: Version $($result.Java.Version)"
                }
            }
        } catch {
            Write-Verbose "Error checking Java version"
        }
    }

    # Check PlantUML JAR
    $plantUmlPath = Join-Path $script:DependenciesConfig.PlantUML.LocalPath $script:DependenciesConfig.PlantUML.FileName
    if (Test-Path $plantUmlPath) {
        $result.PlantUML.Installed = $true
        $result.PlantUML.Path = $plantUmlPath
        Write-Verbose "PlantUML found at: $plantUmlPath"
    } else {
        Write-Verbose "PlantUML JAR not found at: $plantUmlPath"
    }

    # Check Graphviz - try common installation paths first, then PATH
    $graphvizPaths = @(
        "C:\Program Files\Graphviz\bin\dot.exe",
        "C:\Program Files (x86)\Graphviz\bin\dot.exe",
        "$env:USERPROFILE\.graphviz\bin\dot.exe"
    )
    
    $dotCmd = $null
    foreach ($path in $graphvizPaths) {
        if (Test-Path $path) {
            $dotCmd = $path
            Write-Verbose "Found Graphviz at: $path"
            break
        }
    }
    
    if (-not $dotCmd) {
        try {
            $dotCmd = (Get-Command dot -ErrorAction SilentlyContinue).Source
            Write-Verbose "Found Graphviz in PATH: $dotCmd"
        } catch {
            Write-Verbose "Graphviz not found"
        }
    }
    
    if ($dotCmd) {
        try {
            $graphvizVersion = & $dotCmd -V 2>&1
            if ($LASTEXITCODE -eq 0) {
                $versionString = $graphvizVersion | Out-String
                if ($versionString -match 'version (\d+\.\d+\.\d+)') {
                    $result.Graphviz.Installed = $true
                    $result.Graphviz.Version = $matches[1]
                    $result.Graphviz.Path = $dotCmd
                    Write-Verbose "Graphviz found: Version $($result.Graphviz.Version)"
                }
            }
        } catch {
            Write-Verbose "Error checking Graphviz version"
        }
    }

    return $result
}

function Install-Dependencies {
    <#
    .SYNOPSIS
    Download and install missing dependencies.
    
    .DESCRIPTION
    Automatically downloads and installs Java, PlantUML, and Graphviz if missing.
    #>
    [CmdletBinding()]
    param()

    Write-Verbose "Starting dependency installation..."

    $deps = Test-Dependencies

    # Install PlantUML (simplest - just download JAR)
    if (-not $deps.PlantUML.Installed) {
        Write-Host "Installing PlantUML..." -ForegroundColor Yellow
        Install-PlantUML
    }

    # Install Java if missing
    if (-not $deps.Java.Installed) {
        Write-Host "Installing Java..." -ForegroundColor Yellow
        Install-Java
    }

    # Install Graphviz if missing
    if (-not $deps.Graphviz.Installed) {
        Write-Host "Installing Graphviz..." -ForegroundColor Yellow
        Install-Graphviz
    }

    Write-Verbose "Dependency installation completed."
}

function Install-PlantUML {
    <#
    .SYNOPSIS
    Download PlantUML JAR file.
    #>
    [CmdletBinding()]
    param()

    $localPath = $script:DependenciesConfig.PlantUML.LocalPath
    $jarPath = Join-Path $localPath $script:DependenciesConfig.PlantUML.FileName
    $downloadUrl = $script:DependenciesConfig.PlantUML.LatestUrl

    Write-Verbose "Creating PlantUML directory: $localPath"
    if (-not (Test-Path $localPath)) {
        New-Item -ItemType Directory -Path $localPath -Force | Out-Null
    }

    Write-Verbose "Downloading PlantUML from: $downloadUrl"
    try {
        # Use .NET WebClient for better compatibility
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($downloadUrl, $jarPath)
        Write-Host "PlantUML downloaded successfully to: $jarPath" -ForegroundColor Green
    } catch {
        Write-Error "Failed to download PlantUML: $_"
        throw
    }
}

function Install-Java {
    <#
    .SYNOPSIS
    Download and install Java portable version.
    #>
    [CmdletBinding()]
    param()

    $localPath = "$env:USERPROFILE\.java"
    $javaZip = Join-Path $localPath "openjdk.zip"
    $javaDir = Join-Path $localPath "jdk"
    
    # Microsoft OpenJDK 17 portable
    $downloadUrl = "https://aka.ms/download-jdk/microsoft-jdk-17.0.9-windows-x64.zip"

    Write-Verbose "Creating Java directory: $localPath"
    if (-not (Test-Path $localPath)) {
        New-Item -ItemType Directory -Path $localPath -Force | Out-Null
    }

    Write-Host "Downloading Java JDK (this may take a few minutes)..." -ForegroundColor Yellow
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($downloadUrl, $javaZip)
        Write-Host "Download completed." -ForegroundColor Green
    } catch {
        Write-Error "Failed to download Java: $_"
        Write-Host "Please install Java manually from: https://adoptium.net/" -ForegroundColor Cyan
        return
    }

    Write-Host "Extracting Java..." -ForegroundColor Yellow
    try {
        if (Test-Path $javaDir) {
            Remove-Item -Path $javaDir -Recurse -Force
        }
        Expand-Archive -Path $javaZip -DestinationPath $localPath -Force
        
        # Find the actual JDK folder (it might be nested)
        $jdkFolder = Get-ChildItem -Path $localPath -Directory | Where-Object { $_.Name -like "*jdk*" } | Select-Object -First 1
        if ($jdkFolder) {
            if ($jdkFolder.FullName -ne $javaDir) {
                Rename-Item -Path $jdkFolder.FullName -NewName "jdk" -Force
            }
        }
        
        Write-Host "Java extracted to: $javaDir" -ForegroundColor Green
        
        # Clean up zip
        Remove-Item -Path $javaZip -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Error "Failed to extract Java: $_"
        return
    }

    # Add to PATH for current session
    $javaBin = Join-Path $javaDir "bin"
    if (Test-Path $javaBin) {
        $env:PATH = "$javaBin;$env:PATH"
        Write-Host "Java added to PATH for current session." -ForegroundColor Green
        Write-Host "To make permanent, add this to your PATH: $javaBin" -ForegroundColor Yellow
    }
    
    Write-Host "Java installation completed!" -ForegroundColor Green
    Write-Host "Note: You may need to restart PowerShell for changes to take effect." -ForegroundColor Yellow
}

function Install-Graphviz {
    <#
    .SYNOPSIS
    Download and install Graphviz portable version.
    #>
    [CmdletBinding()]
    param()

    # Try winget first (modern Windows package manager)
    Write-Host "Attempting to install Graphviz using winget..." -ForegroundColor Yellow
    try {
        $wingetCheck = Get-Command winget -ErrorAction SilentlyContinue
        if ($wingetCheck) {
            Write-Host "Installing Graphviz via winget..." -ForegroundColor Yellow
            $process = Start-Process -FilePath "winget" -ArgumentList "install", "--id", "Graphviz.Graphviz", "--silent", "--accept-source-agreements", "--accept-package-agreements" -Wait -PassThru -NoNewWindow
            
            if ($process.ExitCode -eq 0) {
                Write-Host "Graphviz installed successfully via winget!" -ForegroundColor Green
                Write-Host "Please restart PowerShell to update PATH." -ForegroundColor Yellow
                return
            }
        }
    } catch {
        Write-Verbose "Winget installation failed or not available"
    }

    # Try downloading portable version
    $localPath = "$env:USERPROFILE\.graphviz"
    $graphvizZip = Join-Path $localPath "graphviz.zip"
    
    # Try alternate download URLs
    $downloadUrls = @(
        "https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/10.0.1/windows_10_cmake_Release_Graphviz-10.0.1-win64.zip",
        "https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/9.0.0/windows_10_cmake_Release_Graphviz-9.0.0-win64.zip"
    )

    Write-Verbose "Creating Graphviz directory: $localPath"
    if (-not (Test-Path $localPath)) {
        New-Item -ItemType Directory -Path $localPath -Force | Out-Null
    }

    $downloaded = $false
    foreach ($url in $downloadUrls) {
        Write-Host "Trying download from: $url" -ForegroundColor Yellow
        try {
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($url, $graphvizZip)
            Write-Host "Download completed." -ForegroundColor Green
            $downloaded = $true
            break
        } catch {
            Write-Verbose "Failed to download from: $url"
        }
    }
    
    if (-not $downloaded) {
        Write-Warning "Failed to download Graphviz automatically."
        Write-Host "`nPlease install Graphviz manually:" -ForegroundColor Cyan
        Write-Host "  Option 1: winget install Graphviz.Graphviz" -ForegroundColor Cyan
        Write-Host "  Option 2: choco install graphviz" -ForegroundColor Cyan
        Write-Host "  Option 3: scoop install graphviz" -ForegroundColor Cyan
        Write-Host "  Option 4: https://graphviz.org/download/" -ForegroundColor Cyan
        return
    }

    Write-Host "Extracting Graphviz..." -ForegroundColor Yellow
    try {
        Expand-Archive -Path $graphvizZip -DestinationPath $localPath -Force
        Write-Host "Graphviz extracted to: $localPath" -ForegroundColor Green
        
        # Clean up zip
        Remove-Item -Path $graphvizZip -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Error "Failed to extract Graphviz: $_"
        return
    }

    # Find bin directory and add to PATH
    $binDirs = Get-ChildItem -Path $localPath -Directory -Recurse | Where-Object { $_.Name -eq "bin" } | Select-Object -First 1
    if ($binDirs) {
        $env:PATH = "$($binDirs.FullName);$env:PATH"
        Write-Host "Graphviz added to PATH for current session." -ForegroundColor Green
        Write-Host "To make permanent, add this to your PATH: $($binDirs.FullName)" -ForegroundColor Yellow
    }
    
    Write-Host "Graphviz installation completed!" -ForegroundColor Green
    Write-Host "Note: You may need to restart PowerShell for changes to take effect." -ForegroundColor Yellow
}

function Get-PlantUmlPath {
    <#
    .SYNOPSIS
    Get the path to PlantUML JAR file.
    
    .OUTPUTS
    String path to PlantUML JAR
    #>
    [CmdletBinding()]
    param()

    $plantUmlPath = Join-Path $script:DependenciesConfig.PlantUML.LocalPath $script:DependenciesConfig.PlantUML.FileName
    
    if (-not (Test-Path $plantUmlPath)) {
        throw "PlantUML JAR not found at: $plantUmlPath. Run with -Check -Download to install."
    }

    return $plantUmlPath
}

# Export functions
Export-ModuleMember -Function Test-Dependencies, Install-Dependencies, Get-PlantUmlPath
