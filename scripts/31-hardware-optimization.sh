#!/bin/bash
# scripts/31-hardware-optimization.sh
# Phase 3: Hardware Optimization
# Applies power and performance tuning based on chassis type.

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"

log_header "Phase 3: Hardware Optimization"

check_root

PROFILE_FILE="/tmp/fedora-hardware-profile.json"

#######################################
# 1. Load Hardware Profile
#######################################
if [[ ! -f "$PROFILE_FILE" ]]; then
    log_warn "Hardware profile not found. Running detection..."
    DETECT_SCRIPT="$(dirname "${BASH_SOURCE[0]}")/detect-hardware.sh"
    if [[ -x "$DETECT_SCRIPT" ]]; then
        "$DETECT_SCRIPT"
    else
        log_error "Cannot find detect-hardware.sh"
        exit 1
    fi
fi

if [[ "${DRY_RUN:-}" == "true" ]]; then
    CHASSIS="laptop" # Mock for testing
    log_info "[DRY RUN] Mocking chassis as: $CHASSIS"
else
    CHASSIS=$(jq -r '.chassis // "desktop"' "$PROFILE_FILE")
fi

log_info "Optimizing for chassis type: $CHASSIS"

#######################################
# 2. Laptop Optimization (Battery)
#######################################
optimize_laptop() {
    log_info "Applying laptop battery & thermal optimizations..."

    # Install TLP (Advanced Power Management)
    # Note: TLP conflicts with power-profiles-daemon in some GNOME setups,
    # but for pure dev battery life, TLP is often superior.
    # Fedora default is power-profiles-daemon.
    
    # Check if user wants TLP or sticks with default
    # For this script, we'll ensure TLP is available but respecting defaults if active.
    
    install_dnf_packages "tlp" "tlp-rdw" "powertop"

    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would enable and start TLP service"
    else
        # We mask power-profiles-daemon to prevent conflicts if enabling TLP
        systemctl mask power-profiles-daemon
        systemctl enable tlp
        systemctl start tlp
        log_success "TLP enabled for battery optimization."
    fi
}

#######################################
# 3. Workstation Optimization (Performance)
#######################################
optimize_desktop() {
    log_info "Applying workstation performance optimizations..."

    # Install performance tools
    install_dnf_packages "cpupower"

    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would set CPU governor to 'performance'"
    else
        # Force performance governor if possible
        if command_exists "cpupower"; then
            cpupower frequency-set -g performance 2>/dev/null || log_warn "Could not set CPU frequency"
        fi
        
        # Ensure standard power daemon is running (balanced/performance)
        systemctl unmask power-profiles-daemon
        systemctl enable power-profiles-daemon
        systemctl start power-profiles-daemon
        
        log_success "System tuned for performance."
    fi
}

#######################################
# 4. Execute Logic
#######################################

case "$CHASSIS" in
    laptop|notebook|portable)
        optimize_laptop
        ;;
    desktop|server|workstation)
        optimize_desktop
        ;;
    *)
        log_warn "Unknown chassis type: $CHASSIS. Defaulting to desktop mode."
        optimize_desktop
        ;;
esac

log_success "Hardware optimization complete!"