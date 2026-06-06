#!/bin/bash
# scripts/restore-config.sh
# Phase 2: Backup & Restore
# Restores system configuration from a backup archive.

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"

log_header "Phase 2: Configuration Restore"

ACTUAL_USER="${SUDO_USER:-$(whoami)}"
ACTUAL_HOME=$(eval echo "~$ACTUAL_USER")
BACKUP_ROOT="$ACTUAL_HOME/fedora-backups"
BACKUP_ARCHIVE=""

# Interactive search if no argument specified
if [[ -z "${1:-}" ]]; then
    log_info "No backup archive specified. Scanning $BACKUP_ROOT..."
    if [[ -d "$BACKUP_ROOT" ]]; then
        # Find all .tar.gz backups, sorted by modification time (newest first)
        mapfile -t backups < <(find "$BACKUP_ROOT" -maxdepth 1 -name "fedora_dev_backup_*.tar.gz" -type f -printf "%T@ %p\n" 2>/dev/null | sort -nr | cut -d' ' -f2-)
        
        if [[ ${#backups[@]} -gt 0 ]]; then
            log_info "Found ${#backups[@]} backup(s):"
            for i in "${!backups[@]}"; do
                printf "  %2d) %s\n" "$((i+1))" "$(basename "${backups[i]}")"
            done
            echo ""
            read -r -p "Select backup to restore [1-${#backups[@]} or path to file]: " choice
            
            if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#backups[@]} )); then
                BACKUP_ARCHIVE="${backups[choice-1]}"
            elif [[ -f "$choice" ]]; then
                BACKUP_ARCHIVE="$choice"
            else
                log_error "Invalid selection or file not found."
                exit 1
            fi
        else
            log_warn "No backups found in $BACKUP_ROOT."
        fi
    fi

    # If still empty, prompt manually
    if [[ -z "$BACKUP_ARCHIVE" ]]; then
        read -r -p "Please enter the absolute path to your backup archive (.tar.gz): " manual_path
        if [[ -f "$manual_path" ]]; then
            BACKUP_ARCHIVE="$manual_path"
        else
            log_error "File not found: $manual_path"
            exit 1
        fi
    fi
else
    BACKUP_ARCHIVE="$1"
fi

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

# Find the inner directory
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
        install_dnf_packages_best_effort "${PACKAGE_LIST[@]}"
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

# Flatpak Apps (NEW)
if [[ -f "$BACKUP_DIR/packages/flatpak_installed.txt" ]]; then
    log_info "Restoring Flatpak applications..."
    
    # Ensure remote exists
    if ! command_exists "flatpak"; then
        install_dnf_packages_best_effort "flatpak"
    fi
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    while read -r app; do
        if [[ -n "$app" ]]; then
            if [[ "${DRY_RUN:-}" == "true" ]]; then
                log_info "[DRY RUN] Would install Flatpak: $app"
            else
                flatpak install -y flathub "$app" || log_warn "Failed to install $app"
            fi
        fi
    done < "$BACKUP_DIR/packages/flatpak_installed.txt"
    log_success "Flatpaks processed"
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
    FILES=(".bashrc" ".zshrc" ".gitconfig" ".tmux.conf" ".zprofile" ".profile")
    
    for file in "${FILES[@]}"; do
        if [[ -f "$CONFIGS_SRC/$file" ]]; then
            if [[ "${DRY_RUN:-}" == "true" ]]; then
                 log_info "[DRY RUN] Would restore $file to $ACTUAL_HOME/$file"
            else
                 backup_file "$ACTUAL_HOME/$file"
                 cp "$CONFIGS_SRC/$file" "$ACTUAL_HOME/$file"
                 chown "$ACTUAL_USER:$ACTUAL_USER" "$ACTUAL_HOME/$file"
                 log_success "Restored $file"
            fi
        fi
    done

    # SSH Config
    if [[ -f "$CONFIGS_SRC/config" ]]; then
        if [[ "${DRY_RUN:-}" == "true" ]]; then
             log_info "[DRY RUN] Would restore SSH config"
        else
             mkdir -p "$ACTUAL_HOME/.ssh"
             chmod 700 "$ACTUAL_HOME/.ssh"
             backup_file "$ACTUAL_HOME/.ssh/config"
             cp "$CONFIGS_SRC/config" "$ACTUAL_HOME/.ssh/config"
             chmod 600 "$ACTUAL_HOME/.ssh/config"
             chown -R "$ACTUAL_USER:$ACTUAL_USER" "$ACTUAL_HOME/.ssh"
             log_success "Restored SSH config"
        fi
    fi

    # Zsh Custom Configuration
    if [[ -d "$CONFIGS_SRC/zsh-custom" ]]; then
        if [[ "${DRY_RUN:-}" == "true" ]]; then
             log_info "[DRY RUN] Would restore zsh-custom directory to $ACTUAL_HOME/.config/zsh-custom"
        else
             if [[ -d "$ACTUAL_HOME/.config/zsh-custom" ]]; then
                 mv "$ACTUAL_HOME/.config/zsh-custom" "$ACTUAL_HOME/.config/zsh-custom.backup.$(date +%s)"
             fi
             mkdir -p "$ACTUAL_HOME/.config"
             cp -r "$CONFIGS_SRC/zsh-custom" "$ACTUAL_HOME/.config/zsh-custom"
             chown -R "$ACTUAL_USER:$ACTUAL_USER" "$ACTUAL_HOME/.config/zsh-custom"
             log_success "Restored zsh-custom directory"
        fi
    fi

    # GNOME/dconf settings
    if [[ -f "$CONFIGS_SRC/dconf_settings.ini" ]]; then
        if [[ "${DRY_RUN:-}" == "true" ]]; then
            log_info "[DRY RUN] Would restore GNOME/dconf settings from dconf_settings.ini"
        elif command_exists "dconf"; then
            # Run dconf as the actual user to modify their session database
            # shellcheck disable=SC2024
            sudo -u "$ACTUAL_USER" dconf load / < "$CONFIGS_SRC/dconf_settings.ini" 2>/dev/null || log_warn "Failed to restore GNOME/dconf settings (are you in a graphical session?)"
            log_success "Restored GNOME/dconf settings"
        fi
    fi
    
    # VSCodium Settings
    if [[ -d "$CONFIGS_SRC/vscode" ]]; then
        VS_USER_DIR="$ACTUAL_HOME/.config/VSCodium/User"
        
        if [[ "${DRY_RUN:-}" == "true" ]]; then
            log_info "[DRY RUN] Would restore VSCodium settings.json"
        else
            ensure_directory "$VS_USER_DIR" "$ACTUAL_USER"
            cp "$CONFIGS_SRC/vscode/"* "$VS_USER_DIR/" 2>/dev/null
            chown -R "$ACTUAL_USER:$ACTUAL_USER" "$VS_USER_DIR"
            log_success "Restored VSCodium settings"
        fi
    fi
fi

# Cleanup
rm -rf "$RESTORE_ROOT"
log_success "Restore complete!"