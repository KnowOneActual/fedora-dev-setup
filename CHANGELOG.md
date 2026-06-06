# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.6.0] - 2026-06-06

### Added
- **Interactive Backup & Restore Menu** (`bootstrap-fedora.sh`): Integrated backup and restore workflows directly into the main bootstrapper CLI flags (`--backup` and `--restore`) and the interactive menu options.
- **Interactive Backup Selection** (`scripts/restore-config.sh`): Introduced auto-scanning of backups in `~/fedora-backups/` to let the user select the latest file interactively via a numbered list.
- **Resilient Package Recovery** (`scripts/lib/utils.sh`): Implemented `install_dnf_packages_best_effort` which falls back to individual package installation if the bulk transaction fails, preventing a single unconfigured repository or missing package from breaking the entire environment restore.
- **Expanded Backup Scope**: Added support for backing up and restoring `.tmux.conf`, `.profile`, `.zprofile`, local shell customization folders (`~/.config/zsh-custom/`), and GNOME/desktop configurations (via `dconf` settings dump/load).
- **Centralized Configuration** (`scripts/lib/variables.sh`): Extracted all hardcoded arrays (e.g., CLI tools, Python tools, VSCodium extensions, Node packages, Flatpaks, and validation targets) into a single configuration file for easy user customization.
- **Enhanced Logging** (`scripts/lib/logging.sh`): Integrated `tee` to capture all command output (stdout and stderr) into timestamped log files, significantly improving debuggability.

### Fixed
- **Home Path & File Ownership Correctness**: Resolved issue where running recovery as `sudo` would restore configuration files to the `/root` directory or leave them owned by `root`. Now resolves user home dynamically and enforces user ownership (`chown`) on all restored configurations.
- **Robust Centralized Logging**: Adjusted logging pathing to write to root-level `<root>/logs` and check writability before logging to prevent permission-denied crashes.
- **ShellCheck Issues**: Fixed a variable expansion bug in `scripts/10-python-dev.sh` and resolved several other linting warnings across the scripts.

## [1.5.0] - 2026-04-25

### Added
- **RPM Fusion Repositories** (`scripts/00-system-base.sh`): Now automatically enables both Free and Nonfree RPM Fusion repositories during the base setup phase. This ensures proprietary drivers and codecs are available for downstream scripts.
- **Core Dependencies**: Explicitly added `zsh`, `tmux`, `jq`, `git`, `curl`, and `make` to the base system installation to ensure `bootstrap-fedora.sh` is fully self-sufficient and validation-ready.
- **Default Shell** (`scripts/25-setup-zsh.sh`): Added automation to change the user's default shell to Zsh using `chsh` upon successful configuration.

### Changed
- **Modern CLI Tools** (`scripts/05-modern-tools.sh`):
  - Replaced the unavailable `bottom` package with `htop` to ensure DNF transactions complete successfully.
  - Added `direnv` to the modern toolchain.
  - Updated system aliases to map `top` to `htop`.
- **Fedora Support**: Updated documentation and configuration to reflect testing and support for Fedora 43.

### Fixed
- **Installation Resilience**: Fixed a critical issue where an unavailable package in a DNF transaction (like `bottom`) would cause all other modern tools (like `zoxide`, `fzf`) to be skipped.
- **GPU Driver Availability**: Resolved "Package not found" errors for `intel-media-driver` by ensuring RPM Fusion is enabled before Phase 3 execution.
- **Zsh Setup**: Fixed failures in Oh My Zsh installation caused by `zsh` not being present on the base system.

## [1.4.1] - 2025-12-25

### Added

* New CLI utilities: `ripgrep` (search), `fzf` (fuzzy finder), `zoxide` (smart cd), `bottom` (system monitor), and `tldr` (simplified man pages).
* Automatic shell aliases for improved quality of life (e.g., `ls` maps to `eza`, `cat` maps to `bat`).
* Shell integration for `zoxide` to track frequently used directories.

### Changed

