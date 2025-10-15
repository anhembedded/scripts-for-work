# Design Documentation

This directory contains comprehensive design documentation and PlantUML diagrams for the Convert-UmlToSvg project.

## Files

### Documentation

- **DESIGN.md**: Complete system design documentation including architecture, module specifications, data flow, and design decisions

### PlantUML Diagrams

1. **architecture-overview.puml**: System component architecture showing modules, dependencies, and relationships

2. **sequence-dependency-install.puml**: Sequence diagram showing the complete dependency installation flow (Test Case 2)

3. **sequence-conversion.puml**: Sequence diagram showing the UML to SVG conversion process

4. **class-diagram.puml**: Class/module structure diagram showing functions, relationships, and data structures

5. **activity-workflow.puml**: Activity diagram showing the complete workflow from start to finish with decision points

6. **state-diagram.puml**: State machine diagram showing dependency and conversion states

7. **usecase-diagram.puml**: Use case diagram showing actors (Developer, CI/CD, Doc Team) and system interactions

## Generating SVG Diagrams

To generate SVG files from these PlantUML diagrams:

```powershell
# From the project root directory
cd ..

# Convert all design diagrams
.\Convert-UmlToSvg.ps1 -Path "doc" -Out "doc\svg" -Force

# View a specific diagram
.\Convert-UmlToSvg.ps1 -Path "doc\architecture-overview.puml" -Preview
```

## Diagram Descriptions

### Architecture Overview
Shows the complete system architecture with:
- Main script and modules
- External dependencies (Java, PlantUML, Graphviz)
- Input/output structure
- Testing components
- Dependency relationships

### Sequence: Dependency Install
Illustrates Test Case 2 flow:
1. User runs `-Check -Download`
2. Script detects missing dependencies
3. Downloads PlantUML JAR (24.08 MB)
4. Downloads and extracts Java portable (MS OpenJDK 17)
5. Installs Graphviz via winget
6. Verifies all installations successful

### Sequence: Conversion
Shows the conversion workflow:
1. Dependency verification
2. Finding input .puml files
3. Processing each file
4. Executing Java + PlantUML
5. Generating SVG output
6. Displaying results

### Class Diagram
Displays module structure:
- Convert-UmlToSvg.ps1 script
- DependencyManager module functions
- UmlConverter module functions
- Logger module
- External dependency classes
- Relationships and dependencies

### Activity Workflow
Complete decision flow:
- Parameter parsing
- Check mode vs Convert mode
- Dependency validation
- File processing
- Error handling paths
- Success/failure tracking

### State Diagram
State machine showing:
- Dependency checking states
- Installation states
- Conversion states
- Transitions and conditions

### Use Case Diagram
System boundaries and actors:
- Developer use cases
- CI/CD system integration
- Documentation team workflows
- Include and extend relationships

## Design Highlights

### Key Features
- ✅ Automatic dependency management
- ✅ Multi-path dependency detection
- ✅ Portable installations (no admin rights)
- ✅ Comprehensive error handling
- ✅ Modular architecture

### Design Decisions
1. **Portable Java**: No admin rights, parallel installations
2. **Multi-path detection**: Local installs prioritized over PATH
3. **Winget for Graphviz**: Official package manager integration
4. **Absolute paths**: Eliminates PlantUML path resolution issues
5. **Modular design**: Testable, maintainable, reusable

### Test Coverage
- Unit tests: 11/11 passing (100%)
- Integration Test Case 1: Uninstall/error handling ✅
- Integration Test Case 2: Auto-install/conversion ✅
- Total validation: 24 test scenarios, 100% pass rate

## Related Documentation

- **README.md**: User documentation and usage guide
- **QUICKSTART.md**: Quick start guide for new users
- **PROJECT_SUMMARY.md**: Project overview and status
- **TEST_RESULTS.md**: Detailed test results and validation

---

**Last Updated:** October 15, 2025  
**Version:** 1.0.0  
**Status:** Production Ready
