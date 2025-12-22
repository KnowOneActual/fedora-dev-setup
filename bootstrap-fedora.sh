#!/usr/bin/env bash
# bootstrap-fedora.sh - Fedora Development Environment Bootstrapper v1.2.0
# Orchestrates the modular setup scripts.

set -euo pipefail

# Directories
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"
LIB_DIR="$SCRIPTS_DIR/lib"

# Source logging if available
if [[ -f "$LIB_DIR/logging.sh" ]]; then
    source "$LIB_DIR/logging.sh"
else
    echo "Error: scripts/lib/logging.sh not found." >&2
    exit 1
fi

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
  --help        Show this help message
  --install     Run the full installation (System -> Python -> Tools -> Hardware)
  --validate    Run only the validation checks
  --dry-run     Simulate the installation without making changes

EXAMPLES:
  $0 --dry-run              # Preview changes safely
  sudo $0 --install         # Install everything
  $0 --validate             # Check if system is ready
EOF
}

run_script() {
    local script_name="$1"
    local script_path="$SCRIPTS_DIR/$script_name"
    
    # Check if script exists
    if [[ ! -f "$script_path" ]]; then
        log_warn "Script not found: $script_name (Skipping)"
        return
    fi

    if [[ -x "$script_path" ]]; then
        log_info "Executing $script_name..."
        "$script_path"
    else
        log_info "Executing $script_name (via bash)..."
        bash "$script_path"
    fi
}

main() {
    if [[ $# -eq 0 ]]; then
        usage
        exit 1
    fi

    local MODE=""
    export DRY_RUN="false"

    # Parse arguments
    for arg in "$@"; do
        case "$arg" in
            --help|-h)
                usage
                exit 0
                ;;
            --dry-run)
                export DRY_RUN="true"
                log_warn "Running in DRY RUN mode. No changes will be made."
                ;;
            --install)
                MODE="install"
                ;;
            --validate)
                MODE="validate"
                ;;
            *)
                log_error "Unknown option: $arg"
                exit 1
                ;;
        esac
    done

    if [[ "$DRY_RUN" == "true" && -z "$MODE" ]]; then
        MODE="install"
    fi

    if [[ ! -d "$SCRIPTS_DIR" ]]; then
        log_error "Missing scripts directory at $SCRIPTS_DIR"
        exit 1
    fi

    case "$MODE" in
        install)
            log_header "Starting Fedora Development Setup v1.2.0"
            
            # --- Phase 1: Core System ---
            run_script "00-system-base.sh"
            
            # --- Phase 2: User Environment ---
            run_script "10-python-dev.sh"
            run_script "20-vscodium.sh"
            run_script "25-setup-zsh.sh"
            
            # --- Phase 3: Hardware & Extended Stack ---
            # 1. Detect Hardware Profile
            run_script "detect-hardware.sh"
            
            # 2. Configure GPU & Optimization based on profile
            run_script "30-gpu-setup.sh"
            run_script "31-hardware-optimization.sh"
            
            # 3. Install Extended Languages
            run_script "40-languages.sh"
            
            # --- Validation ---
            run_script "99-validate.sh"
            
            log_success "🎉 Full installation sequence complete!"
            ;;
            
        validate)
            log_header "Validating Environment"
            run_script "99-validate.sh"
            ;;
            
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"