# Changelog

All notable changes to the Convert-UmlToSvg project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-15

### Added
- Initial release of Convert-UmlToSvg PowerShell script
- Automatic PlantUML to SVG conversion with dependency management
- Auto-installation for all dependencies:
  - Java (Microsoft OpenJDK 17 portable)
  - PlantUML (JAR download from GitHub)
  - Graphviz (winget integration)
- Multi-path dependency detection (local installations + system PATH)
- Command-line parameters:
  - `-Path`: Input file or folder
  - `-Out`: Output directory
  - `-Check`: Check dependencies
  - `-Download`: Auto-install dependencies
  - `-Force`: Overwrite existing files
  - `-Validate`: Syntax validation
  - `-Preview`: Open SVG after conversion
  - `-RawRun`: Execute raw PlantUML commands
  - `-Verbose`: Detailed logging
- Batch conversion support (recursive directory processing)
- PlantUML syntax validation without conversion
- Preview mode (auto-open SVG in browser)
- Comprehensive error handling with helpful messages
- Modular architecture:
  - `DependencyManager.psm1`: Dependency management
  - `UmlConverter.psm1`: Conversion operations
  - `Logger.psm1`: Logging utilities
- 11 Pester unit tests (100% passing)
- 5 example PlantUML diagrams (sequence, class, activity, usecase, component)
- Complete documentation:
  - README.md: User guide
  - QUICKSTART.md: Quick start guide
  - PROJECT_SUMMARY.md: Project overview
  - TEST_RESULTS.md: Test documentation
  - doc/DESIGN.md: System design documentation
  - 7 design diagrams (PlantUML + SVG)

### Features
- Portable Java installation (no admin rights required)
- Session PATH updates for immediate availability
- Absolute path conversion for reliable PlantUML execution
- Graceful fallback for failed installations
- Clear, actionable error messages
- Cross-platform path handling

### Tested
- ✅ Unit tests: 11/11 passing (870ms execution)
- ✅ Integration Test Case 1: Uninstall/error handling
- ✅ Integration Test Case 2: Auto-install/conversion
- ✅ Single file conversion: Validated
- ✅ Batch conversion: 5/5 files succeeded
- ✅ Total: 24 test scenarios, 100% pass rate

### Documentation
- User documentation (README, QUICKSTART)
- Technical documentation (DESIGN)
- Test results and validation
- Architecture diagrams
- Sequence diagrams (installation, conversion)
- Class diagram (module structure)
- Activity workflow diagram
- State machine diagram
- Use case diagram

### Known Limitations
- Java PATH update requires session restart for persistence
- Graphviz installation via winget requires Windows 11 or App Installer
- PlantUML server mode not yet implemented
- Parallel batch conversion not yet implemented

---

## [Unreleased]

### Planned Features
- Support for PNG/PDF output formats
- Watch mode (auto-convert on file change)
- Parallel batch conversion for better performance
- VS Code extension integration
- GUI interface
- Docker containerization
- GitHub Actions workflow templates
- Checksum verification for downloads
- PlantUML server mode support

---

**Release Notes:**

Version 1.0.0 is the initial production release with full auto-installation capabilities for all dependencies. All core features are implemented, tested, and validated through comprehensive unit and integration testing.

**Breaking Changes:** None (initial release)

**Migration Guide:** Not applicable (initial release)

**Deprecations:** None

---

For detailed information, see:
- [README.md](README.md) - User guide
- [QUICKSTART.md](QUICKSTART.md) - Quick start
- [doc/DESIGN.md](doc/DESIGN.md) - System design
- [TEST_RESULTS.md](TEST_RESULTS.md) - Test validation
