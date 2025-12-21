#!/bin/bash

################################################################################
# Fedora Python Development Setup - Step 1: Initial System Setup
# Description: System updates, DNF optimization, and essential packages
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

# Get Fedora version
FEDORA_VERSION=$(rpm -E %fedora)
log_info "Detected Fedora version: $FEDORA_VERSION"

if [[ $FEDORA_VERSION -lt 39 ]]; then
    log_warning "Fedora 39+ recommended. Current version: $FEDORA_VERSION"
fi

################################################################################
# Step 1: DNF Configuration Optimization
################################################################################

log_info "Optimizing DNF package manager configuration..."

# Backup original DNF config
if [[ -f /etc/dnf/dnf.conf ]]; then
    cp /etc/dnf/dnf.conf /etc/dnf/dnf.conf.backup
    log_success "Backed up original dnf.conf"
fi

# Add optimization settings to DNF config
cat >> /etc/dnf/dnf.conf << 'EOF'

# Performance optimizations
max_parallel_downloads=10
fastestmirror=true
deltarpm=true
keepcache=true
EOF

log_success "DNF optimized for better performance"

################################################################################
# Step 2: System Update
################################################################################

log_info "Updating system packages (this may take a few minutes)..."
dnf upgrade -y --refresh
log_success "System packages updated"

################################################################################
# Step 3: Install Essential Packages
################################################################################

log_info "Installing essential development packages..."

ESSENTIAL_PACKAGES=(
    # Development tools
    "gcc"
    "g++"
    "make"
    "cmake"
    "autoconf"
    "automake"
    "libtool"
    
    # Git and version control
    "git"
    "gh"  # GitHub CLI
    
    # Build dependencies
    "openssl-devel"
    "zlib-devel"
    "bzip2-devel"
    "readline-devel"
    "sqlite-devel"
    "libffi-devel"
    
    # System utilities
    "curl"
    "wget"
    "htop"
    "tmux"
    "neovim"
    "tree"
    "jq"
    "bat"
    "ripgrep"
    "fd-find"
    
    # Useful CLI tools
    "unzip"
    "zip"
    "tar"
    "gzip"
    
    # System info
    "lsb-release"
    "util-linux"
    
    # Container support (optional)
    "podman"
)

for package in "${ESSENTIAL_PACKAGES[@]}"; do
    if dnf install -y "$package" 2>/dev/null; then
        log_success "Installed: $package"
    else
        log_warning "Could not install: $package (may not be available)"
    fi
done

################################################################################
# Step 4: Fedora Repositories Configuration
################################################################################

log_info "Configuring Fedora repositories..."

# Enable RPM Fusion repositories (for multimedia and other packages)
if ! dnf repolist | grep -q rpmfusion; then
    log_info "Installing RPM Fusion repositories..."
    dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    log_success "RPM Fusion Free enabled"
else
    log_success "RPM Fusion repositories already configured"
fi

################################################################################
# Step 5: SSH Key Check
################################################################################

log_info "Checking SSH key setup..."

if [[ ! -f ~/.ssh/id_ed25519 ]]; then
    log_warning "No SSH key found. You'll need to create one."
    log_info "You can generate an SSH key with:"
    echo "  ssh-keygen -t ed25519 -C 'your-email@example.com'"
else
    log_success "SSH key found at ~/.ssh/id_ed25519"
fi

################################################################################
# Summary
################################################################################

echo ""
log_success "Step 1 Complete: Initial system setup finished!"
echo ""
echo "Next steps:"
echo "  1. Run: sudo bash scripts/02-git-config.sh"
echo "  2. Then: sudo bash scripts/03-python-setup.sh"
echo "  3. Then: bash scripts/04-vscodium-setup.sh"
echo ""
log_info "For detailed information, see docs/SETUP_GUIDE.md"
echo ""
