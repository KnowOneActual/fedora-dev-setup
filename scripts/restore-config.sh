#!/bin/bash
# scripts/restore-config.sh
# Phase 2: Backup & Restore
# Restores system configuration from a backup archive.

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"

log_header "Phase 2: Configuration Restore"

# Usage check
if [[ -z "$1" ]]; then
    log_error "Usage: $0 <path_to_backup.tar.gz>"
    exit 1
fi

BACKUP_ARCHIVE="$1"
RESTORE_ROOT="/tmp/fedora-restore-$(date +%s)"

# Pre-flight checks
if [[ ! -f "$BACKUP_ARCHIVE" ]]; then
    log_error "Backup file not found: $BACKUP_ARCHIVE"
    exit 1
fi

#######################################
# 1. Extract Archive
#######################################
log_info "Extracting archive..."
mkdir -p "$RESTORE_ROOT"
tar -xzf "$BACKUP_ARCHIVE" -C "$RESTORE_ROOT"

# Find the inner directory (it's inside a folder named backup_YYYYMMDD...)
BACKUP_DIR=$(find "$RESTORE_ROOT" -maxdepth 1 -type d -name "backup_*" | head -n 1)

if [[ -z "$BACKUP_DIR" ]]; then
    log_error "Invalid backup structure (could not find backup directory)"
    exit 1
fi

log_success "Extracted to $BACKUP_DIR"

#######################################
# 2. Restore System Packages
#######################################
log_info "Restoring package selections..."

# DNF Packages
if [[ -f "$BACKUP_DIR/packages/dnf_installed.txt" ]]; then
    mapfile -t PACKAGE_LIST < "$BACKUP_DIR/packages/dnf_installed.txt"
    
    if [[ ${#PACKAGE_LIST[@]} -gt 0 ]]; then
        log_info "Found ${#PACKAGE_LIST[@]} packages in backup. Checking for missing ones..."
        install_dnf_packages "${PACKAGE_LIST[@]}"
    fi
fi

# Pipx Tools
if [[ -f "$BACKUP_DIR/packages/pipx_installed.txt" ]]; then
    log_info "Restoring pipx tools..."
    while read -r tool; do
        pkg_name=$(echo "$tool" | awk '{print $1}')
        if [[ -n "$pkg_name" ]]; then
            if ! command_exists "$pkg_name"; then
                 if [[ "${DRY_RUN:-}" == "true" ]]; then
                    log_info "[DRY RUN] Would install pipx tool: $pkg_name"
                 else
                    pipx install "$pkg_name" 2>/dev/null || log_warn "Failed to reinstall $pkg_name"
                 fi
            fi
        fi
    done < "$BACKUP_DIR/packages/pipx_installed.txt"
fi

#######################################
# 3. Restore VSCodium Extensions
#######################################
if [[ -f "$BACKUP_DIR/packages/vscode_extensions.txt" ]]; then
    log_info "Restoring VSCodium extensions..."
    while read -r ext; do
        if [[ -n "$ext" ]]; then
            if [[ "${DRY_RUN:-}" == "true" ]]; then
                log_info "[DRY RUN] Would install extension: $ext"
            else
                sudo -u "$SUDO_USER" codium --install-extension "$ext" --force >/dev/null 2>&1 || log_warn "Failed to install $ext"
            fi
        fi
    done < "$BACKUP_DIR/packages/vscode_extensions.txt"
    log_success "Extensions processed"
fi

#######################################
# 4. Restore Config Files
#######################################
log_info "Restoring configuration files..."

# Restore Shell Configs
CONFIGS_SRC="$BACKUP_DIR/configs"
if [[ -d "$CONFIGS_SRC" ]]; then
    # TYPO FIXED HERE: ".bashrc" instead of "bjashrc"
    FILES=(".bashrc" ".zshrc" ".gitconfig")
    
    for file in "${FILES[@]}"; do
        if [[ -f "$CONFIGS_SRC/$file" ]]; then
            if [[ "${DRY_RUN:-}" == "true" ]]; then
                 log_info "[DRY RUN] Would restore $file to $HOME/$file"
            else
                 backup_file "$HOME/$file"
                 cp "$CONFIGS_SRC/$file" "$HOME/$file"
                 log_success "Restored $file"
            fi
        fi
    done

    # SSH Config
    if [[ -f "$CONFIGS_SRC/config" ]]; then
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        if [[ "${DRY_RUN:-}" == "true" ]]; then
             log_info "[DRY RUN] Would restore SSH config"
        else
             backup_file "$HOME/.ssh/config"
             cp "$CONFIGS_SRC/config" "$HOME/.ssh/config"
             chmod 600 "$HOME/.ssh/config"
             log_success "Restored SSH config"
        fi
    fi
    
    # VSCodium Settings
    if [[ -d "$CONFIGS_SRC/vscode" ]]; then
        VS_USER_DIR="$HOME/.config/VSCodium/User"
        ensure_directory "$VS_USER_DIR" "$SUDO_USER"
        
        if [[ "${DRY_RUN:-}" == "true" ]]; then
            log_info "[DRY RUN] Would restore VSCodium settings.json"
        else
            cp "$CONFIGS_SRC/vscode/"* "$VS_USER_DIR/" 2>/dev/null
            log_success "Restored VSCodium settings"
        fi
    fi
fi

# Cleanup
rm -rf "$RESTORE_ROOT"
log_success "Restore complete!"