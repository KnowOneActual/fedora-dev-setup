#!/bin/bash
# scripts/00-system-base.sh
# Sets up the base system packages and repositories.

set -e

# Source logging library if it exists
if [ -f "$(dirname "$0")/lib/logging.sh" ]; then
    source "$(dirname "$0")/lib/logging.sh"
else
    # Fallback if logging.sh is missing
    function log_info() { echo "[INFO] $1"; }
    function log_success() { echo "[OK] $1"; }
    function log_header() { echo "=== $1 ==="; }
    function log_warn() { echo "[WARN] $1"; }
    function log_error() { echo "[ERROR] $1"; }
fi

log_header "Phase 1: System Base Setup"

# Check for root/sudo
if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_warn "[DRY RUN] Skipping root check"
else
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root or with sudo"
        exit 1
    fi
fi

# Internet check (Optional but good practice)
if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_info "[DRY RUN] Skipping internet check"
fi

# 1. Optimize DNF
log_info "Optimizing DNF configuration..."
if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_info "[DRY RUN] Would optimize /etc/dnf/dnf.conf"
else
    if ! grep -q "max_parallel_downloads" /etc/dnf/dnf.conf; then
        {
            echo "max_parallel_downloads=10"
            echo "fastestmirror=True"
            echo "defaultyes=True"
        } >> /etc/dnf/dnf.conf
        log_success "DNF configuration optimized"
    else
        log_info "DNF already optimized"
    fi
fi

# 2. Update System & Repositories
log_info "Updating system repositories and packages..."
if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_info "[DRY RUN] Would install RPM Fusion and run: dnf upgrade -y --refresh"
else
    # Enable RPM Fusion (Free and Nonfree)
    dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    
    dnf upgrade -y --refresh
    log_success "System is up to date with RPM Fusion enabled"
fi

# 3. Install Base Packages
log_info "Installing base system packages..."
if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_info "[DRY RUN] Would install dnf packages: gcc-c++ zlib-devel wget python3-setuptools git curl jq make tmux zsh"
else
    # Added core tools for validation and zsh setup
    dnf install -y gcc-c++ zlib-devel wget python3-setuptools git curl jq make tmux zsh
fi

log_success "System base setup complete!"