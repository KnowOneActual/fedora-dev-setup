#!/bin/bash
# scripts/50-desktop-apps.sh
# Sets up desktop applications via Flatpak and installs multimedia codecs.

set -e

# ==============================================================================
# Library Sourcing & Setup
# ==============================================================================
# Navigate to the script's directory to find the lib folder correctly
cd "$(dirname "$0")" || exit 1

if [ -f "lib/logging.sh" ]; then
    source lib/logging.sh
else
    echo "[ERROR] lib/logging.sh not found!"
    exit 1
fi

# ==============================================================================
# Checks
# ==============================================================================
log_header "Phase 5: Desktop Workstation Setup"

# Check if we are in Dry Run mode (DRY_RUN is usually set in bootstrap-fedora.sh)
if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_warn "[DRY RUN] Skipping root check"
else
    # Verify script is run as root/sudo
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root or with sudo"
        exit 1
    fi
fi

# ==============================================================================
# 1. Multimedia Codecs
# ==============================================================================
log_info "Installing multimedia codecs (ffmpeg, gstreamer)..."

if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_info "[DRY RUN] Would install dnf packages: gstreamer1-libav"
else
    # Removed 'libdvdcss' to fix repo error
    dnf install -y gstreamer1-libav
fi

# ==============================================================================
# 2. Flatpak Ecosystem
# ==============================================================================
log_info "Configuring Flatpak ecosystem..."

if [[ "${DRY_RUN:-false}" == "true" ]]; then
    log_info "[DRY RUN] Would add Flathub remote"
else
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# ==============================================================================
# 3. Desktop Applications
# ==============================================================================
log_info "Installing Desktop Applications..."

# List of Flatpak applications
flatpak_apps=(
    "org.libreoffice.LibreOffice"
    "md.obsidian.Obsidian"
    "com.getpostman.Postman"
    "io.dbeaver.DBeaverCommunity"
    "com.slack.Slack"
    "us.zoom.Zoom"
    "com.discordapp.Discord"
    "com.google.Chrome"
)

for app in "${flatpak_apps[@]}"; do
    if [[ "${DRY_RUN:-false}" == "true" ]]; then
        log_info "[DRY RUN] Would install Flatpak: $app"
    else
        log_info "Installing $app..."
        flatpak install -y flathub "$app"
    fi
done

log_success "Desktop applications installed!"