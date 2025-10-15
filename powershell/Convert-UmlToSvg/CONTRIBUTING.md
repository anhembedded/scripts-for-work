# Contributing to Convert-UmlToSvg

First off, thank you for considering contributing to Convert-UmlToSvg! It's people like you that make this tool better for everyone.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Testing Guidelines](#testing-guidelines)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

This project adheres to a simple code of conduct: be respectful, be constructive, and be helpful. We want this to be a welcoming space for everyone.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Description**: Clear description of the issue
- **Steps to Reproduce**: Detailed steps to reproduce the behavior
- **Expected Behavior**: What you expected to happen
- **Actual Behavior**: What actually happened
- **Environment**:
  - OS version (e.g., Windows 11)
  - PowerShell version
  - Dependency versions (Java, PlantUML, Graphviz)
- **Logs**: Include relevant log files from `logs/` directory
- **Screenshots**: If applicable

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **Use Case**: Why is this enhancement needed?
- **Proposed Solution**: How should it work?
- **Alternatives**: What other solutions have you considered?
- **Impact**: Who would benefit from this?

### Contributing Code

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (see commit guidelines below)
4. **Test** your changes thoroughly
5. **Push** to your branch (`git push origin feature/amazing-feature`)
6. **Open** a Pull Request

## Development Setup

### Prerequisites

- PowerShell 5.1 or higher
- Git
- Pester 3.4.0+ (for testing)

### Setup Steps

```powershell
# Clone your fork
git clone https://github.com/YOUR-USERNAME/scripts-for-work.git
cd scripts-for-work/powershell/Convert-UmlToSvg

# Install dependencies
.\Convert-UmlToSvg.ps1 -Check -Download

# Run tests
Invoke-Pester -Path .\tests\Convert-UmlToSvg.Tests.ps1
```

### Project Structure

```
Convert-UmlToSvg/
├── Convert-UmlToSvg.ps1      # Main script
├── modules/                   # PowerShell modules
│   ├── DependencyManager.psm1
│   ├── UmlConverter.psm1
│   └── Logger.psm1
├── tests/                     # Test files
├── examples/                  # Example PlantUML files
├── doc/                       # Design documentation
└── output/                    # Example output SVGs
```

## Testing Guidelines

### Running Tests

```powershell
# Run all tests
Invoke-Pester -Path .\tests\

# Run with code coverage
Invoke-Pester -Path .\tests\ -CodeCoverage .\Convert-UmlToSvg.ps1

# Run specific test
Invoke-Pester -Path .\tests\Convert-UmlToSvg.Tests.ps1 -Tag "DependencyManager"
```

### Writing Tests

- Use Pester framework (version 3.4.0+)
- Follow the existing test structure
- Test both success and failure scenarios
- Mock external dependencies when possible
- Aim for high code coverage

Example test structure:

```powershell
Describe "Feature Name" {
    Context "When condition" {
        It "Should do something" {
            # Arrange
            $input = "test"
            
            # Act
            $result = Test-Function -Input $input
            
            # Assert
            $result | Should Be "expected"
        }
    }
}
```

## Coding Standards

### PowerShell Style Guide

- **Naming Conventions**:
  - Functions: `Verb-Noun` (e.g., `Get-PlantUmlPath`)
  - Variables: `$camelCase` or `$PascalCase`
  - Constants: `$UPPERCASE_WITH_UNDERSCORES`

- **Comments**:
  - Use comment-based help for functions
  - Add inline comments for complex logic
  - Keep comments up-to-date

- **Error Handling**:
  - Use `try-catch` blocks
  - Provide meaningful error messages
  - Use `Write-Error` for errors, `Write-Warning` for warnings

- **Parameters**:
  - Use `[CmdletBinding()]`
  - Add parameter validation
  - Include help text

Example function:

```powershell
function Get-Example {
    <#
    .SYNOPSIS
    Brief description.
    
    .DESCRIPTION
    Detailed description.
    
    .PARAMETER Name
    Description of parameter.
    
    .EXAMPLE
    Get-Example -Name "test"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )
    
    try {
        # Implementation
        Write-Verbose "Processing: $Name"
        return $result
    }
    catch {
        Write-Error "Failed: $_"
        throw
    }
}
```

### Documentation

- Update README.md for user-facing changes
- Update doc/DESIGN.md for architectural changes
- Add examples for new features
- Update CHANGELOG.md

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**

```
feat(dependency): Add support for PlantUML server mode

Implement PlantUML server mode for faster conversions.
- Add -ServerUrl parameter
- Update conversion logic to use HTTP API
- Add tests for server mode

Closes #123
```

```
fix(conversion): Fix absolute path resolution on UNC paths

The path conversion was failing for UNC paths. Updated to use
GetUnresolvedProviderPathFromPSPath which handles UNC properly.

Fixes #456
```

## Pull Request Process

1. **Update Documentation**: Ensure README, DESIGN, and other docs are updated

2. **Add Tests**: Include tests for new functionality

3. **Run Tests**: Ensure all tests pass
   ```powershell
   Invoke-Pester -Path .\tests\
   ```

4. **Update CHANGELOG**: Add your changes to CHANGELOG.md under `[Unreleased]`

5. **Clean Commits**: Squash commits if necessary for a clean history

6. **PR Description**: Include:
   - What changes were made
   - Why they were made
   - How to test them
   - Screenshots (if applicable)
   - Related issues

7. **Review Process**:
   - Address review feedback
   - Keep discussions constructive
   - Be patient - reviews take time

### PR Checklist

- [ ] Code follows the project's coding standards
- [ ] All tests pass
- [ ] New tests added for new functionality
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] No merge conflicts
- [ ] Commit messages follow guidelines

## Questions?

If you have questions, feel free to:
- Open an issue with the "question" label
- Check existing documentation
- Review closed issues for similar questions

## Recognition

Contributors will be recognized in:
- README.md (Contributors section)
- Release notes
- CHANGELOG.md

Thank you for contributing to Convert-UmlToSvg! 🎉
