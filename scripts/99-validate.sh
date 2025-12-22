#!/bin/bash
# scripts/99-validate.sh
# Phase 1: Validation
# Verifies that all components from the setup process are correctly installed.

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"

log_header "Phase 1: Setup Validation"

FAILED=0
ACTUAL_USER="${SUDO_USER:-$(whoami)}"
ACTUAL_HOME=$(eval echo "~$ACTUAL_USER")

#######################################
# 1. System Tools Verification
#######################################
log_info "Verifying core system tools..."

SYSTEM_TOOLS=(
    "git" "curl" "wget" "jq" "make" "gcc" "tar" "unzip"
    "zsh" "tmux" "htop" "fzf" "direnv"
)

for tool in "${SYSTEM_TOOLS[@]}"; do
    if ! validate_command "$tool"; then
        FAILED=$((FAILED + 1))
    fi
done

#######################################
# 2. Python Environment Verification
#######################################
log_info "Verifying Python environment..."

# Removed 'uv' from this list because it's not in the system PATH
PYTHON_TOOLS=(
    "python3" "pip3" "pipx"
)

for tool in "${PYTHON_TOOLS[@]}"; do
    if ! validate_command "$tool"; then
        FAILED=$((FAILED + 1))
    fi
done

# Check uv specifically in user's home (since root can't see it)
if sudo -u "$ACTUAL_USER" test -f "$ACTUAL_HOME/.local/bin/uv" || \
   sudo -u "$ACTUAL_USER" test -f "$ACTUAL_HOME/.cargo/bin/uv"; then
    log_success "uv is installed (user local)"
else
    log_error "uv is missing from ~/.local/bin or ~/.cargo/bin"
    FAILED=$((FAILED + 1))
fi

# Verify global pipx tools
log_info "Verifying global Python utilities..."
PIPX_TOOLS=("black" "ruff" "mypy" "pytest" "ipython")

for tool in "${PIPX_TOOLS[@]}"; do
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_success "[DRY RUN] $tool validation passed (mock)"
    else
        # pipx tools might not be in PATH immediately for script execution
        # so we check if they are registered in pipx
        if sudo -u "$ACTUAL_USER" pipx list | grep -q "$tool"; then
            log_success "$tool is installed (pipx)"
        else
            log_error "$tool is missing from pipx"
            FAILED=$((FAILED + 1))
        fi
    fi
done

#######################################
# 3. VSCodium Verification
#######################################
log_info "Verifying VSCodium setup..."

if validate_command "codium" "VSCodium"; then
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_success "[DRY RUN] Extensions validation passed (mock)"
    else
        # Check for key extensions
        INSTALLED_EXTS=$(sudo -u "$ACTUAL_USER" codium --list-extensions)
        REQUIRED_EXTS=("ms-python.python" "charliermarsh.ruff" "eamodio.gitlens")
        
        for ext in "${REQUIRED_EXTS[@]}"; do
            if echo "$INSTALLED_EXTS" | grep -q "$ext"; then
                log_success "Extension $ext is active"
            else
                log_warn "Extension $ext not found (might need manual install)"
            fi
        done
    fi
else
    FAILED=$((FAILED + 1))
fi

#######################################
# 4. Final Report
#######################################
echo ""
if [[ $FAILED -eq 0 ]]; then
    log_success "✅ All checks passed! Your Fedora development environment is ready."
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo "  1. Restart your shell or log out/in to apply PATH changes."
    echo "  2. Open VSCodium and verify your settings."
    echo "  3. Clone a repo and start coding!"
else
    log_error "❌ Setup verified with $FAILED errors."
    echo "Check the logs above for details on missing components."
    exit 1
fi