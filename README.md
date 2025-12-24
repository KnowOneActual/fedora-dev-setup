# 🚀 Fedora Development Workstation Setup

![Version](https://img.shields.io/badge/version-1.3.0-blue?style=for-the-badge)
![Fedora](https://img.shields.io/badge/Fedora-41-blue?logo=fedora&logoColor=white&style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Build Status](https://img.shields.io/badge/build-passing-brightgreen?style=for-the-badge)

**Turn a fresh Fedora installation into a battle-ready development workstation in minutes.**

This automated provisioning suite transforms a stock Fedora OS into a professional environment. It intelligently detects your hardware, installs a modern multi-language stack, hardens system security, and configures a power-user shell.

---

## ✨ Features

### 🛡️ Security First
* **Automated Auditing**: Integrated **Lynis** security scanning.
* **Hardening Report**: Generates a system hardening index and detailed log report after every install.

### 🧠 Hardware Intelligence
* **GPU Auto-Detection**: Automatically identifies NVIDIA or AMD GPUs and installs the correct drivers (CUDA/ROCm).
* **Chassis Optimization**: Detects if you are on a **Laptop** (installs TLP/Battery savers) or **Desktop** (enables Performance governors).

### 🛠️ The Dev Stack
* **Python Powerhouse**: Sets up `uv` (blazing fast installer) and `pipx` for isolated tools (`ruff`, `black`, `mypy`).
* **Polyglot Ready**: Installs complete toolchains for **Node.js**, **Go**, and **Rust** (via rustup).
* **IDE Pre-Configured**: Installs **VSCodium** with a curated list of extensions and sane defaults.

### 💻 Visual & UX Polish
* **Interactive Menu**: No need to memorize flags—just run the script and choose your path.
* **Font Perfection**: Installs **JetBrains Mono Nerd Fonts** automatically, ensuring terminal icons look perfect.
* **Zsh Configured**: Installs **Oh My Zsh** with syntax highlighting and autosuggestions out of the box.

---

## 🚀 Quick Start

### 1. Installation
Clone the repo and run the bootstrap script.

```bash
git clone https://github.com/KnowOneActual/fedora-dev-setup.git
cd fedora-dev-setup

# Launches the interactive menu. You will need to 'sudo' to install.
./bootstrap-fedora.sh

```

### 2. CLI Options (Non-Interactive)

For CI/CD or power users who prefer flags:

```bash
# Run full installation
sudo ./bootstrap-fedora.sh --install

# Validate existing setup
./bootstrap-fedora.sh --validate

# Dry Run (Safe Preview)
./bootstrap-fedora.sh --dry-run

```

---

## 💾 Backup & Restore System

Moving to a new machine? Take your environment with you.

### Export Configuration

Creates a timestamped `.tar.gz` containing your package lists, VSCodium extensions, and dotfiles (`.bashrc`, `.zshrc`, etc.).

```bash
./scripts/export-config.sh
# Output: ~/fedora-backups/fedora_dev_backup_YYYYMMDD_HHMMSS.tar.gz

```

### Restore Configuration

Re-hydrates a fresh system from a backup file. Safe to run—it backs up existing files before overwriting.

```bash
./scripts/restore-config.sh <path_to_backup.tar.gz>

```

---

## 📂 Project Structure

```text
fedora-dev-setup/
├── bootstrap-fedora.sh      # Main Entry Point (Interactive)
├── scripts/
│   ├── 00-system-base.sh    # Core (DNF, Git, Repos)
│   ├── 10-python-dev.sh     # Python (uv, pipx)
│   ├── 20-vscodium.sh       # IDE Setup
│   ├── 25-setup-zsh.sh      # Shell Configuration
│   ├── 30-gpu-setup.sh      # Hardware Drivers
│   ├── 31-hardware-opt.sh   # Power Management
│   ├── 40-languages.sh      # Node, Go, Rust
│   ├── 45-containers.sh     # Docker/Podman
│   ├── 50-desktop-apps.sh   # GUI Apps/Fonts
│   ├── 60-security.sh       # Security Audit (Lynis)
│   ├── 99-validate.sh       # Verification Suite
│   ├── export-config.sh     # Backup Tool
│   └── restore-config.sh    # Restore Tool
└── docs/                    # Architecture Specs

```

---

## 🤝 Contributing

Found a bug? Want to add support for a new tool? PRs are welcome!
Please check [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repo.
2. Create your feature branch (`git checkout -b feature/amazing-feature`).
3. Commit your changes.
4. Open a Pull Request.

---

**License**: MIT
**Author**: KnowOneActual