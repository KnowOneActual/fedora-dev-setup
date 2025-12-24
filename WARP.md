# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This repository contains an automated Fedora workstation provisioning system that transforms a fresh Fedora installation into a battle-ready development environment. The project is built around modular Bash scripts that handle system setup, development tools, hardware optimization, and security hardening. All scripts emphasize idempotency, dry-run safety, and ShellCheck compliance.

## Development Commands

### Linting
All Bash scripts must pass ShellCheck before merging:
```bash
find . -name "*.sh" -type f -exec shellcheck {} +
```

Or check a specific script:
```bash
shellcheck scripts/00-system-base.sh
```

### Running the Bootstrapper
Interactive mode (shows menu):
```bash
./bootstrap-fedora.sh
```

Non-interactive modes:
```bash
# Full installation (requires sudo)
sudo ./bootstrap-fedora.sh --install

# Dry run (preview without changes)
./bootstrap-fedora.sh --dry-run

# Validate existing setup
./bootstrap-fedora.sh --validate
```

### Testing Changes
1. **Syntax check**: Run ShellCheck on modified scripts
2. **Dry run**: Test logic flow without system modifications
3. **Validation**: Verify installation state after changes

## Code Architecture

### Core Components

**bootstrap-fedora.sh** (~140 lines)
The main orchestrator that provides CLI interface and executes phase scripts in order:
- Interactive menu system for user-friendly operation
- Argument parsing for CLI flags (--install, --dry-run, --validate)
- Sequential execution of numbered phase scripts
- Integrates with shared logging library

**Modular Phase Scripts** (scripts/ directory)
Numbered scripts execute in sequence:
- `00-system-base.sh`: Core system packages, DNF optimization, base repos
- `10-python-dev.sh`: Python toolchain (uv, pipx, ruff, black, mypy)
- `20-vscodium.sh`: IDE setup with extensions
- `25-setup-zsh.sh`: Shell configuration (Oh My Zsh, plugins)
- `30-gpu-setup.sh`: Hardware-specific GPU drivers (NVIDIA CUDA, AMD ROCm)
- `31-hardware-optimization.sh`: Chassis-based optimization (TLP for laptops, performance for desktops)
- `40-languages.sh`: Multi-language toolchains (Node.js, Go, Rust)
- `45-containers.sh`: Container runtime setup
- `50-desktop-apps.sh`: GUI applications and Nerd Fonts
- `60-security.sh`: Security auditing with Lynis
- `99-validate.sh`: Post-install verification suite

**Utility Scripts**
- `detect-hardware.sh`: Hardware detection for GPU/chassis optimization
- `export-config.sh`: Backup system (packages, dotfiles, extensions)
- `restore-config.sh`: Restore from backup tarball

**Shared Libraries** (scripts/lib/)
- `logging.sh`: Centralized logging with color output and file logging
- `utils.sh`: Common helper functions

### Design Patterns

**Idempotency**: All scripts check existing state before making changes. Safe to run multiple times.

**Dry-Run Support**: Scripts respect `DRY_RUN=true` environment variable to preview actions without execution.

**Logging Architecture**:
- Timestamped log files in `logs/` directory (git-ignored)
- Color-coded console output (INFO/OK/WARN/ERROR)
- Centralized via `scripts/lib/logging.sh`

**Error Handling**: Scripts use `set -e` to fail fast, with careful error checking around critical operations

## Coding Standards

### Bash Scripting Requirements

**ShellCheck compliance is mandatory**. All shell scripts must pass ShellCheck linting with zero warnings/errors before PR merge. CI enforces this via GitHub Actions.

**Style conventions**:
- Use 4 spaces for indentation (not tabs)
- Enable strict error handling: `set -e` (or `set -euo pipefail` where appropriate)
- Always use shebang: `#!/bin/bash` (or `#!/usr/bin/env bash` for bootstrapper)
- Quote all variable expansions to prevent word splitting: `"$VAR"`
- Use readonly for constants
- Prefer `[[ ]]` over `[ ]` for conditionals
- Use explicit variable names (no single-letter variables except loop counters)

