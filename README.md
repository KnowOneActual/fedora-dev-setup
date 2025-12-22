# Fedora Python Development Environment Setup

![Fedora](https://img.shields.io/badge/Fedora-40+-blue?logo=fedora&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12+-yellow?logo=python&logoColor=white)
![NVIDIA](https://img.shields.io/badge/GPU-NVIDIA%20CUDA-green?logo=nvidia)
![AMD](https://img.shields.io/badge/GPU-AMD%20ROCm-red?logo=amd)
![License](https://img.shields.io/badge/License-MIT-green)

# Still in testing phase! 

A comprehensive, reproducible setup guide for configuring Fedora as a professional development workstation.

## 📋 Features

- ✅ **One-Command Setup**: Orchestrated via `bootstrap-fedora.sh`.
- ✅ **Hardware Aware**: Automatically detects NVIDIA/AMD GPUs and installs drivers.
- ✅ **Chassis Optimized**: Auto-configures TLP for laptops or Performance mode for desktops.
- ✅ **Power User Shell**: Zsh + Oh My Zsh + Syntax Highlighting + Autosuggestions.
- ✅ **Backup & Restore**: Portable snapshots of your packages and configs.
- ✅ **Full Stack**: Python (uv/pipx), Node.js, Go, Rust, and VSCodium.

## 🚀 Quick Start

### Installation

```bash
# 1. Clone the repository
git clone [https://github.com/KnowOneActual/fedora-dev-setup.git](https://github.com/KnowOneActual/fedora-dev-setup.git)
cd fedora-dev-setup

# 2. Run the full installer
# (Detects hardware, installs drivers, sets up shell & tools)
sudo ./bootstrap-fedora.sh --install

```

### Backup & Restore

* **Backup:** `./scripts/export-config.sh`
* **Restore:** `./scripts/restore-config.sh <backup_file.tar.gz>`

## 📁 Directory Structure

```text
fedora-dev-setup/
├── bootstrap-fedora.sh      # Main orchestrator
├── scripts/
│   ├── 00-system-base.sh    # Core Tools
│   ├── 10-python-dev.sh     # Python Stack
│   ├── 20-vscodium.sh       # Editor Setup
│   ├── 25-setup-zsh.sh      # Shell & Dotfiles
│   ├── 30-gpu-setup.sh      # GPU Drivers (NVIDIA/AMD)
│   ├── 31-hardware-opt.sh   # Power/Perf Tuning
│   ├── 40-languages.sh      # Node, Go, Rust
│   ├── export-config.sh     # Backup Tool
│   └── restore-config.sh    # Restore Tool
└── docs/                    # Specs & Roadmap



```



## 📊 Status

- Latest Fedora Version: **40**
- Python Support: **3.10, 3.11, 3.12**
- VSCodium: **Latest**
- Last Updated: **December 2025**
