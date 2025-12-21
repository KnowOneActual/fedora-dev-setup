#!/bin/bash

################################################################################
# Fedora Python Development Setup - Step 6: Configuration Backup/Restore
# Description: Backup and restore development environment configurations
# Author: Fedora Dev Setup Contributors
# Last Updated: December 2025
################################################################################

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[✗]${NC} $*" >&2
}

# Current user
ACTUAL_USER="${SUDO_USER:-$(whoami)}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)
BACKUP_DIR="${BACKUP_DIR:-$ACTUAL_HOME/.config/fedora-setup-backups}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

################################################################################
# Usage Function
################################################################################

usage() {
    echo "Usage: $0 [--backup|--restore <backup_file>|--list]"
    echo ""
    echo "Commands:"
    echo "  --backup              Create a backup of your development environment"
    echo "  --restore <file>      Restore from a backup file"
    echo "  --list                List available backups"
    echo ""
    echo "Backup includes:"
    echo "  - VSCodium settings and extensions"
    echo "  - Git configuration"
    echo "  - Shell configuration and aliases"
    echo "  - Development directory structure"
    echo ""
    echo "Backup does NOT include:"
    echo "  - Project source code (use Git for this)"
    echo "  - Virtual environments (recreate with pip install)"
    echo "  - System packages (recreate with setup scripts)"
    exit 1
}

################################################################################
# Backup Function
################################################################################

backup_config() {
    log_info "Creating backup of development environment configuration..."
    echo ""
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    chown $ACTUAL_USER:$ACTUAL_USER "$BACKUP_DIR"
    
    # Create temporary backup staging area
    TEMP_BACKUP="/tmp/fedora-setup-backup-$TIMESTAMP"
    mkdir -p "$TEMP_BACKUP"
    
    # Backup VSCodium configuration
    if [[ -d "$ACTUAL_HOME/.config/VSCodium" ]]; then
        log_info "Backing up VSCodium configuration..."
        mkdir -p "$TEMP_BACKUP/vscode"
        cp -r "$ACTUAL_HOME/.config/VSCodium/User" "$TEMP_BACKUP/vscode/User" 2>/dev/null || true
        log_success "VSCodium config backed up"
    fi
    
    # Backup Git configuration
    if [[ -f "$ACTUAL_HOME/.gitconfig" ]]; then
        log_info "Backing up Git configuration..."
        mkdir -p "$TEMP_BACKUP/git"
        cp "$ACTUAL_HOME/.gitconfig" "$TEMP_BACKUP/git/.gitconfig"
        log_success "Git config backed up"
    fi
    
    # Backup shell configuration
    log_info "Backing up shell configuration..."
    mkdir -p "$TEMP_BACKUP/shell"
    [[ -f "$ACTUAL_HOME/.bashrc" ]] && cp "$ACTUAL_HOME/.bashrc" "$TEMP_BACKUP/shell/.bashrc"
    [[ -f "$ACTUAL_HOME/.bash_profile" ]] && cp "$ACTUAL_HOME/.bash_profile" "$TEMP_BACKUP/shell/.bash_profile"
    [[ -f "$ACTUAL_HOME/.zshrc" ]] && cp "$ACTUAL_HOME/.zshrc" "$TEMP_BACKUP/shell/.zshrc" 2>/dev/null || true
    log_success "Shell config backed up"
    
    # List installed VSCodium extensions
    log_info "Backing up VSCodium extensions list..."
    mkdir -p "$TEMP_BACKUP/extensions"
    if command -v codium &> /dev/null; then
        sudo -u $ACTUAL_USER codium --list-extensions > "$TEMP_BACKUP/extensions/extensions-list.txt" 2>/dev/null || true
        log_success "Extensions list backed up"
    fi
    
    # List Python versions installed via pyenv
    log_info "Backing up Python versions..."
    mkdir -p "$TEMP_BACKUP/python"
    if [[ -d "$ACTUAL_HOME/.pyenv" ]]; then
        sudo -u $ACTUAL_USER "$ACTUAL_HOME/.pyenv/bin/pyenv" versions > "$TEMP_BACKUP/python/versions.txt" 2>/dev/null || true
        log_success "Python versions backed up"
    fi
    
    # Create development directory structure snapshot
    log_info "Backing up development directory structure..."
    mkdir -p "$TEMP_BACKUP/dev-structure"
    find "$ACTUAL_HOME/dev" -type d -maxdepth 3 > "$TEMP_BACKUP/dev-structure/directories.txt" 2>/dev/null || true
    find "$ACTUAL_HOME/dev" -name "requirements.txt" -exec cp {} "$TEMP_BACKUP/dev-structure/" \; 2>/dev/null || true
    log_success "Development directory structure backed up"
    
    # Create metadata file
    cat > "$TEMP_BACKUP/BACKUP_INFO.txt" << EOF
Fedora Development Setup Backup
Created: $(date)
User: $ACTUAL_USER
Fedora Version: $(grep VERSION_ID /etc/os-release)
Python Version: $(python3 --version 2>&1)
VSCodium Version: $(codium --version 2>/dev/null || echo 'Not installed')

Contents:
  - VSCodium configuration and extensions list
  - Git configuration
  - Shell configuration and aliases
  - Python versions installed via pyenv
  - Development directory structure

To restore:
  bash scripts/06-config-backup.sh --restore backup_$TIMESTAMP.tar.gz
EOF
    
    # Create tarball
    log_info "Creating backup archive..."
    BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"
    
    cd /tmp
    tar -czf "$BACKUP_FILE" -C /tmp "fedora-setup-backup-$TIMESTAMP/" 2>/dev/null
    
    # Clean up temp directory
    rm -rf "$TEMP_BACKUP"
    
    # Set proper permissions
    chmod 600 "$BACKUP_FILE"
    chown $ACTUAL_USER:$ACTUAL_USER "$BACKUP_FILE"
    
    log_success "Backup created successfully!"
    echo ""
    log_info "Backup file: $BACKUP_FILE"
    log_info "Size: $(du -h "$BACKUP_FILE" | cut -f1)"
    echo ""
    log_info "To restore this backup on another machine:"
    echo "  bash scripts/06-config-backup.sh --restore $BACKUP_FILE"
    echo ""
}

