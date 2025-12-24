# Fedora Dev Setup - Technical Specification

**Version:** 1.3.0  
**Status:** Active  
**Last Updated:** December 24, 2025

---

## 1. System Overview

The **Fedora Dev Setup** is a modular, idempotent bootstrapping system designed to configure a fresh Fedora Workstation for professional development. It features a robust **Interactive CLI** entry point (`bootstrap-fedora.sh`) that orchestrates the entire process.

---

## 2. Architecture

### Orchestrator: `bootstrap-fedora.sh`
The main entry point. It provides an interactive text menu if run without arguments, or accepts CLI flags (`--install`, `--dry-run`, `--validate`) for automation.

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

### Export (`scripts/export-config.sh`)
Creates a portable snapshot.
- **Packages:** DNF, Pipx, VSCodium Extensions, **Flatpaks**.
- **Configs:** Dotfiles (`.zshrc`, etc.) and VSCodium settings.
- **Artifact:** `~/fedora-backups/fedora_dev_backup_YYYYMMDD.tar.gz`.

### Restore (`scripts/restore-config.sh`)
Rehydrates a system.
- Installs missing DNF/Flatpak packages from the manifest.
- Safely restores config files (with backups).