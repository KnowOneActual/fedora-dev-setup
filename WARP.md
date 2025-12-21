# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This repository contains a Git workflow automation tool centered around `start-work.sh`, a Bash script that streamlines branch creation and management. The project emphasizes clean, portable, and ShellCheck-compliant Bash scripting.

## Development Commands

### Linting
All Bash scripts must pass ShellCheck before merging:
```bash
shellcheck start-work.sh
```

For recursive checking of all shell scripts:
```bash
find . -name "*.sh" -type f -exec shellcheck {} +
```

### Running the Main Script
```bash
./start-work.sh
```

The script provides an interactive workflow for:
1. Auto-stashing uncommitted changes (with user confirmation)
2. Selecting branch type (feature/, bugfix/, hotfix/, or none)
3. Creating/switching to a sanitized branch name
4. Syncing with the main branch from origin

## Code Architecture

### Core Components

**start-work.sh** (90 lines)
The main executable script that orchestrates the Git workflow. Key architecture:

- **Set strict mode**: Uses `set -euo pipefail` to catch errors early
- **Color output system**: Defines readonly color variables (GREEN, YELLOW, BLUE, PURPLE, NC) for terminal formatting
- **Helper functions**:
  - `spinner()`: Provides visual feedback during long-running operations
  - `log_info()`, `log_success()`, `log_warn()`: Consistent logging with color coding
- **Four-phase workflow**:
  1. Stash check: Detects uncommitted changes and prompts to stash
  2. Branch type selection: Interactive menu for prefix selection (feature/bugfix/hotfix/none)
  3. Branch naming: Sanitizes user input (lowercase, hyphen-separated, alphanumeric)
  4. Git synchronization: Fetches origin, syncs main branch, creates/switches to target branch

**Branch naming convention**:
- User input is automatically sanitized: uppercase→lowercase, spaces→hyphens, special chars removed
- Leading/trailing hyphens stripped
- Invalid names default to "work"
- Final format: `{prefix}{sanitized-name}`

## Coding Standards

### Bash Scripting Requirements

**ShellCheck compliance is mandatory**. All shell scripts must pass ShellCheck linting with zero warnings/errors before PR merge.

**Style conventions**:
- Use 4 spaces for indentation (not tabs)
- Enable strict error handling: `set -euo pipefail`
- Quote all variable expansions to prevent word splitting
- Use readonly for constants
- Prefer `[[ ]]` over `[ ]` for conditionals
- Use explicit variable names (no single-letter variables except loop counters)

**Safety patterns observed in this codebase**:
- User input validation before destructive operations
- Confirmation prompts for potentially dangerous actions (e.g., stashing)
- Background processes tracked with PID for safe spinner implementation
- Null checks before proceeding with operations

## Git Workflow

### Branch Naming
When creating branches (manually or via script):
- Feature work: `feature/descriptive-name`
- Bug fixes: `bugfix/issue-description`
- Hotfixes: `hotfix/critical-fix`

### Pull Requests
Use the template in `.github/PULL_REQUEST_TEMPLATE.md`:
- Link related issues
- Check appropriate change type
- Complete the checklist (code review, documentation, warnings)

## Repository Structure

```
.
├── start-work.sh          # Main workflow automation script
├── CONTRIBUTING.md        # Contribution guidelines
├── README.md              # Basic project info
├── CHANGELOG.md           # Version history
├── LICENSE                # MIT license
├── .gitignore            # Comprehensive ignore patterns (Python, Node, IDEs)
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── ISSUE_TEMPLATE/
│   └── workflows/        # Empty (no CI configured yet)
├── docs/                 # Empty (reserved for documentation)
├── src/                  # Empty (reserved for source code)
└── tests/                # Empty (reserved for tests)
```

## Notes

- The repository structure suggests future expansion (empty src/, tests/, docs/ directories)
- CI workflows directory exists but contains no workflow files yet
- ShellCheck enforcement is mentioned in CONTRIBUTING.md but no automated CI workflow is present
- Main branch is auto-detected from `git remote show origin`
