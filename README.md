# Fedora Python Development Environment Setup

![Fedora](https://img.shields.io/badge/Fedora-40+-blue?logo=fedora&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12+-yellow?logo=python&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Stable-green)

A comprehensive, reproducible setup guide for configuring Fedora as a professional Python development environment.

## 📋 Features

- ✅ **One-Command Setup**: Orchestrated via `bootstrap-fedora.sh`
- ✅ **Backup & Restore**: Portable snapshots of your packages and configs
- ✅ **Idempotent**: Safe to run multiple times
- ✅ **Modern Python**: `uv`, `pipx`, Python 3.12+
- ✅ **VSCodium**: Telemetry-free VS Code with Python, Ruff, and GitLens
- ✅ **Observability**: Detailed, color-coded logging

## 🚀 Quick Start

### Installation

```bash
# 1. Clone the repository
git clone [https://github.com/KnowOneActual/fedora-dev-setup.git](https://github.com/KnowOneActual/fedora-dev-setup.git)
cd fedora-dev-setup

# 2. Run the full installer
sudo ./bootstrap-fedora.sh --install

```

### Backup & Restore

**To Create a Backup:**

```bash
./scripts/export-config.sh
# Creates archive in ~/fedora-backups/

```

**To Restore:**

```bash
./scripts/restore-config.sh ~/fedora-backups/backup_NAME.tar.gz

```

## 📁 Directory Structure

```text
fedora-dev-setup/
├── bootstrap-fedora.sh      # Main entry point
├── scripts/
│   ├── 00-system-base.sh    # Core Tools
│   ├── 10-python-dev.sh     # Python Stack
│   ├── 20-vscodium.sh       # Editor Setup
│   ├── export-config.sh     # Backup Tool
│   ├── restore-config.sh    # Restore Tool
│   └── lib/                 # Shared Libraries
├── docs/
│   ├── SETUP_SPEC.md        # Technical Specs
│   └── ROADMAP.md           # Future Plans
└── README.md                # Usage Guide

```



## 📊 Status

- Latest Fedora Version: **40**
- Python Support: **3.10, 3.11, 3.12**
- VSCodium: **Latest**
- Last Updated: **December 2025**
