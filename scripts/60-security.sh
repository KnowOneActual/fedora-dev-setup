#!/bin/bash
# scripts/60-security.sh
# Phase 6: Security Auditing
# Installs Lynis and performs a system security scan.

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
# Fallback if libs are missing (during dev/testing)
if [[ -f "$LIB_DIR/logging.sh" ]]; then
    source "$LIB_DIR/logging.sh"
    source "$LIB_DIR/utils.sh"
else
    echo "Libraries not found, using simple fallback"
    log_header() { echo "=== $1 ==="; }
    log_info() { echo "[INFO] $1"; }
    log_success() { echo "[OK] $1"; }
    check_root() { [[ $EUID -eq 0 ]] || exit 1; }
fi

log_header "Phase 6: Security Audit"

check_root

#######################################
# 1. Install Lynis
#######################################
log_info "Installing Lynis security auditor..."

if ! command_exists "lynis"; then
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would install package: lynis"
    else
        install_dnf_packages "lynis"
    fi
else
    log_info "Lynis is already installed."
fi

#######################################
# 2. Run Audit
#######################################
LOG_FILE="/var/log/lynis-report.log"

if [[ "${DRY_RUN:-}" == "true" ]]; then
    log_info "[DRY RUN] Would run: lynis audit system"
    log_info "[DRY RUN] Would save report to $LOG_FILE"
else
    log_info "Running system audit (this may take 1-2 minutes)..."
    
    # Run quietly (--quiet), non-interactively (--quick)
    # We define the auditor name to tag the report
    if lynis audit system --quick --auditor "Fedora Dev Setup" > "$LOG_FILE" 2>&1; then
        # Lynis returns non-zero if issues are found, so we might land in 'else' often.
        # However, for our script flow, we just want to ensure it RAN.
        :
    fi
    
    # Check if log file was actually created
    if [[ -f "$LOG_FILE" ]]; then
        log_success "Audit complete. Report saved to $LOG_FILE"
        
        # Extract the Hardening Index if available
        SCORE=$(grep "Hardening index" "$LOG_FILE" | cut -d ':' -f 2 | xargs)
        if [[ -n "$SCORE" ]]; then
            log_info "Security Hardening Index: $SCORE"
        fi
        
        echo ""
        echo "-----------------------------------------------------"
        echo "To view warnings and suggestions, run:"
        echo "  grep -E 'warning|suggestion' $LOG_FILE"
        echo "-----------------------------------------------------"
    else
        log_warn "Lynis ran, but no log file was generated at $LOG_FILE"
    fi
fi

log_success "Security setup complete!"