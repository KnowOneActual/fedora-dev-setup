# Comprehensive Fedora Python Development Setup Guide

**Last Updated:** December 2025

**Target Audience:** Developers with some Linux experience, coming from Debian or other distributions

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Step 1: Initial System Setup](#step-1-initial-system-setup)
4. [Step 2: Git Configuration](#step-2-git-configuration)
5. [Step 3: Python Environment](#step-3-python-environment)
6. [Step 4: VSCodium Installation](#step-4-vscodium-installation)
7. [Step 5: Additional Tools](#step-5-additional-tools)
8. [Verification & Testing](#verification--testing)
9. [Backup & Restore](#backup--restore)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### System Requirements

- **Fedora 40+** (39 works but may have package availability issues)
- **RAM:** Minimum 4GB (8GB+ recommended)
- **Disk Space:** ~15-20GB for all tools and Python versions
- **Internet Connection:** Required for package downloads
- **Sudo Access:** Required for system-wide installations

### Hardware Compatibility

✅ **Tested and Working:**
- Intel Core i5/i7/i9 processors
- AMD Ryzen processors
- Framework laptops
- Dell XPS series
- Lenovo ThinkPad series

### What You'll Get

- Latest Python versions (3.10, 3.11, 3.12) via pyenv
- VSCodium with Python extensions pre-configured
- Git setup with SSH keys
- Development tools: Black, Pylint, Pytest, MyPy, and more
- Pre-configured Python virtual environment system
- Reproducible backups for quick redeployment

---

## Quick Start

### For the Impatient (10 minutes)

```bash
# 1. Clone the setup repository
git clone https://github.com/KnowOneActual/fedora-dev-setup.git
cd fedora-dev-setup

# 2. Run all setup scripts in sequence
sudo bash scripts/01-initial-setup.sh
sudo bash scripts/02-git-config.sh
sudo bash scripts/03-python-setup.sh
sudo bash scripts/04-vscodium-setup.sh
bash scripts/05-dev-tools.sh

# 3. Start a new shell to load changes
exec $SHELL

# 4. Verify everything works
bash tests/verify-setup.sh
```

### For the Thorough (30-45 minutes)

Follow the detailed steps below to understand what's being installed and why.

---

## Step 1: Initial System Setup

### What This Does

1. Optimizes DNF (package manager) for speed
2. Updates all system packages
3. Installs essential development tools (gcc, git, etc.)
4. Configures RPM Fusion repositories
5. Checks for SSH keys

### Run the Script

```bash
sudo bash scripts/01-initial-setup.sh
```

### What to Expect

```
[INFO] Detected Fedora version: 40
[INFO] Optimizing DNF package manager configuration...
[✓] DNF optimized for better performance
[INFO] Updating system packages (this may take a few minutes)...
[✓] System packages updated
[INFO] Installing essential development packages...
[✓] Installed: gcc
[✓] Installed: git
... (more packages)
```

### Duration

⏱️ **5-15 minutes** (depending on internet speed and existing packages)

---

## Step 2: Git Configuration

### What This Does

1. Configures Git with your user information
2. Sets up SSH keys for GitHub authentication
3. Configures Git preferences (rebase, color, etc.)
4. Authenticates with GitHub CLI

### Run the Script

```bash
sudo bash scripts/02-git-config.sh
```

### Interactive Prompts

You'll be asked for:

```
? Git user name [your-username]: John Doe
? Git user email: john@example.com
? SSH key email (for identification): john@example.com
```

### SSH Key Setup

If you don't have an SSH key, the script will:

1. Generate a new Ed25519 SSH key pair
2. Save it to `~/.ssh/id_ed25519`
3. Display your public key

**Important:** Add your public key to GitHub:

1. Copy the output from: `cat ~/.ssh/id_ed25519.pub`
2. Go to [GitHub SSH Settings](https://github.com/settings/keys)
3. Click "New SSH key"
4. Paste your key

### Verify Git Setup

```bash
git config --global --list | grep user
git config --global --list | grep init
```

### Duration

⏱️ **2-5 minutes**

---

## Step 3: Python Environment

### What This Does

1. Installs system Python 3
2. Installs pyenv for Python version management
3. Builds and installs Python 3.10, 3.11, and 3.12
4. Sets up Python development tools
5. Creates example virtual environments

### Run the Script

```bash
sudo bash scripts/03-python-setup.sh
```

### What Gets Installed

**Python Versions:**
- Python 3.10 (security patches)
- Python 3.11 (stable, widely used)
- Python 3.12 (latest, set as default)

**Development Tools:**
- Black (code formatter)
- Pylint (linter)
- Flake8 (style checker)
- MyPy (type checker)
- Pytest (testing framework)
- Poetry (dependency manager)
- Jupyter (notebooks)
- And more...

### Verify Python Installation

```bash
# After script completes and you start a new shell
python3 --version

# Check available Python versions
~/.pyenv/bin/pyenv versions

# Install additional tools via pip
pip install --upgrade pip
pip install numpy pandas scipy  # example
```

### Create a Virtual Environment

```bash
# Using venv (built-in)
cd ~/dev/projects/my-project
python3 -m venv .venv
source .venv/bin/activate

# Using pyenv-virtualenv (recommended)
pyenv virtualenv 3.12 my-project
pyenv activate my-project
```

### Duration

⏱️ **20-40 minutes** (Python compilation takes time on first run)

---

## Step 4: VSCodium Installation

### What This Does

1. Adds VSCodium repository
2. Installs VSCodium (open-source VS Code)
3. Installs Python extensions
4. Configures Python development settings
5. Sets up debugging and testing configurations

### Run the Script

```bash
sudo bash scripts/04-vscodium-setup.sh
```

### Installed Extensions

| Extension | Purpose |
|-----------|----------|
| `ms-python.python` | Core Python support |
| `ms-python.vscode-pylance` | Language server, type hints |
| `ms-python.debugpy` | Debugger |
| `charliermarsh.ruff` | Fast linting and formatting |
| `ms-python.black-formatter` | Code formatting |
| `ms-python.isort` | Import sorting |
| `ms-python.mypy-type-checker` | Static type checking |
| `eamodio.gitlens` | Git integration |
| `ms-toolsai.jupyter` | Jupyter notebook support |

### First Launch

```bash
# Start VSCodium
codium

# Or open a specific folder
codium /path/to/project
```

### Recommended Settings

The script pre-configures:

- **Format on Save:** Enabled (Black formatter)
- **Rulers:** 80 and 120 columns (PEP 8 guidelines)
- **Tab Size:** 4 spaces (Python standard)
- **Linters:** Flake8 and Pylint enabled
- **Test Framework:** Pytest configured

### Using VSCodium with Python

1. Open a Python project folder in VSCodium
2. Create/activate a virtual environment:
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   ```
3. VSCodium will detect the virtual environment automatically
4. Start coding! Extensions handle formatting, linting, type checking

### Debugging in VSCodium

```python
# In your Python file, set breakpoints by clicking on the line number
# Then press F5 or click "Run and Debug" to start debugging
```

### Duration

⏱️ **3-5 minutes**

---

## Step 5: Additional Tools

### What This Does

1. Optionally installs Docker/Podman
2. Optionally installs Node.js
3. Optionally installs database tools (PostgreSQL, Redis, SQLite)
4. Installs development utilities
5. Creates helpful bash aliases
6. Adds useful development scripts

### Run the Script

```bash
bash scripts/05-dev-tools.sh
```

The script asks questions for optional tools:

```
? Install Docker Desktop (or Podman for containers)? [Y/n]: y
? Install Node.js and npm (useful for web development)? [Y/n]: n
? Install PostgreSQL client tools? [Y/n]: n
```

### Useful Aliases

After running the script, you can use:

```bash
py              # Shortcut for python3
activate        # Activate .venv
pip-freeze      # Save dependencies
lint            # Run pylint
format          # Format with black
test            # Run pytest
test-coverage   # Run tests with coverage
```

### Development Scripts

Useful scripts are created in `~/dev/scripts/`:

```bash
# Create a new Python project with structure
~/dev/scripts/new-python-project.sh my_app

# Manage virtual environments
~/dev/scripts/venv-manager.sh my_venv create
~/dev/scripts/venv-manager.sh my_venv activate
```

### Duration

⏱️ **2-5 minutes** (depending on which optional tools you install)

---

## Verification & Testing

### Run the Verification Script

```bash
bash tests/verify-setup.sh
```

### Manual Verification

```bash
# Check Fedora version
cat /etc/os-release | grep VERSION_ID

# Check Python
python3 --version
pyenv --version

# Check Git
git --version
git config --global user.name

# Check VSCodium
codium --version

# Check key development tools
black --version
pylint --version
pytest --version
mypy --version

# Check virtual environment
source ~/dev/.venv-example/bin/activate
python --version  # Should be 3.12+
deactivate
```

### Expected Output

```
Fedora Version: 40
Python: Python 3.12.x
Git: git version 2.43.x
VSCodium: 1.95.x
Black: 24.x.x
Pytest: 7.x.x
```

---

## Backup & Restore

### Create a Backup

Before making changes or on a working system:

```bash
bash scripts/06-config-backup.sh --backup
```

This creates a tarball with:
- VSCodium settings
- Git configuration
- Python environments list
- Development directory structure
- Shell configuration

### Restore a Backup

On a fresh Fedora installation:

```bash
# First run steps 1-4 to install everything
sudo bash scripts/01-initial-setup.sh
sudo bash scripts/02-git-config.sh
sudo bash scripts/03-python-setup.sh
sudo bash scripts/04-vscodium-setup.sh

# Then restore your backup
bash scripts/06-config-backup.sh --restore /path/to/backup.tar.gz
```

### What Gets Backed Up

- ✅ VSCodium extensions list
- ✅ Git configuration
- ✅ Shell aliases and configurations
- ✅ Development directory structure
- ✅ Project listings (not the code)
- ❌ Project source code (use Git for this)
- ❌ Virtual environments (recreate with `pip install -r requirements.txt`)

---

## Troubleshooting

### "Command not found" after running scripts

**Solution:** Start a new shell session

```bash
exec $SHELL
# or
bash
# or
source ~/.bashrc
```

### Python from pyenv not available

**Solution:** Ensure pyenv initialization is in your `.bashrc`

```bash
grep -A 2 "pyenv init" ~/.bashrc
# If nothing shows, add it:
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
exec $SHELL
```

### VSCodium can't find Python

**Solution:** Select the correct interpreter in VSCodium

1. Press `Ctrl+Shift+P`
2. Search "Python: Select Interpreter"
3. Choose from `.venv/bin/python` or the global version

### SSH key not working with GitHub

**Solution:** Ensure SSH key is added to ssh-agent

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh -T git@github.com  # Should show: "Hi username!"
```

### DNF/package manager slow

**Solution:** The script already optimized DNF, but you can check:

```bash
cat /etc/dnf/dnf.conf | grep -A 5 "Performance"
```

### Fedora version too old

**Solution:** Upgrade Fedora

```bash
sudo dnf upgrade --refresh
sudo dnf system-upgrade download --releasever=40
sudo dnf system-upgrade reboot
```

See full [Troubleshooting Guide](TROUBLESHOOTING.md) for more issues.

---

## Next Steps

### Start Your First Project

```bash
~/dev/scripts/new-python-project.sh hello-world
cd ~/dev/projects/hello-world

# Open in VSCodium
codium .

# Start coding!
```

### Common Development Tasks

```bash
# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Format code
black .

# Run tests
pytest tests/ -v

# Check types
mypy src/
```

### Learn More

- [Fedora Documentation](https://docs.fedoraproject.org/)
- [Python.org](https://www.python.org/)
- [VSCodium](https://vscodium.com/)
- [pyenv GitHub](https://github.com/pyenv/pyenv)
- [Black Code Formatter](https://black.readthedocs.io/)
- [Pytest](https://docs.pytest.org/)

---

## Support

- 📖 See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- 🐛 Open an [issue](https://github.com/KnowOneActual/fedora-dev-setup/issues) on GitHub
- 💬 Start a [discussion](https://github.com/KnowOneActual/fedora-dev-setup/discussions)
- 🔧 See [HARDWARE_NOTES.md](HARDWARE_NOTES.md) for hardware-specific issues

---

**Happy coding! 🚀**
