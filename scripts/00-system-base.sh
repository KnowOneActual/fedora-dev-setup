#!/bin/bash
# scripts/00-system-base.sh
# Phase 1: System Base & Core Tools
# Installs essential compilers, shell utilities, and system tools.

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"

log_header "Phase 1: System Base Setup"

# Pre-flight checks
check_root
check_internet

#######################################
# 1. Optimize DNF
#######################################
log_info "Optimizing DNF configuration..."

# Check if we need to optimize (mock check for dry run)
if [[ "${DRY_RUN:-}" == "true" ]]; then
    log_info "[DRY RUN] Would optimize /etc/dnf/dnf.conf"
elif ! grep -q "max_parallel_downloads" /etc/dnf/dnf.conf 2>/dev/null; then
    # Backup config
    backup_file "/etc/dnf/dnf.conf"
    
    # Apply optimizations
    cat >> /etc/dnf/dnf.conf << 'EOF'

# Performance optimizations
max_parallel_downloads=10
fastestmirror=true
deltarpm=true
keepcache=true
EOF
    log_success "DNF optimized (parallel downloads enabled)"
else
    log_info "DNF already optimized"
fi

#######################################
# 2. System Update
#######################################
log_info "Updating system repositories and packages..."

if [[ "${DRY_RUN:-}" == "true" ]]; then
    log_info "[DRY RUN] Would run: dnf upgrade -y --refresh"
else
    dnf upgrade -y --refresh
    log_success "System is up to date"
fi

#######################################
# 3. Enable Repositories
#######################################
# Enable RPM Fusion for broader package support (media codecs, etc.)
if ! package_installed "rpmfusion-free-release"; then
    log_info "Enabling RPM Fusion repositories..."
    
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would install RPM Fusion repository"
    else
        dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(get_fedora_version).noarch.rpm"
        log_success "RPM Fusion enabled"
    fi
fi

#######################################
# 4. Install Base Packages
#######################################
PACKAGES=(
    # compilers & build tools
    "gcc" "g++" "make" "cmake" "automake" "autoconf" "libtool"
    "kernel-devel" "openssl-devel" "libffi-devel" "zlib-devel"
    "bzip2-devel" "readline-devel" "sqlite-devel"
    
    # shell & terminal
    "zsh" "tmux" "fzf" "direnv" "bash-completion"
    
    # core utilities
    "git" "gh" "curl" "wget" "htop" "jq" "yq"
    "unzip" "zip" "tar" "gzip" "tree" "which"
    
    # modern replacements (optional but recommended)
    "bat"       # cat clone
    "ripgrep"   # grep clone
    "fd-find"   # find clone
    "neovim"    # vim clone
    
    # python base
    "python3" "python3-devel" "python3-pip"
)

log_info "Installing base system packages..."
install_dnf_packages "${PACKAGES[@]}"

#######################################
# 5. Post-Install Configuration
#######################################

# Ensure direnv hook exists in bashrc
ensure_in_path 'eval "$(direnv hook bash)"' "$HOME/.bashrc" "$SUDO_USER"

log_success "System base setup complete!"