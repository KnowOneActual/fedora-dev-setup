#!/bin/bash

################################################################################
# Fedora Python Development Setup - Step 5: Additional Development Tools
# Description: Install optional but useful development utilities
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

read_yes_no() {
    local prompt="$1"
    local default="${2:-y}"
    
    echo -n -e "${BLUE}?​${NC} $prompt [${YELLOW}${default^^}${NC}]: "
    read -r response
    
    if [[ -z "$response" ]]; then
        response="$default"
    fi
    
    [[ "${response:0:1}" == "y" || "${response:0:1}" == "Y" ]]
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root (use sudo)"
    exit 1
fi

log_info "Setting up additional development tools..."

################################################################################
# Optional: Development Utilities
################################################################################

echo ""
log_info "Optional Development Tools"
echo ""

################################################################################
# Docker & Podman
################################################################################

if read_yes_no "Install Docker Desktop (or Podman for containers)?" "y"; then
    log_info "Installing container tools..."
    
    # Podman is lighter and already installed; offer Docker as optional
    if dnf install -y docker; then
        systemctl enable docker
        systemctl start docker
        log_success "Docker installed"
        
        ACTUAL_USER="${SUDO_USER:-$(whoami)}"
        usermod -aG docker $ACTUAL_USER
        log_success "User $ACTUAL_USER added to docker group"
    else
        log_warning "Docker installation failed; Podman may be used instead"
    fi
else
    log_info "Skipped Docker installation"
fi

################################################################################
# Node.js (optional, useful for JavaScript projects)
################################################################################

if read_yes_no "Install Node.js and npm (useful for web development)?" "n"; then
    log_info "Installing Node.js..."
    
    if dnf install -y nodejs npm; then
        log_success "Node.js and npm installed"
        node --version
        npm --version
    else
        log_warning "Node.js installation failed"
    fi
else
    log_info "Skipped Node.js installation"
fi

################################################################################
# PostgreSQL Client (useful for database work)
################################################################################

if read_yes_no "Install PostgreSQL client tools?" "n"; then
    log_info "Installing PostgreSQL client..."
    
    if dnf install -y postgresql; then
        log_success "PostgreSQL client installed"
    else
        log_warning "PostgreSQL client installation failed"
    fi
else
    log_info "Skipped PostgreSQL client installation"
fi

################################################################################
# Redis CLI (useful for Redis development)
################################################################################

if read_yes_no "Install Redis CLI?" "n"; then
    log_info "Installing Redis CLI..."
    
    if dnf install -y redis; then
        log_success "Redis CLI installed"
    else
        log_warning "Redis CLI installation failed"
    fi
else
    log_info "Skipped Redis CLI installation"
fi

################################################################################
# SQLite Tools
################################################################################

if read_yes_no "Install SQLite tools?" "y"; then
    log_info "Installing SQLite..."
    
    if dnf install -y sqlite; then
        log_success "SQLite installed"
    else
        log_warning "SQLite installation failed"
    fi
else
    log_info "Skipped SQLite installation"
fi

################################################################################
# Development Utilities
################################################################################

log_info "Installing development utilities..."

# These are lightweight and generally useful
UTILITIES=(
    "the_silver_searcher"    # ag - fast text search
    "fzf"                     # Fuzzy finder
    "entr"                    # File watcher (runs commands on file changes)
    "shellcheck"              # Shell script linter
    "yamllint"                # YAML linter
    "pre-commit"              # Git hooks framework
    "direnv"                  # Environment management
    "lazygit"                 # TUI git client
    "tmuxp"                   # Tmux session manager
)

for tool in "${UTILITIES[@]}"; do
    if dnf install -y "$tool" 2>/dev/null; then
        log_success "Installed: $tool"
    else
        log_warning "Could not install: $tool"
    fi
done

################################################################################
# Python Development Utilities (user-level)
################################################################################

ACTUAL_USER="${SUDO_USER:-$(whoami)}"

log_info "Installing Python development utilities for user $ACTUAL_USER..."

PYTHON_TOOLS=(
    "tox"                     # Python testing automation
    "pre-commit"              # Git hooks for code quality
    "cookiecutter"            # Project templates
    "pdoc"                     # API documentation generator
    "sphinx"                   # Documentation generator
    "sphinx_rtd_theme"        # ReadTheDocs theme for Sphinx
)

for tool in "${PYTHON_TOOLS[@]}"; do
    if sudo -u $ACTUAL_USER pip install --user "$tool" 2>/dev/null; then
        log_success "Installed: $tool"
    else
        log_warning "Could not install Python tool: $tool"
    fi
done

################################################################################
# Create Development Scripts Directory
################################################################################

log_info "Creating useful development scripts..."

ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)
SCRIPTS_DIR="$ACTUAL_HOME/dev/scripts"

