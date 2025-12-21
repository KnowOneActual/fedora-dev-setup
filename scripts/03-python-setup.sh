#!/bin/bash

################################################################################
# Fedora Python Development Setup - Step 3: Python Environment
# Description: Install and configure Python with pyenv, venv, and pip tools
# Author: Fedora Dev Setup Contributors
# Last Updated: December 2025
################################################################################

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[✗]${NC} $*" >&2
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root (use sudo)"
    exit 1
fi

# Get the actual user (not root)
ACTUAL_USER="${SUDO_USER:-$(whoami)}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)
ACTUAL_UID=$(id -u $ACTUAL_USER)

log_info "Setting up Python environment for user: $ACTUAL_USER"

################################################################################
# Step 1: Install Python and Build Dependencies
################################################################################

log_info "Installing Python and build dependencies..."

# Install system Python and related packages
dnf install -y \
    python3 \
    python3-devel \
    python3-pip \
    python3-virtualenv \
    python3-wheel \
    python3-setuptools

log_success "System Python installed"

################################################################################
# Step 2: Install and Configure pyenv
################################################################################

log_info "Installing pyenv for Python version management..."

PYENV_ROOT="$ACTUAL_HOME/.pyenv"

# Clone pyenv if not already installed
if [[ ! -d "$PYENV_ROOT" ]]; then
    sudo -u $ACTUAL_USER git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
    log_success "pyenv installed to $PYENV_ROOT"
else
    log_info "pyenv already installed at $PYENV_ROOT"
fi

# Update pyenv
sudo -u $ACTUAL_USER git -C "$PYENV_ROOT" pull 2>/dev/null || true

# Install pyenv-virtualenv plugin for easier virtual environment management
PYENV_VIRTUALENV="$PYENV_ROOT/plugins/pyenv-virtualenv"
if [[ ! -d "$PYENV_VIRTUALENV" ]]; then
    log_info "Installing pyenv-virtualenv plugin..."
    sudo -u $ACTUAL_USER git clone https://github.com/pyenv/pyenv-virtualenv.git "$PYENV_VIRTUALENV"
    log_success "pyenv-virtualenv plugin installed"
fi

################################################################################
# Step 3: Configure Shell for pyenv
################################################################################

log_info "Configuring shell for pyenv..."

# Determine shell configuration file
if [[ -f "$ACTUAL_HOME/.bashrc" ]]; then
    SHELL_RC="$ACTUAL_HOME/.bashrc"
else
    SHELL_RC="$ACTUAL_HOME/.bashrc"
fi

# Add pyenv initialization to bashrc if not already present
if ! grep -q 'pyenv init' "$SHELL_RC"; then
    cat >> "$SHELL_RC" << 'EOF'

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
EOF
    chown $ACTUAL_USER:$ACTUAL_USER "$SHELL_RC"
    log_success "pyenv initialization added to $SHELL_RC"
else
    log_info "pyenv already configured in shell"
fi

################################################################################
# Step 4: Install Python Versions
################################################################################

log_info "Building Python versions (this may take several minutes)..."

# Determine which Python versions to install
PYTHON_VERSIONS=${PYTHON_VERSIONS:-"3.10 3.11 3.12"}

for VERSION in $PYTHON_VERSIONS; do
    # Find latest patch version
    LATEST_VERSION=$(sudo -u $ACTUAL_USER "$PYENV_ROOT/bin/pyenv" install --list | grep "^\s*$VERSION" | tail -1 | tr -d ' ')
    
    if [[ -n "$LATEST_VERSION" ]]; then
        if ! sudo -u $ACTUAL_USER "$PYENV_ROOT/bin/pyenv" versions | grep -q "$LATEST_VERSION"; then
            log_info "Installing Python $LATEST_VERSION..."
            sudo -u $ACTUAL_USER "$PYENV_ROOT/bin/pyenv" install "$LATEST_VERSION"
            log_success "Python $LATEST_VERSION installed"
        else
            log_info "Python $LATEST_VERSION already installed"
        fi
    fi
done

