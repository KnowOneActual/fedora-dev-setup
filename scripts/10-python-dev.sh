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

# Determine the actual user (fallback to current user if not sudo)
ACTUAL_USER="${SUDO_USER:-$(whoami)}"
ACTUAL_HOME=$(eval echo "~$ACTUAL_USER")

#######################################
# 1. Install uv (Fast Python Installer)
#######################################
log_info "Installing uv (extremely fast Python package installer)..."

# Check if uv is present in the user's home (since it's not a system package)
if ! sudo -u "$ACTUAL_USER" test -f "$ACTUAL_HOME/.local/bin/uv"; then
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would download and install uv"
    else
        # Fix: Run as the actual user so it installs to ~/.local/bin, not /root/.local/bin
        log_info "Downloading and installing uv as user '$ACTUAL_USER'..."
        sudo -u "$ACTUAL_USER" sh -c "curl -LsSf https://astral.sh/uv/install.sh | sh"
        
        # Fix: uv installs to ~/.local/bin by default. 
        # We also add .cargo/bin here to prepare for Rust (Phase 3) or if uv changes behavior.
        ensure_in_path 'export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"' "$ACTUAL_HOME/.bashrc" "$ACTUAL_USER"
        
        if sudo -u "$ACTUAL_USER" test -f "$ACTUAL_HOME/.local/bin/uv"; then
            log_success "uv installed successfully"
        else
            log_warn "uv installed but binary not found in $ACTUAL_HOME/.local/bin"
        fi
    fi
else
    log_info "uv is already installed"
fi

#######################################
# 2. Install pipx (Isolated Environment Manager)
#######################################
log_info "Installing pipx..."

if ! command_exists "pipx"; then
    # In dry run, we use the library function which handles mocking
    install_dnf_packages "pipx"
    
    if [[ "${DRY_RUN:-}" != "true" ]]; then
        # Ensure path is set up for the user
        sudo -u "$ACTUAL_USER" pipx ensurepath
        log_success "pipx installed"
    fi
else
    log_info "pipx is already installed"
fi

#######################################
# 3. Install Global Python Tools
#######################################
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
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would install: $tool"
    else
        # Check if installed for the user
        if ! sudo -u "$ACTUAL_USER" pipx list | grep -q "$tool"; then
            log_info "Installing $tool..."
            if sudo -u "$ACTUAL_USER" pipx install "$tool"; then
                log_success "$tool installed"
            else
                log_error "Failed to install $tool"
            fi
        else
            log_info "$tool already installed"
        fi
    fi
done

#######################################
# 4. Verify Installation
#######################################
log_info "Verifying installations..."

# System-wide checks
validate_command "python3"
validate_command "pipx"

if [[ "${DRY_RUN:-}" == "true" ]]; then
    log_success "[DRY RUN] Global tools validation passed (mock)"
else
    # User-specific checks
    if sudo -u "$ACTUAL_USER" test -f "$ACTUAL_HOME/.local/bin/uv"; then
        log_success "uv is accessible"
    else
        log_error "uv is missing from $ACTUAL_HOME/.local/bin"
    fi

    if sudo -u "$ACTUAL_USER" pipx list | grep -q "black"; then
        log_success "Global tools accessible (via pipx)"
    else
        log_warn "Global tools installed but might need a shell restart to be in PATH"
    fi
fi

log_success "Python development environment setup complete!"