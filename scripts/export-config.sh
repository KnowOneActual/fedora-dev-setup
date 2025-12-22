#!/bin/bash
# scripts/export-config.sh
# Phase 2: Backup & Restore
# Exports system configuration, package lists, and dotfiles to a portable archive.

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"

log_header "Phase 2: Configuration Export"

# Setup backup location
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_ROOT="$HOME/fedora-backups"
BACKUP_DIR="$BACKUP_ROOT/backup_$TIMESTAMP"
ARCHIVE_NAME="$BACKUP_ROOT/fedora_dev_backup_$TIMESTAMP.tar.gz"

ensure_directory "$BACKUP_DIR" "$(whoami)"

#######################################
# 1. Export Package Lists
#######################################
log_info "Exporting package lists..."
mkdir -p "$BACKUP_DIR/packages"

# System Packages (DNF)
if command_exists "dnf"; then
    dnf repoquery --userinstalled --queryformat '%{name}' > "$BACKUP_DIR/packages/dnf_installed.txt"
    log_success "Exported DNF package list"
fi

# Python Tools (pipx)
if command_exists "pipx"; then
    pipx list --short > "$BACKUP_DIR/packages/pipx_installed.txt" 2>/dev/null
    log_success "Exported pipx tool list"
fi

# VSCodium Extensions
if command_exists "codium"; then
    codium --list-extensions > "$BACKUP_DIR/packages/vscode_extensions.txt"
    log_success "Exported VSCodium extensions list"
fi

#######################################
# 2. Backup Config Files
#######################################
log_info "Backing up configuration files..."
mkdir -p "$BACKUP_DIR/configs"

# Shell & Git
FILES_TO_BACKUP=(
    "$HOME/.bashrc"
    "$HOME/.zshrc"
    "$HOME/.gitconfig"
    "$HOME/.ssh/config"
)

for file in "${FILES_TO_BACKUP[@]}"; do
    if [[ -f "$file" ]]; then
        cp "$file" "$BACKUP_DIR/configs/$(basename "$file")"
        log_success "Backed up $(basename "$file")"
    else
        log_warn "Skipped missing file: $file"
    fi
done

# VSCodium Settings
VSCODE_USER_DIR="$HOME/.config/VSCodium/User"
if [[ -d "$VSCODE_USER_DIR" ]]; then
    mkdir -p "$BACKUP_DIR/configs/vscode"
    cp "$VSCODE_USER_DIR/settings.json" "$BACKUP_DIR/configs/vscode/" 2>/dev/null
    cp "$VSCODE_USER_DIR/keybindings.json" "$BACKUP_DIR/configs/vscode/" 2>/dev/null
    log_success "Backed up VSCodium settings"
fi

#######################################
# 3. Create Archive
#######################################
log_info "Compressing backup archive..."

# Create tarball
tar -czf "$ARCHIVE_NAME" -C "$BACKUP_ROOT" "backup_$TIMESTAMP"

# Cleanup uncompressed folder
rm -rf "$BACKUP_DIR"

log_success "Backup complete!"
echo ""
echo -e "${BLUE}Archive created at:${NC} $ARCHIVE_NAME"
echo -e "${BLUE}Size:${NC} $(du -h "$ARCHIVE_NAME" | cut -f1)"