#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_PATH="${SCRIPT_DIR}/scripts"
LOGS_DIR="${SCRIPT_DIR}/logs"

DRY_RUN=false
HEADLESS=false
VERBOSE=false
SKIP_SCRIPTS=()

mkdir -p "${LOGS_DIR}"
LOG_FILE="${LOGS_DIR}/bootstrap-$(date +%Y%m%d-%H%M%S).log"
export LOG_FILE

# shellcheck source=/dev/null
source "${SCRIPTS_PATH}/lib/logging.sh"
# shellcheck source=/dev/null
source "${SCRIPTS_PATH}/lib/utils.sh"

should_skip() {
    local script_name=$1
    for skip in "${SKIP_SCRIPTS[@]}"; do
        if [[ "$script_name" == "$skip" ]]; then
            return 0
        fi
    done
    return 1
}

run_script() {
    local script_path=$1
    local script_name
    script_name=$(basename "$script_path")

    if should_skip "$script_name"; then
        log_warn "Skipping $script_name (--skip)"
        return 0
    fi

    if [[ ! -f "$script_path" ]]; then
        log_error "Script not found: $script_path"
        return 1
    fi

    log_info "Running: $script_name"

    if [[ "$DRY_RUN" == true ]]; then
        log_warn "[DRY RUN] Would execute: bash $script_path"
        return 0
    fi

    export DRY_RUN HEADLESS VERBOSE LOG_FILE

    if bash "$script_path"; then
        log_success "$script_name completed successfully"
        return 0
    else
        log_error "$script_name failed"
        return 1
    fi
}

print_usage() {
    cat << 'EOF'
Fedora Python Dev Setup Bootstrap

USAGE:
  ./bootstrap-fedora.sh [OPTIONS]

OPTIONS:
  --dry-run       Preview changes without applying
  --headless      Run without prompts (for automation)
  --verbose       Print commands as they execute
  --skip SCRIPT   Skip a specific script (e.g. 20-vscodium.sh)
  --help          Show this help

EXAMPLES:
  ./bootstrap-fedora.sh                    # Interactive mode
  ./bootstrap-fedora.sh --dry-run          # Preview only
  ./bootstrap-fedora.sh --headless         # Automated
  ./bootstrap-fedora.sh --skip 20-vscodium.sh  # Skip VSCodium

EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run) DRY_RUN=true; shift ;;
            --headless) HEADLESS=true; shift ;;
            --verbose) VERBOSE=true; export VERBOSE=true; set -x; shift ;;
            --skip) SKIP_SCRIPTS+=("$2"); shift 2 ;;
            --help) print_usage; exit 0 ;;
            *) log_error "Unknown option: $1"; print_usage; exit 1 ;;
        esac
    done
}

preflight_checks() {
    print_section "Preflight Checks"

    if ! is_fedora; then
        log_error "This script is designed for Fedora."
        return 1
    fi
    log_success "Fedora detected"

    local fedora_version
    fedora_version=$(get_fedora_version)
    log_info "Fedora version: $fedora_version"
    if [[ "$fedora_version" -lt 40 ]]; then
        log_warn "Fedora $fedora_version detected (tested on 40+)"
        if [[ "$HEADLESS" != true ]]; then
            read -p "Continue anyway? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log_error "Aborted by user"
                return 1
            fi
        fi
    fi

    log_info "Checking internet connectivity..."
    if ! check_internet; then
        log_error "No internet connectivity"
        return 1
    fi
    log_success "Internet connectivity confirmed"

    log_info "Checking sudo privileges..."
    if ! has_sudo && ! is_root; then
        log_warn "Sudo access required; you may be prompted"
        if ! sudo -v; then
            log_error "Sudo authentication failed"
            return 1
        fi
    fi
    log_success "Sudo privileges confirmed"

    log_info "Checking disk space..."
    local available_space
    available_space=$(get_available_disk_space)
    if [[ $available_space -lt 5242880 ]]; then
        log_error "Insufficient disk space (need at least 5GB)"
        return 1
    fi
    log_success "Sufficient disk space available"
}

main() {
    local start_time
    start_time=$(date +%s)

    parse_args "$@"

    log_info "Fedora Dev Setup Bootstrap Started"
    log_info "Log file: $LOG_FILE"
    log_info "User: $(whoami)"
    log_info "Dir: $(pwd)"

    if [[ "$DRY_RUN" == true ]]; then
        log_warn "DRY RUN MODE - no changes will be made"
    fi

    if ! preflight_checks; then
        log_error "Preflight checks failed"
        exit 1
    fi

    print_section "System Setup"
    run_script "${SCRIPTS_PATH}/00-system-base.sh" || {
        log_error "System base setup failed, aborting"
        exit 1
    }

    print_section "Python Development Setup"
    run_script "${SCRIPTS_PATH}/10-python-dev.sh" || {
        log_warn "Python setup had issues, continuing"
    }

    print_section "VSCodium Setup"
    run_script "${SCRIPTS_PATH}/20-vscodium.sh" || {
        log_warn "VSCodium setup had issues, continuing"
    }

    if [[ -f "${SCRIPTS_PATH}/99-validate.sh" ]]; then
        print_section "Validation"
        run_script "${SCRIPTS_PATH}/99-validate.sh" || {
            log_warn "Some validation checks failed"
        }
    fi

    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    print_section "Setup Complete"
    log_success "Elapsed time: $((duration/60))m $((duration%60))s"
    log_info "Next steps:"
    print_info_list \
        "Verify Python: python3 --version && uv --version" \
        "Launch VSCodium: codium" \
        "Configure Git: git config --global user.name 'Your Name'" \
        "Generate SSH key: ssh-keygen -t ed25519"

}

main "$@"
