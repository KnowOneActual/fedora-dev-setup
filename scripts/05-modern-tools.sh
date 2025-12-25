#!/bin/bash
# scripts/05-modern-tools.sh
# Phase 1.5: Modern CLI Toolchain

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"

log_header "Phase 1.5: Modern CLI Tools"

check_root
check_internet

ACTUAL_USER="${SUDO_USER:-$(whoami)}"
USER_HOME=$(getent passwd "$ACTUAL_USER" | cut -d: -f6)

#######################################
# 1. Install Toolchain
#######################################
# eza: Better 'ls' | bat: Better 'cat' | fd-find: Better 'find'
# du-dust: Better 'du' | git-delta: Better 'git diff'
# ripgrep: Better 'grep' | zoxide: Better 'cd' | bottom: Better 'top'
TOOLS=(
    "eza" 
    "bat" 
    "fd-find" 
    "du-dust" 
    "git-delta" 
    "ripgrep" 
    "fzf" 
    "zoxide" 
    "bottom" 
    "tldr"
)

log_info "Installing modern CLI utilities..."
install_dnf_packages "${TOOLS[@]}"

#######################################
# 2. Configure Git Delta
#######################################
log_info "Configuring Git Delta for improved terminal diffs..."

if [[ "${DRY_RUN:-}" == "true" ]]; then
    log_info "[DRY RUN] Would configure git to use delta"
else
    sudo -u "$ACTUAL_USER" git config --global core.pager "delta"
    sudo -u "$ACTUAL_USER" git config --global interactive.diffFilter "delta --color-only"
    sudo -u "$ACTUAL_USER" git config --global delta.side-by-side true
    sudo -u "$ACTUAL_USER" git config --global delta.line-numbers true
    log_success "Git Delta configured"
fi

#######################################
# 3. Configure Shell Aliases & QoL
#######################################
log_info "Setting up shell aliases and QoL improvements..."

# Define the configuration block
read -r -d '' ALIAS_BLOCK << EOM

# --- Modern Tool Aliases ---
alias ls='eza --group-directories-first --icons'
alias cat='bat --style=plain --paging=never'
alias grep='rg'
alias du='dust'
alias top='btm'
alias fd='fdfind'
alias cd='z'
eval "\$(zoxide init bash)"
# ---------------------------
EOM

if [[ "${DRY_RUN:-}" == "true" ]]; then
    log_info "[DRY RUN] Would append aliases to $USER_HOME/.bashrc"
else
    # Check if the block already exists to avoid duplicates
    if ! grep -q "Modern Tool Aliases" "$USER_HOME/.bashrc"; then
        echo "$ALIAS_BLOCK" >> "$USER_HOME/.bashrc"
        # Ensure the user still owns their bashrc
        chown "$ACTUAL_USER:$ACTUAL_USER" "$USER_HOME/.bashrc"
        log_success "Aliases added to $USER_HOME/.bashrc"
    else
        log_info "Aliases already present in .bashrc, skipping injection."
    fi
    
    # Initialize tldr cache as the user
    sudo -u "$ACTUAL_USER" tldr --update
fi

log_success "Modern CLI toolchain setup complete!"