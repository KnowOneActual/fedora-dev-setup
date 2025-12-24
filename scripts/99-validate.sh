#!/bin/bash
# scripts/99-validate.sh
# Phase 1: Validation
# Verifies that all components from the setup process are correctly installed.

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"

log_header "Final Validation"

FAILED=0
ACTUAL_USER="${SUDO_USER:-$(whoami)}"
ACTUAL_HOME=$(eval echo "~$ACTUAL_USER")

#######################################
# 1. System Tools Verification
#######################################
log_info "Verifying core system tools..."
SYSTEM_TOOLS=("git" "curl" "jq" "make" "gcc" "zsh" "tmux" "htop" "fzf" "direnv")
for tool in "${SYSTEM_TOOLS[@]}"; do
    if ! validate_command "$tool"; then FAILED=$((FAILED + 1)); fi
done

#######################################
# 2. Python Environment
#######################################
log_info "Verifying Python environment..."
if ! validate_command "python3"; then FAILED=$((FAILED + 1)); fi

# Check uv
if [[ "${DRY_RUN:-}" == "true" ]]; then
    log_success "[DRY RUN] uv validation passed (mock)"
elif sudo -u "$ACTUAL_USER" test -f "$ACTUAL_HOME/.local/bin/uv" || \
     sudo -u "$ACTUAL_USER" test -f "$ACTUAL_HOME/.cargo/bin/uv"; then
    log_success "uv is installed"
else
    log_error "uv is missing"
    FAILED=$((FAILED + 1))
fi

#######################################
# 3. Containerization (NEW)
#######################################
log_info "Verifying Container stack..."
CONTAINER_TOOLS=("docker" "podman" "distrobox")

for tool in "${CONTAINER_TOOLS[@]}"; do
    if ! validate_command "$tool"; then FAILED=$((FAILED + 1)); fi
done

#######################################
# 4. Desktop & Flatpaks (NEW)
#######################################
log_info "Verifying Desktop Apps..."

if validate_command "flatpak"; then
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_success "[DRY RUN] Flatpak apps validation passed (mock)"
    else
        INSTALLED_APPS=$(flatpak list --app --columns=application)
        
        # Check a few key apps
        REQUIRED_APPS=("org.libreoffice.LibreOffice" "md.obsidian.Obsidian")
        
        for app in "${REQUIRED_APPS[@]}"; do
            if echo "$INSTALLED_APPS" | grep -q "$app"; then
                log_success "Flatpak app $app is installed"
            else
                log_warn "Flatpak app $app missing (optional)"
            fi
        done
    fi
else
    FAILED=$((FAILED + 1))
fi

#######################################
# 5. Final Report
#######################################
echo ""
if [[ $FAILED -eq 0 ]]; then
    log_success "✅ All checks passed! Your Fedora Workstation is ready."
else
    log_error "❌ Setup verified with $FAILED errors."
    exit 1
fi