* Expanded the `05-modern-tools.sh` script to handle both package installation and shell configuration.

### Fixed

* Added a permission fix to ensure `.bashrc` remains owned by the actual user after script execution.


## [1.4.0] - 2025-12-25

### 🚀 New Features
- **Git & SSH Automation** (`scripts/15-git-ssh-setup.sh`): 
  - Added an interactive setup for Git global identity (`user.name` and `user.email`).
  - Automated generation of Ed25519 SSH keys with correct user-home permissions.
  - Implemented persistent `ssh-agent` configuration in both `.bashrc` and `.zshrc` to ensure keys stay loaded across sessions.
  - Integrated a repository conversion utility that bulk-updates existing HTTPS remotes to SSH to resolve GitHub password authentication errors.
  - Added a connection verification step to test the GitHub SSH link immediately after setup.

### 🛠 Improvements
- **Orchestrator** (`bootstrap-fedora.sh`): Integrated the new Git/SSH setup as Phase 2.1 in the main installation sequence.
- **Documentation**: Updated technical specifications to reflect the new modular phase for user identity and security.

## [1.3.0] - 2025-12-24

### 🚀 New Features
- **Security Auditing** (`scripts/60-security.sh`): 
  - Integrated **Lynis** to perform automated security scanning.
  - outputs a "Hardening Index" score and saves a detailed report to `/var/log/lynis-report.log`.
- **Interactive Menu** (`bootstrap-fedora.sh`): 
  - Running the bootstrapper without arguments now launches a user-friendly text menu.
  - Options: Install, Dry Run, Validate, Exit.
- **Visual Polish** (`scripts/50-desktop-apps.sh`): 
  - Added automated installation of **JetBrains Mono Nerd Fonts** to fix broken icons in terminal/editor themes.

### 🛠 Improvements
- **Bootstrapper:** Refactored argument parsing to support both interactive mode and CI-friendly flags (`--install`, `--validate`) simultaneously.
- **Documentation:** Updated `ROADMAP.md` to reflect the completion of Security and UX phases.

### 🐛 Fixed
- **Network Resilience:** The package installer now gracefully handles temporary mirror connection resets (Curl error 56) during font installation.


## [1.2.1] - 2025-12-23

### Fixed
- **Shell Setup** (`scripts/00-system-base.sh`): Added missing `zoxide` and `thefuck` packages to the base install list.
- **Zsh Config** (`scripts/25-setup-zsh.sh`): 
  - Fixed a critical bug where the script tried to source every file in `$HOME` (causing "Desktop: command not found" errors).
  - Added safe existence checks before initializing `zoxide`, `thefuck`, and `direnv`.
- **CI** (`.github/workflows/validate.yml`): Fixed flaky ShellCheck action by switching to manual install and excluding false positives (SC1091, SC2016).
- **Documentation**: Updated `README.md` with improved layout and badges.


## [1.2.1] - 2025-12-22

### Fixed
- **CI** (`.github/workflows/validate.yml`): Fixed flaky ShellCheck action by switching to manual install and excluded false positives (SC1091, SC2016).- **Python Setup** (`scripts/10-python-dev.sh`): Fixed `uv` installation running as root; it now correctly installs to the user's `~/.local/bin` and updates the user's `PATH`.
- **VSCodium** (`scripts/20-vscodium.sh`): Resolved `EACCES` permission errors by recursively enforcing user ownership on `~/.config/VSCodium` before installing extensions.
- **Hardware Detection** (`scripts/detect-hardware.sh`):
  - Added fallback logic for empty chassis detection (defaults to "desktop").
  - Added support for VMware and Virtio GPUs to prevent "unknown" vendor warnings in virtualized environments.
- **Validation** (`scripts/99-validate.sh`): Fixed a false positive where `uv` was reported missing because the validation script checked the root user's `PATH` instead of the user's home directory.
- **Rust** (`scripts/40-languages.sh`): Ensured `~/.cargo/env` is persistently sourced in `.bashrc` and `.zshrc` for the non-root user.


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
