#!/bin/bash
# scripts/lib/utils.sh
# Shared utility functions for Fedora Dev Setup

# Prevent double sourcing
[[ -n "${_UTILS_SH_LOADED:-}" ]] && return
_UTILS_SH_LOADED=true

# Get directory of this script
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure logging is loaded
if [[ -z "${_LOGGING_SH_LOADED:-}" ]]; then
    if [[ -f "$LIB_DIR/logging.sh" ]]; then
        source "$LIB_DIR/logging.sh"
    else
        echo "Error: logging.sh not found" >&2
        exit 1
    fi
fi

#######################################
# System Checks
#######################################

is_fedora() {
    [[ -f /etc/os-release ]] && grep -q "ID=fedora" /etc/os-release
}

get_fedora_version() {
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        echo "40" # Mock version for testing
        return 0
    fi
    rpm -E %fedora
}

check_root() {
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_warn "[DRY RUN] Skipping root check"
        return 0
    fi

    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_internet() {
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Skipping internet check"
        return 0
    fi

    if ! ping -c 1 google.com &> /dev/null; then
        log_error "No internet connection detected"
        return 1
    fi
}

#######################################
# Package Management
#######################################

package_installed() {
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        return 1 # Pretend nothing is installed so we see installation logic
    fi
    rpm -q "$1" &> /dev/null
}

command_exists() {
    command -v "$1" &> /dev/null
}

install_dnf_packages() {
    local packages=("$@")
    
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would install dnf packages: ${packages[*]}"
        return 0
    fi

    local to_install=()
    log_info "Checking ${#packages[@]} system packages..."

    for pkg in "${packages[@]}"; do
        if ! package_installed "$pkg"; then
            to_install+=("$pkg")
        fi
    done

    if [[ ${#to_install[@]} -eq 0 ]]; then
        log_success "All packages already installed"
        return 0
    fi

    log_info "Installing missing packages: ${to_install[*]}"
    dnf install -y "${to_install[@]}"
    
    # Verify installation
    local failed=0
    for pkg in "${to_install[@]}"; do
        if ! package_installed "$pkg"; then
            log_error "Failed to install: $pkg"
            failed=$((failed + 1))
        fi
    done

    return $failed
}

#######################################
# File & Directory Operations
#######################################

ensure_directory() {
    local dir="$1"
    local user="${2:-$SUDO_USER}"
    
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would create directory: $dir (owner: ${user:-current})"
        return 0
    fi
    
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        if [[ -n "$user" ]]; then
            chown -R "$user:$user" "$dir"
        fi
        log_success "Created directory: $dir"
    fi
}

backup_file() {
    local file="$1"
    
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would backup file: $file"
        return 0
    fi

    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        log_info "Backed up $file to $backup"
    fi
}

download_file() {
    local url="$1"
    local dest="$2"
    
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would download $url to $dest"
        return 0
    fi
    
    log_info "Downloading $url..."
    if curl -L -o "$dest" "$url"; then
        log_success "Downloaded to $dest"
    else
        log_error "Failed to download $url"
        return 1
    fi
}

#######################################
# Path & Configuration
#######################################

ensure_in_path() {
    local path_entry="$1"
    local rc_file="$2"
    local user="${3:-$SUDO_USER}"
    
    # Expand ~ if present
    rc_file="${rc_file/#\~/$HOME}"
    
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would add '$path_entry' to $rc_file"
        return 0
    fi
    
    if [[ ! -f "$rc_file" ]]; then
        touch "$rc_file"
        chown "$user:$user" "$rc_file"
    fi
    
    if ! grep -qF "$path_entry" "$rc_file"; then
        echo "" >> "$rc_file"
        echo "export PATH=\"$path_entry:\$PATH\"" >> "$rc_file"
        log_success "Added $path_entry to $rc_file"
    fi
}

#######################################
# Validation & Output
#######################################

validate_command() {
    local cmd="$1"
    local name="${2:-$cmd}"
    
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_success "[DRY RUN] $name validation passed (mock)"
        return 0
    fi
    
    if command_exists "$cmd"; then
        log_success "$name is available"
        return 0
    else
        log_error "$name is missing"
        return 1
    fi
}

print_success_list() {
    local title="$1"
    shift
    local items=("$@")
    
    echo ""
    log_success "$title"
    for item in "${items[@]}"; do
        echo -e "  ${GREEN}✓${NC} $item"
    done
}