#!/usr/bin/env bash
# bootstrap-fedora.sh - Fedora Development Environment Bootstrapper v1.0.0
# Orchestrates the modular setup scripts.

set -euo pipefail

# Directories
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"
LIB_DIR="$SCRIPTS_DIR/lib"

# Source logging if available, otherwise define simple fallbacks
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
  --install     Run the full installation (System -> Python -> VSCodium -> Validate)
  --validate    Run only the validation checks (verify current state)
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
    
    if [[ -x "$script_path" ]]; then
        log_info "Executing $script_name..."
        "$script_path"
    else
        # Try running with bash if not executable
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

    # Default to install mode if dry-run is set but no mode is specified
    if [[ "$DRY_RUN" == "true" && -z "$MODE" ]]; then
        MODE="install"
    fi

    # Pre-flight check for scripts directory
    if [[ ! -d "$SCRIPTS_DIR" ]]; then
        log_error "Missing scripts directory at $SCRIPTS_DIR"
        exit 1
    fi

    # Execute based on mode
    case "$MODE" in
        install)
            log_header "Starting Fedora Development Setup v1.0.0"
            
            # 1. System Base
            run_script "00-system-base.sh"
            
            # 2. Python Environment
            run_script "10-python-dev.sh"
            
            # 3. VSCodium
            run_script "20-vscodium.sh"
            
            # 4. Validation
            run_script "99-validate.sh"
            
            log_success "🎉 Full installation sequence complete!"
            ;;
            
        validate)
            log_header "Validating Environment"
            run_script "99-validate.sh"
            ;;
            
        *)
            # If still no mode, show usage
            usage
            exit 1
            ;;
    esac
}

main "$@"