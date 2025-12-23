#!/bin/bash
# scripts/50-desktop-apps.sh
# Phase 5: Desktop & GUI Applications
# Installs multimedia codecs, Flatpak ecosystem, and daily driver apps.

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"

log_header "Phase 5: Desktop Workstation Setup"

check_root

ACTUAL_USER="${SUDO_USER:-$(whoami)}"

#######################################
# 1. Multimedia Codecs
#######################################
log_info "Installing multimedia codecs (ffmpeg, gstreamer)..."

# Essential for playing videos, meetings, and OBS
# Logic ported from fedora-setup-v2.8.sh
CODECS=(
    "gstreamer1-plugins-base"
    "gstreamer1-plugins-good"
    "gstreamer1-plugins-bad-free"
    "gstreamer1-plugins-ugly"
    "gstreamer1-libav"
    "ffmpeg"
    "libdvdcss"
)

install_dnf_packages "${CODECS[@]}"

#######################################
# 2. Flatpak Setup
#######################################
log_info "Configuring Flatpak ecosystem..."

if ! command_exists "flatpak"; then
    install_dnf_packages "flatpak"
fi

if [[ "${DRY_RUN:-}" == "true" ]]; then
    log_info "[DRY RUN] Would add Flathub remote"
else
    # Enable Flathub (The App Store for Linux)
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    log_success "Flathub repository enabled"
fi

#######################################
# 3. Install Workstation Apps
#######################################
log_info "Installing Desktop Applications..."

# Curated list for a Developer Workstation
APPS=(
    # --- Productivity ---
    "org.libreoffice.LibreOffice"   # Office Suite
    "md.obsidian.Obsidian"          # Knowledge Base / Notes
    
    # --- Development Tools ---
    "com.getpostman.Postman"        # API Testing
    "io.dbeaver.DBeaverCommunity"   # Universal SQL Client
    
    # --- Communication ---
    "com.slack.Slack"               # Team Chat
    "us.zoom.Zoom"                  # Video Conferencing
    "com.discordapp.Discord"        # Community
    
    # --- Browsers ---
    "com.google.Chrome"             # Web Testing (Standard)
)

for app in "${APPS[@]}"; do
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would install Flatpak: $app"
    else
        # Install via Flatpak (Non-interactive)
        # Note: 'flatpak install' is safe to run multiple times
        log_info "Installing $app..."
        flatpak install -y flathub "$app"
    fi
done

log_success "Desktop applications installed!"