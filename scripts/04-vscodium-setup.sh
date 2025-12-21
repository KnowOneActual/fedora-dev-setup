#!/bin/bash

################################################################################
# Fedora Python Development Setup - Step 4: VSCodium Installation
# Description: Install VSCodium and configure Python development extensions
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

read_input() {
    local prompt="$1"
    local default="${2:-n}"
    
    echo -n -e "${BLUE}?​${NC} $prompt [${YELLOW}$default${NC}]: "
    read -r value
    
    if [[ -z "$value" ]]; then
        value="$default"
    fi
    
    echo "$value"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root (use sudo)"
    exit 1
fi

ACTUAL_USER="${SUDO_USER:-$(whoami)}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

log_info "Setting up VSCodium for user: $ACTUAL_USER"

################################################################################
# Step 1: Add VSCodium Repository
################################################################################

log_info "Adding VSCodium repository..."

# Check if running on Fedora
if ! grep -q "Fedora" /etc/os-release; then
    log_error "This script is designed for Fedora. Other distributions may work but are not officially supported."
    exit 1
fi

# Add Microsft's VS Code repository (which includes VSCodium builds for Fedora)
if ! dnf repolist | grep -q "copr:copr.fedorainfracloud.org"; then
    log_info "Adding COPR repository for VSCodium..."
    dnf copr enable -y vscodium-community/vscodium
    log_success "VSCodium COPR repository added"
else
    log_info "COPR repository already configured"
fi

################################################################################
# Step 2: Install VSCodium
################################################################################

log_info "Installing VSCodium..."

if dnf install -y codium; then
    log_success "VSCodium installed"
else
    log_error "Failed to install VSCodium"
    exit 1
fi

################################################################################
# Step 3: Create VSCode Configuration Directory
################################################################################

log_info "Setting up VSCodium user configuration directory..."

VSCODE_DIR="$ACTUAL_HOME/.config/VSCodium/User"

if [[ ! -d "$VSCODE_DIR" ]]; then
    mkdir -p "$VSCODE_DIR"
    chown -R $ACTUAL_USER:$ACTUAL_USER "$ACTUAL_HOME/.config/VSCodium"
    log_success "VSCodium configuration directory created"
fi

################################################################################
# Step 4: Create VSCodium Settings
################################################################################

log_info "Configuring VSCodium settings for Python development..."

SETTINGS_FILE="$VSCODE_DIR/settings.json"

if [[ -f "$SETTINGS_FILE" ]]; then
    log_warning "settings.json already exists. Backing up..."
    cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup.$(date +%s)"
fi

# Create settings.json with Python development configuration
sudo -u $ACTUAL_USER cat > "$SETTINGS_FILE" << 'EOF'
{
    // Editor Configuration
    "editor.formatOnSave": true,
    "editor.formatOnType": true,
    "editor.defaultFormatter": "ms-python.python",
    "editor.rulers": [80, 120],
    "editor.wordWrap": "on",
    "editor.codeActionsOnSave": {
        "source.fixAll.isort": true,
        "source.fixAll.flake8": true
    },
    "editor.insertSpaces": true,
    "editor.tabSize": 4,
    "files.trimTrailingWhitespace": true,
    "files.trimFinalNewlines": true,

    // Python Extension Configuration
    "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "python.linting.flake8Args": ["--max-line-length=120"],
    "python.linting.pylintEnabled": true,
    "python.formatting.provider": "black",
    "python.formatting.blackArgs": ["--line-length", "120"],
    "python.analysis.extraPaths": [],

    // Testing Configuration
    "python.testing.pytestEnabled": true,
    "python.testing.unittestEnabled": false,
    "python.testing.pytestArgs": ["tests", "-v"],

    // General Editor Settings
    "files.exclude": {
        "**/__pycache__": true,
        "**/.pytest_cache": true,
        "**/.mypy_cache": true,
        "**/*.egg-info": true,
        "**/node_modules": true,
        "**/.git": true
    },

    // Extensions Configuration
    "[python]": {
        "editor.defaultFormatter": "ms-python.python",
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
            "source.fixAll.pylint": true,
            "source.fixAll.isort": true
        }
    },

    // Terminal Configuration
    "terminal.integrated.defaultProfile.linux": "bash",
    "terminal.integrated.enableMultiLinePasteWarning": false,

    // Git Configuration
    "git.ignoreLimitWarning": true,

    // Appearance
    "workbench.colorTheme": "Default Dark Modern",
    "editor.minimap.enabled": true,
    "breadcrumbs.enabled": true
}
EOF

chown $ACTUAL_USER:$ACTUAL_USER "$SETTINGS_FILE"
log_success "VSCodium settings configured"

################################################################################
# Step 5: Install Recommended Extensions
################################################################################

log_info "Installing Python development extensions for VSCodium..."

