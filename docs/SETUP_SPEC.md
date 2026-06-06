# Fedora Dev Setup - Technical Specification

**Version:** 1.6.0  
**Status:** Active  
**Last Updated:** June 6, 2026

---

## 1. System Overview

The **Fedora Dev Setup** is a modular, idempotent bootstrapping system designed to configure a fresh Fedora Workstation for professional development. It features a robust **Interactive CLI** entry point (`bootstrap-fedora.sh`) that orchestrates the entire process.

---

## 2. Architecture

### Orchestrator: `bootstrap-fedora.sh`
The main entry point. It provides an interactive text menu if run without arguments, or accepts CLI flags (`--install`, `--dry-run`, `--validate`) for automation.

### Shared Libraries (`scripts/lib/`)
- **`variables.sh`**: Centralized configuration file holding all arrays for tools, apps, and extensions.
- **`logging.sh`**: Standardized, timestamped, colored logging. Uses `tee` to capture all stdout/stderr to a log file.
- **`utils.sh`**: Idempotent functions for DNF, file management, and system checks.

### Installation Phases

#### Phase 1: System Base (`00-system-base.sh`)
**Goal:** Prepare the OS.
- DNF Optimization (parallel downloads).
- Core Tools: GCC, Git, Tmux, Zsh.

#### Phase 2: User Environment
**Goal:** Modern development workflow.
- **Python (`10-python-dev.sh`):** `uv` and `pipx` installation.
- **IDE (`20-vscodium.sh`):** VSCodium with extensions and settings.
- **Shell (`25-setup-zsh.sh`):** Oh My Zsh, plugins (syntax-highlighting, autosuggestions), and aliases.

#### Phase 3: Hardware Awareness
**Goal:** Adapt to physical hardware.
- **Detection (`detect-hardware.sh`):** Profiles GPU and Chassis.
- **GPU (`30-gpu-setup.sh`):** NVIDIA/AMD drivers.
- **Optimization (`31-hardware-optimization.sh`):** TLP for laptops, CPU governors for desktops.
- **Languages (`40-languages.sh`):** Node.js, Go, Rust.

#### Phase 4 & 5: Applications
**Goal:** Daily driver functionality.
- **Containers (`45-containers.sh`):** Docker CE and Podman/Distrobox.
- **Desktop (`50-desktop-apps.sh`):** Flatpaks (LibreOffice, Obsidian), Multimedia Codecs, and **Nerd Fonts**.

#### Phase 6: Security Audit (`60-security.sh`)
**Goal:** System Hardening.
- **Tooling:** Installs Lynis.
- **Audit:** Runs a non-interactive security scan.
- **Reporting:** Generates a "Hardening Index" and saves a log to `/var/log/lynis-report.log`.

#### Validation (`99-validate.sh`)
**Goal:** Verification.
- Checks presence of binaries, Docker service status, Flatpak apps, and security logs.

---

## 3. Backup & Restore Architecture

### Export (`scripts/export-config.sh` or `bootstrap-fedora.sh --backup`)
Creates a portable snapshot.
- **Packages:** DNF, Pipx, VSCodium Extensions, Flatpaks.
- **Configs:** Shell configuration files (`.bashrc`, `.zshrc`, `.zprofile`, `.profile`), SSH connections (`.ssh/config`), Git preferences (`.gitconfig`), Tmux properties (`.tmux.conf`), custom zsh directories (`~/.config/zsh-custom`), VSCodium preferences, and GNOME window manager/shortcut configurations (via `dconf dump`).
- **Artifact:** `~/fedora-backups/fedora_dev_backup_YYYYMMDD_HHMMSS.tar.gz`.

### Restore (`scripts/restore-config.sh` or `bootstrap-fedora.sh --restore`)
Rehydrates a system.
- **Auto-Discovery:** Automatically scans `~/fedora-backups/` and prompts the user with an interactive selection if no specific backup archive is passed.
- **Resilient Package Recovery:** Installs DNF packages using a best-effort transaction; falls back to package-by-package installation on error to ensure a single repository failure does not block restoration.
- **User Permission Alignment:** Automatically resolves user home directory context and applies proper user-level ownership (`chown`) on restored files and directories.