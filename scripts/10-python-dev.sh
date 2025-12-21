#!/bin/bash
# scripts/10-python-dev.sh
# Phase 2: Python Development Environment
# Installs modern Python tooling: uv, pipx, and global utilities.

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"

log_header "Phase 2: Python Environment Setup"

check_root
check_internet

#######################################
# 1. Install uv (Fast Python Installer)
#######################################
log_info "Installing uv (extremely fast Python package installer)..."

if ! command_exists "uv"; then
    # uv installs to ~/.cargo/bin or ~/.local/bin usually, but we want it system-wide for dev setup
    # or we install it to /usr/local/bin manually to ensure visibility
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Ensure it's in the path for the current session
    export PATH="$HOME/.cargo/bin:$PATH"
    
    # Persist for user
    ensure_in_path 'export PATH="$HOME/.cargo/bin:$PATH"' "$HOME/.bashrc" "$SUDO_USER"
    
    if command_exists "uv"; then
        log_success "uv installed successfully"
    else
        log_warn "uv installed but not found in PATH. You may need to restart shell."
    fi
else
    log_info "uv is already installed"
fi

#######################################
# 2. Install pipx (Isolated Environment Manager)
#######################################
log_info "Installing pipx..."

if ! command_exists "pipx"; then
    # We install pipx via dnf or pip. DNF is safer for system integration on Fedora.
    install_dnf_packages "pipx"
    
    # Ensure path is set up
    sudo -u "$SUDO_USER" pipx ensurepath
    log_success "pipx installed"
else
    log_info "pipx is already installed"
fi

#######################################
# 3. Install Global Python Tools
#######################################
# We use pipx for these to verify they are isolated and don't break system python
TOOLS=(
    "black"         # Formatter
    "ruff"          # Fast Linter
    "mypy"          # Type Checker
    "pytest"        # Testing
    "ipython"       # Better REPL
    "httpie"        # Modern curl alternative
    "poetry"        # Dependency management
    "cookiecutter"  # Project scaffolding
)

log_info "Installing global Python tools via pipx..."

for tool in "${TOOLS[@]}"; do
    if ! sudo -u "$SUDO_USER" pipx list | grep -q "$tool"; then
        log_info "Installing $tool..."
        if sudo -u "$SUDO_USER" pipx install "$tool"; then
            log_success "$tool installed"
        else
            log_error "Failed to install $tool"
        fi
    else
        log_info "$tool already installed"
    fi
done

#######################################
# 4. Verify Installation
#######################################
log_info "Verifying installations..."

validate_command "uv"
validate_command "pipx"
validate_command "python3"

# Check a few pipx tools
if sudo -u "$SUDO_USER" pipx list | grep -q "black"; then
    log_success "Global tools accessible"
else
    log_warn "Global tools installed but might need a shell restart to be in PATH"
fi

log_success "Python development environment setup complete!"