**Safety patterns in this codebase**:
- Check for root/sudo before system modifications
- Idempotency checks (e.g., grep config files before appending)
- Dry-run mode support: `if [[ "${DRY_RUN:-false}" == "true" ]]; then`
- Shared logging via sourced library: `source "$(dirname "$0")/lib/logging.sh"`
- Graceful fallbacks when libraries are missing

## Git Workflow

### Branch Naming
Follow standard naming conventions:
- Feature work: `feature/descriptive-name` or `feat/descriptive-name`
- Bug fixes: `bugfix/issue-description` or `fix/issue-description`
- Documentation: `docs/update-description`
- Refactoring: `refactor/component-name`
- Chores: `chore/task-description`

### Pull Requests
Use the template in `.github/PULL_REQUEST_TEMPLATE.md`:
- Link related issues
- Check appropriate change type
- Complete the checklist (ShellCheck passed, tested via dry-run, documentation updated)
- Include co-author line: `Co-Authored-By: Warp <agent@warp.dev>`

## Repository Structure

```
.
├── bootstrap-fedora.sh           # Main entry point (interactive orchestrator)
├── CONTRIBUTING.md               # Contribution guidelines
├── README.md                     # User-facing documentation
├── ROADMAP.md                    # Development roadmap (currently v1.3.0)
├── CHANGELOG.md                  # Version history
├── LICENSE                       # MIT license
├── WARP.md                       # This file (AI assistant guidance)
├── .gitignore                    # Comprehensive ignore patterns
├── git-fedora-setup.md           # Git workflow documentation
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── ISSUE_TEMPLATE/
│   └── workflows/
│       └── validate.yml          # CI: ShellCheck + Fedora dry-run tests
├── docs/
│   ├── SETUP_GUIDE.md            # Installation documentation
│   └── SETUP_SPEC.md             # Technical specifications
├── scripts/
│   ├── 00-system-base.sh         # Phase 1: Core system
│   ├── 10-python-dev.sh          # Phase 2: Python toolchain
│   ├── 20-vscodium.sh            # Phase 2: IDE setup
│   ├── 25-setup-zsh.sh           # Phase 2: Shell config
│   ├── 30-gpu-setup.sh           # Phase 3: GPU drivers
│   ├── 31-hardware-optimization.sh  # Phase 3: Power management
│   ├── 40-languages.sh           # Phase 3: Node/Go/Rust
│   ├── 45-containers.sh          # Phase 4: Docker/Podman
│   ├── 50-desktop-apps.sh        # Phase 5: GUI apps + fonts
│   ├── 60-security.sh            # Phase 6: Lynis security audit
│   ├── 99-validate.sh            # Verification suite
│   ├── detect-hardware.sh        # Hardware detection utility
│   ├── export-config.sh          # Backup tool
│   ├── restore-config.sh         # Restore tool
│   └── lib/
│       ├── logging.sh            # Shared logging library
│       └── utils.sh              # Common helper functions
├── logs/                         # Git-ignored timestamped logs
├── src/                          # Reserved for future use
└── tests/                        # Reserved for future test suite
```

## CI/CD

**GitHub Actions** (`.github/workflows/validate.yml`):
- **ShellCheck**: Lints all `.sh` files on every push
- **Fedora Container Test**: Runs bootstrap in dry-run mode on Fedora 41 container
- **Backup Script Test**: Validates export-config.sh functionality

## Version Information

**Current Version**: v1.3.0  
**Target Platform**: Fedora 41+ (tested on Rawhide)  
**Next Milestone**: v1.4.0 (Dotfile mastery with GNU Stow)

## Important Notes

- All scripts are designed to be idempotent and safe to re-run
- The `logs/` directory is git-ignored and contains timestamped execution logs
- Hardware detection (`detect-hardware.sh`) drives conditional installations (GPU drivers, power management)
- Backup/restore system creates portable `.tar.gz` archives for environment migration
- Scripts source shared libraries from `scripts/lib/` for consistent behavior
