# Fedora Python Development Environment Setup

A comprehensive, reproducible setup guide for configuring Fedora as a Python development environment with VSCodium. Designed for quick redeployment across multiple machines and backup configurations.

## 📋 Features

- ✅ **Reproducible Setup**: Automate everything with shell scripts for consistency across machines
- ✅ **Python 3 Ready**: Latest Python with virtual environment support (pyenv, venv)
- ✅ **VSCodium Integration**: Open-source Visual Studio Code alternative pre-configured for Python
- ✅ **Git Configuration**: Pre-setup Git with your GitHub credentials
- ✅ **Development Tools**: Essential CLI tools (curl, wget, git, htop, tmux, neovim, etc.)
- ✅ **Package Management**: DNF with optimizations for faster package installation
- ✅ **System Backup**: Automated backup/restore scripts for configuration portability
- ✅ **Hardware Agnostic**: Tested on common laptop configurations (Intel/AMD)

## 🚀 Quick Start

### Prerequisites

- Fresh Fedora 40+ installation (or existing Fedora system)
- Internet connection
- ~5-10 GB disk space for development tools
- Sudo access required

### One-Line Installation

```bash
# Clone the repository
git clone https://github.com/KnowOneActual/fedora-dev-setup.git
cd fedora-dev-setup

# Run the main setup script
bash scripts/01-initial-setup.sh
```

### Step-by-Step Setup

Follow the numbered scripts in order for best results:

1. **[01-initial-setup.sh](scripts/01-initial-setup.sh)** - System updates, DNF optimization, essential packages
2. **[02-git-config.sh](scripts/02-git-config.sh)** - Git user configuration and SSH keys
3. **[03-python-setup.sh](scripts/03-python-setup.sh)** - Python environment (pyenv, virtual environments, pip tools)
4. **[04-vscodium-setup.sh](scripts/04-vscodium-setup.sh)** - VSCodium installation and Python extension configuration
5. **[05-dev-tools.sh](scripts/05-dev-tools.sh)** - Additional development tools and utilities
6. **[06-config-backup.sh](scripts/06-config-backup.sh)** - Backup/restore your configurations

See [SETUP_GUIDE.md](docs/SETUP_GUIDE.md) for detailed step-by-step instructions.

## 📁 Directory Structure

```
fedora-dev-setup/
├── scripts/                    # Automated setup scripts (numbered for execution order)
│   ├── 01-initial-setup.sh
│   ├── 02-git-config.sh
│   ├── 03-python-setup.sh
│   ├── 04-vscodium-setup.sh
│   ├── 05-dev-tools.sh
│   └── 06-config-backup.sh
├── configs/                    # Configuration files
│   ├── .vscode/
│   │   ├── settings.json       # VSCodium default settings
│   │   └── extensions.json     # Recommended extensions
│   ├── .bashrc                 # Bash configuration
│   ├── .gitconfig              # Git configuration template
│   └── dnf.conf                # DNF package manager config
├── docs/                       # Documentation
│   ├── SETUP_GUIDE.md          # Detailed step-by-step guide
│   ├── TROUBLESHOOTING.md      # Common issues and solutions
│   └── HARDWARE_NOTES.md       # Hardware-specific configuration
├── backup/                     # Backup and restore utilities
│   └── backup-configs.sh       # Backup your development environment
├── tests/                      # Verification scripts
│   └── verify-setup.sh         # Test that everything is configured correctly
├── WARP.md                     # Project work log and improvements
├── CHANGELOG.md                # Version history
└── README.md                   # This file
```

## 🔧 Configuration Options

Before running the setup, you can customize behavior with environment variables:

```bash
# Custom Python version
export PYTHON_VERSION="3.12"

# Custom VSCodium extensions
export INSTALL_EXTENSIONS=true

# Skip interactive prompts
export AUTO_APPROVE=true

# Dry run (show what would happen without executing)
export DRY_RUN=true

bash scripts/01-initial-setup.sh
```

## 📚 Documentation

- **[SETUP_GUIDE.md](docs/SETUP_GUIDE.md)** - Complete step-by-step walkthrough with explanations
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and how to resolve them
- **[HARDWARE_NOTES.md](docs/HARDWARE_NOTES.md)** - Hardware-specific considerations (Intel/AMD, WiFi, GPU)
- **[WARP.md](WARP.md)** - Project development log and optimization notes

## 💾 Backup & Restore

To backup your entire development environment:

```bash
bash scripts/06-config-backup.sh --backup
```

To restore on a new machine:

```bash
bash scripts/06-config-backup.sh --restore /path/to/backup.tar.gz
```

## ✅ Verification

After setup, verify everything is installed correctly:

```bash
bash tests/verify-setup.sh
```

## 🛠️ System Requirements

| Requirement | Minimum | Recommended |
|------------|---------|-------------|
| Fedora Version | 39 | 40+ |
| Disk Space | 10 GB | 20 GB |
| RAM | 4 GB | 8+ GB |
| Processor | Any | Recent (Intel/AMD) |
| Internet | Required | Required |

## 🖥️ Tested Hardware

- ✅ Dell XPS 13 (Intel, 8GB RAM)
- ✅ Lenovo ThinkPad (Intel, 16GB RAM)
- ✅ Framework Laptop (AMD, 16GB RAM)
- ✅ Generic Intel i5 laptops
- ✅ Generic AMD Ryzen laptops

*Have you tested on other hardware? Please submit issues with your configuration!*

## 🤝 Contributing

Improvements, bug reports, and suggestions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.

## 🆘 Support

- 📖 Check [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) first
- 🐛 Open an [issue](https://github.com/KnowOneActual/fedora-dev-setup/issues) on GitHub
- 💬 Start a [discussion](https://github.com/KnowOneActual/fedora-dev-setup/discussions)

## 📊 Status

- Latest Fedora Version: **40**
- Python Support: **3.10, 3.11, 3.12**
- VSCodium: **Latest**
- Last Updated: **December 2025**
