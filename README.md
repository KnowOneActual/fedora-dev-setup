# 🚀 Fedora Development Workstation Setup

![Version](https://img.shields.io/badge/version-1.2.1-blue?style=for-the-badge)
![Fedora](https://img.shields.io/badge/Fedora-41-blue?logo=fedora&logoColor=white&style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Build Status](https://img.shields.io/badge/build-passing-brightgreen?style=for-the-badge)

**Turn a fresh Fedora installation into a battle-ready development workstation in minutes.**

This automated provisioning suite transforms a stock Fedora OS into a professional environment. It intelligently detects your hardware (GPU/Chassis), installs a modern multi-language stack (Python, Rust, Go, Node), configures your shell, and sets up robust backup mechanisms.

---

## ✨ Features

### 🧠 Hardware Intelligence
* **GPU Auto-Detection**: Automatically identifies NVIDIA or AMD GPUs and installs the correct drivers (CUDA/ROCm).
* **Chassis Optimization**: Detects if you are on a **Laptop** (installs TLP/Battery savers) or **Desktop** (enables Performance governors).

### 🛠️ The Ultimate Dev Stack
* **Python Powerhouse**: Sets up `uv` (blazing fast installer) and `pipx` for isolated tools (`ruff`, `black`, `mypy`, `pytest`).
* **Polyglot Ready**: Installs complete toolchains for **Node.js** (npm/yarn), **Go**, and **Rust** (via rustup).
* **IDE Pre-Configured**: Installs **VSCodium** (telemetry-free VS Code) with a curated list of extensions and sane defaults (Format on Save, GitLens, ErrorLens).

### 🛡️ Safety & Reliability
* **Idempotent Design**: Run the script as many times as you want; it skips what is already done.
* **Dry Run Mode**: Preview every change without touching your system using `--dry-run`.
* **Backup & Restore**: Snapshot your entire config (dotfiles, extensions, packages) to a portable archive.

### 💻 Power User Shell
* **Zsh Configured**: Installs **Oh My Zsh** with syntax highlighting and autosuggestions out of the box.
* **Core Utils**: `fzf`, `ripgrep`, `bat`, `htop`, `tmux`, and `direnv`.

---

## 🚀 Quick Start

### 1. Installation
Clone the repo and run the bootstrap script. It will handle the rest.

```bash
git clone [https://github.com/KnowOneActual/fedora-dev-setup.git](https://github.com/KnowOneActual/fedora-dev-setup.git)
cd fedora-dev-setup

# Run the full installer
sudo ./bootstrap-fedora.sh --install

```

### 2. Validation

Verify that everything is installed correctly:

```bash
# Runs a suite of checks on binaries, paths, and configs
sudo ./bootstrap-fedora.sh --validate

```

### 3. Dry Run (Test Mode)

Curious what it does? See the plan without making changes:

```bash
./bootstrap-fedora.sh --dry-run

```

---

## 💾 Backup & Restore System

Moving to a new machine? Take your environment with you.

### Export Configuration

Creates a timestamped `.tar.gz` containing your package lists, VSCodium extensions, and dotfiles (`.bashrc`, `.zshrc`, `.gitconfig`, etc.).

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
├── bootstrap-fedora.sh      # Main Entry Point
├── scripts/
│   ├── 00-system-base.sh    # Core (DNF, Git, Repos)
│   ├── 10-python-dev.sh     # Python (uv, pipx)
│   ├── 20-vscodium.sh       # IDE Setup
│   ├── 25-setup-zsh.sh      # Shell Configuration
│   ├── 30-gpu-setup.sh      # Hardware Drivers (HAL)
│   ├── 31-hardware-opt.sh   # Power Management
│   ├── 40-languages.sh      # Node, Go, Rust
│   ├── 99-validate.sh       # Verification Suite
│   ├── export-config.sh     # Backup Tool
│   └── restore-config.sh    # Restore Tool
└── docs/                    # Architecture Specs

```

---

## 🤝 Contributing

Found a bug? Want to add support for a new tool? PRs are welcome!
Please check [CONTRIBUTING.md](https://www.google.com/search?q=CONTRIBUTING.md) for guidelines.

1. Fork the repo.
2. Create your feature branch (`git checkout -b feature/amazing-feature`).
3. Commit your changes (`git commit -m 'feat: add amazing feature'`).
4. Push to the branch (`git push origin feature/amazing-feature`).
5. Open a Pull Request.

---

**License**: MIT

**Author**: KnowOneActual