# Set global Python version (use latest 3.12)
LATEST_PYTHON=$(sudo -u $ACTUAL_USER "$PYENV_ROOT/bin/pyenv" versions | grep '3.12' | head -1 | awk '{print $1}')
if [[ -n "$LATEST_PYTHON" ]]; then
    sudo -u $ACTUAL_USER "$PYENV_ROOT/bin/pyenv" global $LATEST_PYTHON
    log_success "Global Python version set to $LATEST_PYTHON"
fi

################################################################################
# Step 5: Upgrade pip and Install Python Tools
################################################################################

log_info "Upgrading pip and installing Python development tools..."

# Get the python executable for the current user
export PYENV_ROOT="$ACTUAL_HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# Initialize pyenv for this script
eval "$(sudo -u $ACTUAL_USER $PYENV_ROOT/bin/pyenv init -)"

PIP_TOOLS=(
    "pip"           # Package manager (upgrade)
    "setuptools"    # Package building tools
    "wheel"         # Wheel package format
    "virtualenv"    # Virtual environment tool
    "pipx"          # Install Python tools in isolated environments
    "poetry"        # Modern Python dependency management
    "black"         # Code formatter
    "flake8"        # Linter
    "pylint"        # Code analyzer
    "pytest"        # Testing framework
    "pytest-cov"    # Test coverage
    "mypy"          # Type checker
    "isort"         # Import sorter
    "autopep8"      # Code formatter
    "ipython"       # Enhanced Python shell
    "jupyter"       # Jupyter notebooks
    "requests"      # HTTP library
    "python-dotenv" # .env file management
)

for tool in "${PIP_TOOLS[@]}"; do
    log_info "Installing pip tool: $tool"
    if sudo -u $ACTUAL_USER python3 -m pip install --upgrade "$tool" 2>/dev/null; then
        log_success "Installed: $tool"
    else
        log_warning "Could not install: $tool"
    fi
done

################################################################################
# Step 6: Create Development Directory Structure
################################################################################

log_info "Creating development directory structure..."

DEV_DIRS=(
    "$ACTUAL_HOME/dev"
    "$ACTUAL_HOME/dev/projects"
    "$ACTUAL_HOME/dev/scripts"
    "$ACTUAL_HOME/dev/experiments"
)

for dir in "${DEV_DIRS[@]}"; do
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        chown $ACTUAL_USER:$ACTUAL_USER "$dir"
        log_success "Created: $dir"
    else
        log_info "Directory already exists: $dir"
    fi
done

################################################################################
# Step 7: Create Example Virtual Environment
################################################################################

log_info "Creating example Python virtual environment..."

EXAMPLE_VENV="$ACTUAL_HOME/dev/.venv-example"

if [[ ! -d "$EXAMPLE_VENV" ]]; then
    sudo -u $ACTUAL_USER python3 -m venv "$EXAMPLE_VENV"
    log_success "Example virtual environment created at $EXAMPLE_VENV"
    echo ""
    echo "To activate this environment:"
    echo "  source $EXAMPLE_VENV/bin/activate"
    echo ""
else
    log_info "Example virtual environment already exists"
fi

################################################################################
# Step 8: Display Python Configuration
################################################################################

echo ""
log_success "Python setup complete!"
echo ""
log_info "Python installation summary:"
echo ""
sudo -u $ACTUAL_USER python3 --version
sudo -u $ACTUAL_USER python3 -m pip --version
echo ""
log_info "Installed Python versions (via pyenv):"
sudo -u $ACTUAL_USER $PYENV_ROOT/bin/pyenv versions 2>/dev/null || echo "  (pyenv not yet available in current shell)"
echo ""

################################################################################
# Summary
################################################################################

echo "Next steps:"
echo "  1. Start a new shell to load pyenv: exec \$SHELL"
echo "  2. Verify Python setup: python3 --version"
echo "  3. Run: bash scripts/04-vscodium-setup.sh"
echo "  4. Then: bash scripts/05-dev-tools.sh"
echo ""
log_info "For detailed information, see docs/SETUP_GUIDE.md"
echo ""
