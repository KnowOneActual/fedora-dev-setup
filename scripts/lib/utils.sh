#!/bin/bash
# scripts/lib/utils.sh
# Common utility functions for Fedora setup scripts.

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get Fedora Version (e.g., 40, 41)
get_fedora_version() {
    if command_exists "rpm"; then
        local version
        version=$(rpm -E %fedora)
        echo "$version"
    else
        # Fallback for non-Fedora systems (testing)
        echo "41"
    fi
}

# Check if a DNF package is installed
package_installed() {
    if ! command_exists "rpm"; then
        return 1
    fi
    rpm -q "$1" >/dev/null 2>&1
}

# Install DNF packages if missing
install_dnf_packages() {
    local packages=("$@")
    local to_install=()

    for pkg in "${packages[@]}"; do
        if ! package_installed "$pkg"; then
            to_install+=("$pkg")
        fi
    done

    if [[ ${#to_install[@]} -gt 0 ]]; then
        if [[ "${DRY_RUN:-}" == "true" ]]; then
            log_info "[DRY RUN] Would install dnf packages: ${to_install[*]}"
        else
            log_info "Installing: ${to_install[*]}"
            sudo dnf install -y "${to_install[@]}"
        fi
    fi
}

# Ensure a directory exists with correct ownership
ensure_directory() {
    local dir="$1"
    local owner="$2"

    if [[ ! -d "$dir" ]]; then
        if [[ "${DRY_RUN:-}" == "true" ]]; then
            log_info "[DRY RUN] Would create directory: $dir (owner: $owner)"
        else
            mkdir -p "$dir"
            if [[ -n "$owner" ]]; then
                chown "$owner:$owner" "$dir"
            fi
            log_success "Created directory: $dir"
        fi
    fi
}

# Create a timestamped backup of a file
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local timestamp
        timestamp=$(date +%s)
        cp "$file" "${file}.backup.${timestamp}"
        log_info "Backed up $file to ${file}.backup.${timestamp}"
    fi
}

# Ensure a line exists in a file (idempotent)
ensure_in_path() {
    local line="$1"
    local file="$2"
    local owner="$3"

    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would add '$line' to $file"
        return
    fi

    if [[ ! -f "$file" ]]; then
        touch "$file"
        if [[ -n "$owner" ]]; then
            chown "$owner:$owner" "$file"
        fi
    fi

    if ! grep -Fxq "$line" "$file"; then
        echo "$line" >> "$file"
        log_success "Added to $file: $line"
    fi
}

# Verify user is root (or sudo)
check_root() {
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_warn "[DRY RUN] Skipping root check"
        return
    fi

    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root or with sudo"
        exit 1
    fi
}

# Verify internet connection
check_internet() {
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Skipping internet check"
        return
    fi

    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log_error "No internet connection available"
        exit 1
    fi
}

# Validation helper
validate_command() {
    local cmd="$1"
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_success "[DRY RUN] $cmd validation passed (mock)"
    elif command_exists "$cmd"; then
        log_success "$cmd is accessible"
    else
        log_error "$cmd is missing"
    fi
}