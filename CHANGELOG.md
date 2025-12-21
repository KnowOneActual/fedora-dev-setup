# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned for v1.1.0 (Backup & Restore)
- **Backup Pipeline**
  - `scripts/export-config.sh`: Export system state (packages, extensions, settings).
  - `scripts/restore-config.sh`: Replay setup from backup.
- **Documentation**
  - `docs/ARCHITECTURE.md`: Internal design and data flow.
  - `docs/CUSTOMIZE.md`: Guide for adding packages/tools.
  - `docs/TROUBLESHOOTING.md`: Recovery steps for common failures.
- **CI/CD**
  - GitHub Actions workflow for ShellCheck validation.

### Planned for v1.2.0 (Hardware & GPU)
- **Hardware Detection**: Profile GPU (NVIDIA/AMD), CPU, and RAM.
- **GPU Acceleration**: CUDA and ROCm setup scripts.
- **Optimization**: Laptop (power) vs. Workstation (performance) profiles.
- **Language Stacks**: Node.js, Go, and Rust support.

---

## [1.0.0] - 2025-12-21

### Added

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