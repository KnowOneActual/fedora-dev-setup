# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---
## [1.2.0] - 2025-12-22

### Added
- **Hardware Detection** (`scripts/detect-hardware.sh`): Generates a JSON system profile identifying GPU vendor and Chassis type (Laptop/Desktop).
- **GPU Setup** (`scripts/30-gpu-setup.sh`): Automatically installs NVIDIA CUDA drivers or AMD ROCm stacks based on detection.
- **Hardware Optimization** (`scripts/31-hardware-optimization.sh`): Applies TLP for laptops and performance governors for desktops.
- **Extended Language Stack** (`scripts/40-languages.sh`): Installs Node.js, Go, and Rust toolchains.
- **Shell Configuration** (`scripts/25-setup-zsh.sh`): Dedicated setup for Oh My Zsh, plugins (syntax highlighting, autosuggestions), and custom "Power User" aliases.

### Changed
- **Orchestrator**: `bootstrap-fedora.sh` now executes the Phase 2.5 and Phase 3 scripts.
- **Dependencies**: Added `pciutils`, `jq`, and `util-linux` for hardware profiling.

## [1.1.0] - 2025-12-22

### Added
- **Backup System** (`scripts/export-config.sh`):
  - Automatically detects and exports installed DNF packages, Pipx tools, and VSCodium extensions.
  - Backs up critical dotfiles (`.bashrc`, `.zshrc`, `.gitconfig`, `.ssh/config`).
  - Saves VSCodium `settings.json` and `keybindings.json`.
  - Compresses everything into a timestamped `.tar.gz` archive.
- **Restore System** (`scripts/restore-config.sh`):
  - Re-installs missing packages from the backup list.
  - Restores VSCodium extensions and settings.
  - Safely restores dotfiles (creating backups of existing files before overwriting).
- **Shell Configuration** (`scripts/25-setup-zsh.sh`):
  - Dedicated script for Zsh, Oh My Zsh, and plugin setup.

### Changed
- **VSCodium Setup**: Updated extension list to include user productivity tools (ErrorLens, Rainbow CSV, etc.).
- **Orchestrator**: Updated `bootstrap-fedora.sh` to support new modules.

---

## [1.0.0] - 2025-12-21

#### Core Infrastructure
- **`bootstrap-fedora.sh`**: Main orchestrator script.
  - CLI Options: `--dry-run`, `--install`, `--validate`, `--help`.
  - Performs pre-flight checks (OS version, internet, root privileges).
- **Shared Libraries** (`scripts/lib/`):
  - `logging.sh`: Standardized, timestamped, colored logging.
  - `utils.sh`: Idempotent functions for DNF, file management, and system checks.

#### Modular Setup Scripts
- **`scripts/00-system-base.sh`**:
  - DNF optimization (parallel downloads).
  - Base tools: gcc, git, tmux, zsh, htop, neovim, ripgrep.
  - RPM Fusion repository enablement.
- **`scripts/10-python-dev.sh`**:
  - Modern Python stack: `uv` (fast installer) and `pipx` (isolated tools).
  - Global tools: black, ruff, mypy, pytest, ipython.
- **`scripts/20-vscodium.sh`**:
  - VSCodium installation via official RPM.
  - Extensions: Python, Ruff, GitLens.
  - Settings: Format on save, 88-char line limit (Ruff/Black standard).
- **`scripts/99-validate.sh`**:
  - Verification suite to ensure all components installed correctly.

#### Documentation
- **`SETUP_SPEC.md`**: Technical specification of the installation process.
- **`ROADMAP.md`**: Project planning and phase breakdown.
- **`README.md`**: Updated usage instructions and directory structure.



## [Unreleased]


### Planned for v1.2.0 (Hardware & GPU)
- **Hardware Detection**: Profile GPU (NVIDIA/AMD), CPU, and RAM.
- **GPU Acceleration**: CUDA and ROCm setup scripts.
- **Optimization**: Laptop (power) vs. Workstation (performance) profiles.
- **Language Stacks**: Node.js, Go, and Rust support.