################################################################################
# Restore Function
################################################################################

restore_config() {
    local backup_file="$1"
    
    if [[ ! -f "$backup_file" ]]; then
        log_error "Backup file not found: $backup_file"
        exit 1
    fi
    
    log_info "Restoring configuration from backup..."
    echo "WARNING: This will overwrite existing configurations!"
    echo -n "Are you sure you want to continue? [y/N]: "
    read -r confirm
    
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        log_warning "Restore cancelled"
        exit 0
    fi
    
    echo ""
    
    # Create temporary restore directory
    TEMP_RESTORE="/tmp/fedora-setup-restore-$TIMESTAMP"
    mkdir -p "$TEMP_RESTORE"
    
    # Extract backup
    log_info "Extracting backup archive..."
    tar -xzf "$backup_file" -C "$TEMP_RESTORE"
    RESTORE_DIR="$TEMP_RESTORE/fedora-setup-backup-"*
    
    # Restore VSCodium configuration
    if [[ -d "$RESTORE_DIR/vscode/User" ]]; then
        log_info "Restoring VSCodium configuration..."
        mkdir -p "$ACTUAL_HOME/.config/VSCodium"
        cp -r "$RESTORE_DIR/vscode/User" "$ACTUAL_HOME/.config/VSCodium/User" 2>/dev/null || true
        chown -R $ACTUAL_USER:$ACTUAL_USER "$ACTUAL_HOME/.config/VSCodium"
        log_success "VSCodium config restored"
    fi
    
    # Restore Git configuration
    if [[ -f "$RESTORE_DIR/git/.gitconfig" ]]; then
        log_info "Restoring Git configuration..."
        cp "$RESTORE_DIR/git/.gitconfig" "$ACTUAL_HOME/.gitconfig"
        chown $ACTUAL_USER:$ACTUAL_USER "$ACTUAL_HOME/.gitconfig"
        log_success "Git config restored"
    fi
    
    # Restore shell configuration
    if [[ -f "$RESTORE_DIR/shell/.bashrc" ]]; then
        log_info "Restoring shell configuration..."
        cp "$RESTORE_DIR/shell/.bashrc" "$ACTUAL_HOME/.bashrc"
        chown $ACTUAL_USER:$ACTUAL_USER "$ACTUAL_HOME/.bashrc"
        log_success "Shell config restored"
    fi
    
    # Restore development directory structure
    if [[ -f "$RESTORE_DIR/dev-structure/directories.txt" ]]; then
        log_info "Recreating development directory structure..."
        mkdir -p "$ACTUAL_HOME/dev/projects" "$ACTUAL_HOME/dev/scripts" "$ACTUAL_HOME/dev/experiments"
        chown -R $ACTUAL_USER:$ACTUAL_USER "$ACTUAL_HOME/dev"
        log_success "Development directory structure created"
    fi
    
    # List extensions to install
    if [[ -f "$RESTORE_DIR/extensions/extensions-list.txt" ]]; then
        log_info ""
        log_info "Available extensions from backup:"
        echo ""
        cat "$RESTORE_DIR/extensions/extensions-list.txt"
        echo ""
        log_info "To install these extensions, run:"
        echo "  while read ext; do codium --install-extension \"\$ext\"; done < extensions-list.txt"
    fi
    
    # Clean up
    rm -rf "$TEMP_RESTORE"
    
    echo ""
    log_success "Restore complete!"
    echo ""
    log_warning "Note: You may need to reinstall VSCodium extensions manually:"
    echo "  See the list above and run codium --install-extension for each"
    echo ""
}

################################################################################
# List Backups Function
################################################################################

list_backups() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log_info "No backups found. Create one with: $0 --backup"
        exit 0
    fi
    
    log_info "Available backups in $BACKUP_DIR:"
    echo ""
    
    if ls "$BACKUP_DIR"/backup_*.tar.gz 1> /dev/null 2>&1; then
        ls -lh "$BACKUP_DIR"/backup_*.tar.gz | awk '{print $9, "(" $5 ")"}'
    else
        log_info "No backups found"
    fi
    
    echo ""
}

################################################################################
# Main
################################################################################

if [[ $# -eq 0 ]]; then
    usage
fi

case "${1:-}" in
    --backup)
        backup_config
        ;;
    --restore)
        if [[ -z "${2:-}" ]]; then
            log_error "Please provide a backup file path"
            usage
        fi
        restore_config "$2"
        ;;
    --list)
        list_backups
        ;;
    -h|--help)
        usage
        ;;
    *)
        log_error "Unknown option: $1"
        usage
        ;;
esac
