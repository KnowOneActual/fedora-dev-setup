#!/bin/bash
# scripts/45-containers.sh
# Phase 4: Container Virtualization
# Installs Docker, Podman, and Distrobox for isolated development.

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"

log_header "Phase 4: Container Setup"

check_root

ACTUAL_USER="${SUDO_USER:-$(whoami)}"

#######################################
# 1. Podman & Distrobox (Fedora Native)
#######################################
log_info "Installing Podman and Distrobox..."
# Distrobox is amazing for running other distros (Ubuntu/Arch) inside Fedora terminal
install_dnf_packages "podman" "podman-compose" "distrobox"

#######################################
# 2. Docker CE (Industry Standard)
#######################################
if ! command_exists "docker"; then
    log_info "Installing Docker CE..."
    install_dnf_packages "docker" "docker-compose"
    
    if [[ "${DRY_RUN:-}" != "true" ]]; then
        # Enable and start the service
        systemctl enable --now docker
        
        # Add user to docker group (avoid sudo for docker commands)
        if ! groups "$ACTUAL_USER" | grep -q "docker"; then
            usermod -aG docker "$ACTUAL_USER"
            log_success "Added user $ACTUAL_USER to 'docker' group (requires logout)"
        fi
        
        log_success "Docker installed and service started"
    fi
else
    log_info "Docker is already installed"
fi

log_success "Container setup complete!"