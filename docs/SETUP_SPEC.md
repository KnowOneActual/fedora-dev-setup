# Fedora Dev Setup - Technical Specification

**Version:** 1.3.0  
**Status:** Active  
**Last Updated:** December 23, 2025

---

## 1. System Overview

The **Fedora Dev Setup** is a modular, idempotent bootstrapping system designed to configure a fresh Fedora Workstation for professional development and daily use.

---

## 2. Architecture

### Installation Phases

#### Phase 1: System Base (`00-system-base.sh`)
**Goal:** Prepare the OS.
- DNF Optimization (parallel downloads).
- Core Tools: GCC, Git, Tmux, Zsh.

#### Phase 2: Python Environment (`10-python-dev.sh`)
**Goal:** Modern Python workflow.
- `uv` and `pipx` installation.
- Global tools: `ruff`, `black`, `mypy`.

#### Phase 3: Hardware Awareness
**Goal:** Adapt to physical hardware.
- **Detection (`detect-hardware.sh`):** Profiles GPU and Chassis.
- **GPU (`30-gpu-setup.sh`):** NVIDIA/AMD drivers.
- **Optimization (`31-hardware-optimization.sh`):** TLP for laptops, CPU governors for desktops.

#### Phase 4: Containerization (`45-containers.sh`)
**Goal:** Isolated development environments.
- **Podman & Distrobox:** Native Fedora tools for containerized workflows.
- **Docker CE:** Industry standard runtime, user added to `docker` group.

#### Phase 5: Desktop Workstation (`50-desktop-apps.sh`)
**Goal:** Daily driver functionality.
- **Multimedia:** Full codec support (H.264/HEVC) via RPM Fusion.
- **Flatpak:** Flathub repository enabled.
- **Apps:** LibreOffice, Obsidian, Slack, Postman, DBeaver.

#### Validation (`99-validate.sh`)
**Goal:** Verification.
- Checks presence of binaries, Docker service status, and Flatpak apps.

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