# Extensions to install
EXTENSIONS=(
    "ms-python.python"              # Python support
    "ms-python.vscode-pylance"      # Python language server
    "ms-python.debugpy"             # Python debugger
    "ms-pylint.pylint"              # Pylint linter
    "charliermarsh.ruff"            # Ruff formatter and linter
    "ms-python.black-formatter"     # Black code formatter
    "ms-python.isort"               # isort import sorter
    "ms-python.mypy-type-checker"   # mypy type checker
    "eamodio.gitlens"               # Git integration
    "mhutchie.git-graph"            # Git graph visualization
    "ms-python.vscode-pylance"      # Pylance language server
    "ms-python.select-pytest-framework"  # Pytest support
    "ms-toolsai.jupyter"            # Jupyter notebook support
    "DavidAnson.vscode-markdownlint" # Markdown linting
)

log_info "Installing VSCodium extensions..."
for ext in "${EXTENSIONS[@]}"; do
    log_info "Installing: $ext"
    if sudo -u $ACTUAL_USER codium --install-extension "$ext" 2>/dev/null; then
        log_success "Installed: $ext"
    else
        log_warning "Could not install: $ext (may already be installed or unavailable)"
    fi
done

################################################################################
# Step 6: Create extensions.json for workspace recommendations
################################################################################

log_info "Creating workspace extension recommendations..."

EXT_RECOMMENDATIONS="$VSCODE_DIR/extensions.json"

sudo -u $ACTUAL_USER cat > "$EXT_RECOMMENDATIONS" << 'EOF'
{
    "recommendations": [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "ms-python.debugpy",
        "ms-pylint.pylint",
        "charliermarsh.ruff",
        "ms-python.black-formatter",
        "ms-python.isort",
        "ms-python.mypy-type-checker",
        "eamodio.gitlens",
        "mhutchie.git-graph",
        "ms-toolsai.jupyter",
        "DavidAnson.vscode-markdownlint"
    ]
}
EOF

chown $ACTUAL_USER:$ACTUAL_USER "$EXT_RECOMMENDATIONS"
log_success "Workspace extension recommendations created"

################################################################################
# Step 7: Create launch configuration for debugging
################################################################################

log_info "Creating VSCodium debugging configuration..."

VSWORKSPACE_DIR="$ACTUAL_HOME/.config/VSCodium"
mkdir -p "$VSCODE_DIR/.vscode"

sudo -u $ACTUAL_USER cat > "$VSCODE_DIR/.vscode/launch.json" << 'EOF'
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: Current File",
            "type": "python",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal",
            "justMyCode": true
        },
        {
            "name": "Python: Debug Tests",
            "type": "python",
            "request": "launch",
            "module": "pytest",
            "args": ["${workspaceFolder}/tests", "-v"],
            "console": "integratedTerminal"
        },
        {
            "name": "Python: Interactive Console",
            "type": "python",
            "request": "launch",
            "module": "code",
            "args": []
        }
    ]
}
EOF

log_success "Debugging configuration created"

################################################################################
# Step 8: Create tasks configuration
################################################################################

log_info "Creating VSCodium tasks configuration..."

mkdir -p "$VSCODE_DIR/.vscode"

sudo -u $ACTUAL_USER cat > "$VSCODE_DIR/.vscode/tasks.json" << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Format with Black",
            "type": "shell",
            "command": "black",
            "args": ["."],
            "problemMatcher": [],
            "group": {
                "kind": "build",
                "isDefault": false
            }
        },
        {
            "label": "Lint with Pylint",
            "type": "shell",
            "command": "pylint",
            "args": ["."],
            "problemMatcher": [],
            "group": {
                "kind": "test",
                "isDefault": false
            }
        },
        {
            "label": "Run Tests (pytest)",
            "type": "shell",
            "command": "pytest",
            "args": ["tests", "-v"],
            "problemMatcher": [],
            "group": {
                "kind": "test",
                "isDefault": true
            }
        }
    ]
}
EOF

log_success "Tasks configuration created"

################################################################################
# Summary
################################################################################

echo ""
log_success "VSCodium setup complete!"
echo ""
log_info "To launch VSCodium:"
echo "  codium"
echo ""
log_info "Recommended workflow:"
echo "  1. Open a project folder: codium /path/to/project"
echo "  2. Create a virtual environment: python3 -m venv .venv"
echo "  3. Activate it: source .venv/bin/activate"
echo "  4. Install dependencies: pip install -r requirements.txt"
echo "  5. Start coding!"
echo ""

echo "Next steps:"
echo "  1. Run: bash scripts/05-dev-tools.sh"
echo "  2. Then: bash scripts/06-config-backup.sh"
echo ""
log_info "For detailed information, see docs/SETUP_GUIDE.md"
echo ""
