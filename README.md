# Fedora Python Development Environment Setup

![Fedora](https://img.shields.io/badge/Fedora-40+-blue?logo=fedora&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12+-yellow?logo=python&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Early%20Alpha-orange)

**⚠️ DEVELOPMENT STATUS: EARLY ALPHA**
This project is currently under active refactoring. Testing is currently limited to syntax validation and dry-runs on macOS. Full end-to-end testing on a native Fedora machine is pending. Use with caution or stick to `--dry-run` mode to preview changes.

A comprehensive, reproducible setup guide for configuring Fedora as a professional Python development environment. Designed for consistency across machines using a modular, idempotent architecture.

## 📋 Features

- ✅ **One-Command Setup**: Orchestrated via `bootstrap-fedora.sh`
- ✅ **Idempotent**: Safe to run multiple times; checks before installing
- ✅ **Modern Python**: `uv` (fast installer), `pipx` (isolated tools), and Python 3.12+
- ✅ **VSCodium**: Telemetry-free VS Code with Python, Ruff, and GitLens pre-configured
- ✅ **System Base**: Optimized DNF, RPM Fusion, Zsh, Tmux, and essential build tools
- ✅ **Observability**: Detailed, color-coded logging with timestamped history
- ✅ **Dry Run Mode**: Preview all actions without modifying your system

## 🚀 Quick Start

### Prerequisites

- Fedora Workstation 40+
- Sudo access
- Internet connection

### Installation

```bash
# 1. Clone the repository
git clone [https://github.com/KnowOneActual/fedora-dev-setup.git](https://github.com/KnowOneActual/fedora-dev-setup.git)
cd fedora-dev-setup

# 2. (Optional) Run a safe dry-run to see what will happen
./bootstrap-fedora.sh --dry-run

# 3. Run the full installer
sudo ./bootstrap-fedora.sh --install

```

### Verification Only

If you just want to check if your system meets the requirements or if a previous install worked:

```bash
./bootstrap-fedora.sh --validate

```

## 📁 Directory Structure

```text
fedora-dev-setup/
├── bootstrap-fedora.sh      # Main entry point (Run this!)
├── logs/                    # Timestamped installation logs
├── scripts/
│   ├── 00-system-base.sh    # DNF, Repos, Base Tools
│   ├── 10-python-dev.sh     # Python, uv, pipx, Global Tools
│   ├── 20-vscodium.sh       # Editor, Extensions, Settings
│   ├── 99-validate.sh       # System Verification
│   └── lib/                 # Shared Libraries
│       ├── logging.sh       # Color output & log files
│       └── utils.sh         # Helper functions
├── docs/
│   ├── SETUP_SPEC.md        # Technical specifications
│   ├── SETUP_GUIDE.md       # Detailed walkthrough
│   └── ROADMAP.md           # Development plans
└── README.md                # This file

```

## 🔧 What Gets Installed

| Phase | Components |
| --- | --- |
| **System** | DNF optimizations, RPM Fusion, GCC, Make, Git, Zsh, Tmux, Htop, Riplgrep, FD |
| **Python** | Python 3.12, `uv` (installer), `pipx` (tool manager) |
| **Tools** | Black, Ruff, Mypy, Pytest, IPython (all installed via pipx) |
| **Editor** | VSCodium with Python, Ruff, and GitLens extensions |

## 🤝 Contributing

This project is in active development. We welcome bug reports and PRs!

1. Fork the repo
2. Create a feature branch
3. Submit a Pull Request

## 📝 License

Distributed under the MIT License. See [LICENSE](https://www.google.com/search?q=LICENSE) for details.


## 📊 Status

- Latest Fedora Version: **40**
- Python Support: **3.10, 3.11, 3.12**
- VSCodium: **Latest**
- Last Updated: **December 2025**
