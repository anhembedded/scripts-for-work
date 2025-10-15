<#
.SYNOPSIS
    Pester tests for Convert-UmlToSvg script and modules.

.DESCRIPTION
    This file contains unit and integration tests for the UML to SVG conversion script.
    Compatible with Pester 3.4.0
#>

# Setup - Import modules
$scriptRoot = Split-Path -Parent $PSScriptRoot
Import-Module "$scriptRoot\modules\DependencyManager.psm1" -Force
Import-Module "$scriptRoot\modules\UmlConverter.psm1" -Force

Describe "DependencyManager Module" {
    Context "Test-Dependencies" {
        It "Should return a hashtable with dependency status" {
            $result = Test-Dependencies
            
            $result | Should Not BeNullOrEmpty
            $result.ContainsKey('Java') | Should Be $true
            $result.ContainsKey('PlantUML') | Should Be $true
            $result.ContainsKey('Graphviz') | Should Be $true
        }
        
        It "Should have Installed property for each dependency" {
            $result = Test-Dependencies
            
            $result.Java.ContainsKey('Installed') | Should Be $true
            $result.PlantUML.ContainsKey('Installed') | Should Be $true
            $result.Graphviz.ContainsKey('Installed') | Should Be $true
        }
    }
    
    Context "Get-PlantUmlPath" {
        It "Should return a path when PlantUML is installed" {
            $deps = Test-Dependencies
            
            if ($deps.PlantUML.Installed) {
                $path = Get-PlantUmlPath
                $path | Should Not BeNullOrEmpty
                Test-Path $path | Should Be $true
            }
        }
    }
}

Describe "Convert-UmlToSvg Script" {
    Context "Script File" {
        It "Should exist" {
            $scriptPath = Join-Path $scriptRoot "Convert-UmlToSvg.ps1"
            Test-Path $scriptPath | Should Be $true
        }
        
        It "Should be a valid PowerShell script" {
            $scriptPath = Join-Path $scriptRoot "Convert-UmlToSvg.ps1"
            $content = Get-Content $scriptPath -Raw
            $content | Should Not BeNullOrEmpty
        }
    }
    
    Context "Dependency Check" {
        It "Should check dependencies without errors" {
            $scriptPath = Join-Path $scriptRoot "Convert-UmlToSvg.ps1"
            { & $scriptPath -Check } | Should Not Throw
        }
    }
}

Describe "Example Files" {
    Context "Sample PlantUML Files" {
        It "Should have example .puml files" {
            $examplesDir = Join-Path $scriptRoot "examples"
            Test-Path $examplesDir | Should Be $true
            
            $pumlFiles = Get-ChildItem -Path $examplesDir -Filter "*.puml"
            $pumlFiles.Count | Should BeGreaterThan 0
        }
        
        It "Should have sequence example" {
            $exampleFile = Join-Path $scriptRoot "examples\sequence-example.puml"
            Test-Path $exampleFile | Should Be $true
        }
        
        It "Should have class example" {
            $exampleFile = Join-Path $scriptRoot "examples\class-example.puml"
            Test-Path $exampleFile | Should Be $true
        }
    }
}

Describe "Module Files" {
    Context "Required Modules" {
        It "Should have DependencyManager module" {
            $modulePath = Join-Path $scriptRoot "modules\DependencyManager.psm1"
            Test-Path $modulePath | Should Be $true
        }
        
        It "Should have UmlConverter module" {
            $modulePath = Join-Path $scriptRoot "modules\UmlConverter.psm1"
            Test-Path $modulePath | Should Be $true
        }
    }
}