mkdir -p "$SCRIPTS_DIR"

# Create a Python project template script
sudo -u $ACTUAL_USER cat > "$SCRIPTS_DIR/new-python-project.sh" << 'EOF'
#!/bin/bash
# Create a new Python project with standard structure

if [[ -z "$1" ]]; then
    echo "Usage: $0 <project-name>"
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_DIR="$(pwd)/$PROJECT_NAME"

echo "Creating Python project: $PROJECT_NAME"

mkdir -p "$PROJECT_DIR"/{src,tests,docs}
cd "$PROJECT_DIR"

# Create main package directory
mkdir -p "$PROJECT_NAME"
touch "$PROJECT_NAME/__init__.py"

# Create README
cat > README.md << 'READMEEOF'
# $PROJECT_NAME

A Python project.

## Installation

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Usage

TODO

## Testing

```bash
pytest tests/
```
READMEEOF

# Create requirements.txt
cat > requirements.txt << 'REQEOF'
pytest>=7.0
pytest-cov>=4.0
black>=22.0
flake8>=4.0
pylint>=2.0
mypy>=0.990
isort>=5.0
REQEOF

# Create setup.py
cat > setup.py << 'SETUPEOF'
from setuptools import setup, find_packages

setup(
    name="$PROJECT_NAME",
    version="0.1.0",
    description="A Python project",
    author="Your Name",
    author_email="your.email@example.com",
    packages=find_packages(),
    install_requires=[
        # Add your dependencies here
    ],
    classifiers=[
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
    ],
)
SETUPEOF

# Create .gitignore
cat > .gitignore << 'GITEOF'
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
.venv/
venv/
ENV/
.vscode/
.idea/
.DS_Store
.pytest_cache/
.mypy_cache/
.coverage
htmlcov/
GITEOF

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

echo "Project $PROJECT_NAME created successfully!"
echo "To activate the virtual environment: source $PROJECT_DIR/.venv/bin/activate"
EOF

chmod +x "$SCRIPTS_DIR/new-python-project.sh"
log_success "Created: new-python-project.sh"

# Create a virtual environment manager script
sudo -u $ACTUAL_USER cat > "$SCRIPTS_DIR/venv-manager.sh" << 'EOF'
#!/bin/bash
# Simple virtual environment manager

VENV_NAME="${1:-.venv}"
VENV_ACTION="${2:-create}"

case $VENV_ACTION in
    create)
        echo "Creating virtual environment: $VENV_NAME"
        python3 -m venv "$VENV_NAME"
        source "$VENV_NAME/bin/activate"
        pip install --upgrade pip setuptools wheel
        echo "Virtual environment created and activated!"
        ;;
    activate)
        echo "Activating virtual environment: $VENV_NAME"
        source "$VENV_NAME/bin/activate"
        ;;
    remove)
        echo "Removing virtual environment: $VENV_NAME"
        rm -rf "$VENV_NAME"
        echo "Virtual environment removed!"
        ;;
    *)
        echo "Usage: $0 [venv-name] [create|activate|remove]"
        exit 1
        ;;
esac
EOF

chmod +x "$SCRIPTS_DIR/venv-manager.sh"
log_success "Created: venv-manager.sh"

################################################################################
# Create bash aliases for common development tasks
################################################################################

log_info "Adding development aliases to shell configuration..."

BASHRC="$ACTUAL_HOME/.bashrc"

if ! grep -q "# Python Development Aliases" "$BASHRC"; then
    cat >> "$BASHRC" << 'EOF'

# Python Development Aliases
alias py='python3'
alias venv='python3 -m venv'
alias activate='source .venv/bin/activate'
alias pip-update='pip install --upgrade pip setuptools wheel'
alias pip-freeze='pip freeze > requirements.txt'
alias lint='pylint *.py'
alias format='black .'
alias test='pytest -v'
alias test-coverage='pytest --cov=. --cov-report=html'
alias install-deps='pip install -r requirements.txt'
EOF
    chown $ACTUAL_USER:$ACTUAL_USER "$BASHRC"
    log_success "Development aliases added to .bashrc"
fi

################################################################################
# Summary
################################################################################

echo ""
log_success "Additional development tools setup complete!"
echo ""
log_info "Development scripts available in: $SCRIPTS_DIR"
echo ""
log_info "Useful development aliases:"
echo "  py              - Shortcut for python3"
echo "  activate        - Activate .venv virtual environment"
echo "  pip-freeze      - Save dependencies to requirements.txt"
echo "  lint            - Run pylint"
echo "  format          - Format code with black"
echo "  test            - Run pytest tests"
echo "  test-coverage   - Run tests with coverage report"
echo ""
echo "Next step:"
echo "  Run: bash scripts/06-config-backup.sh"
echo ""
log_info "For detailed information, see docs/SETUP_GUIDE.md"
echo ""
