#!/bin/bash
# scripts/15-git-ssh-setup.sh
# Phase 2.1: Git & SSH Configuration

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"

log_header "Phase 2.1: Git & SSH Setup"

ACTUAL_USER="${SUDO_USER:-$(whoami)}"
ACTUAL_HOME=$(eval echo "~$ACTUAL_USER")
SSH_DIR="$ACTUAL_HOME/.ssh"
KEY_PATH="$SSH_DIR/id_ed25519"

#######################################
# 1. Configure Git Identity
#######################################
log_info "Configuring Git identity..."
CURRENT_NAME=$(sudo -u "$ACTUAL_USER" git config --global user.name || echo "")
CURRENT_EMAIL=$(sudo -u "$ACTUAL_USER" git config --global user.email || echo "")

if [[ -z "$CURRENT_NAME" || "$DRY_RUN" == "true" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would prompt for Git name and email"
    else
        read -r -p "Enter your full name for Git: " git_name
        read -r -p "Enter your email for Git: " git_email
        sudo -u "$ACTUAL_USER" git config --global user.name "$git_name"
        sudo -u "$ACTUAL_USER" git config --global user.email "$git_email"
        log_success "Git identity configured"
    fi
else
    log_info "Git identity already set: $CURRENT_NAME ($CURRENT_EMAIL)"
fi

#######################################
# 2. Generate SSH Key
#######################################
if [[ ! -f "$KEY_PATH" ]]; then
    log_info "No SSH key found. Generating a new Ed25519 key..."
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would generate $KEY_PATH"
    else
        ensure_directory "$SSH_DIR" "$ACTUAL_USER"
        sudo -u "$ACTUAL_USER" ssh-keygen -t ed25519 -C "$(sudo -u "$ACTUAL_USER" git config --global user.email)" -f "$KEY_PATH" -N ""
        log_success "SSH key generated at $KEY_PATH"
    fi
else
    log_info "SSH key already exists at $KEY_PATH"
fi

#######################################
# 3. SSH Agent Persistence
#######################################
log_info "Ensuring SSH agent persists in shell..."
AGENT_CONFIG='if [ -z "$SSH_AUTH_SOCK" ]; then eval "$(ssh-agent -s)" >/dev/null; ssh-add '"$KEY_PATH"' 2>/dev/null; fi'

if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY RUN] Would add ssh-agent logic to .bashrc and .zshrc"
else
    ensure_in_path "$AGENT_CONFIG" "$ACTUAL_HOME/.bashrc" "$ACTUAL_USER"
    ensure_in_path "$AGENT_CONFIG" "$ACTUAL_HOME/.zshrc" "$ACTUAL_USER"
    log_success "SSH agent configuration added to shell profiles"
fi

#######################################
# 4. HTTPS to SSH Conversion (Optional)
#######################################
if [[ "$DRY_RUN" != "true" ]]; then
    read -r -p "Do you want to scan and convert existing HTTPS repos to SSH? [y/N]: " convert_choice
    if [[ "$convert_choice" =~ ^[Yy]$ ]]; then
        read -r -p "Enter the directory to scan (e.g., ~/projects): " scan_dir
        scan_dir_full=$(eval echo "$scan_dir")
        
        if [[ -d "$scan_dir_full" ]]; then
            log_info "Scanning $scan_dir_full for HTTPS remotes..."
            find "$scan_dir_full" -name ".git" -type d | while read -r gitdir; do
                repo_dir=$(dirname "$gitdir")
                current_url=$(cd "$repo_dir" && git remote get-url origin 2>/dev/null || echo "")
                
                if [[ $current_url == https://github.com/* ]]; then
                    new_url=$(echo "$current_url" | sed 's|https://github.com/|git@github.com:|')
                    (cd "$repo_dir" && git remote set-url origin "$new_url")
                    log_success "Converted $repo_dir to SSH"
                fi
            done
        else
            log_warn "Directory $scan_dir_full not found. Skipping conversion."
        fi
    fi
fi

#######################################
# 5. Instructions for GitHub
#######################################
if [[ "$DRY_RUN" != "true" ]]; then
    echo ""
    log_info "FINAL STEP: Add this key to your GitHub account"
    echo "-----------------------------------------------------"
    cat "${KEY_PATH}.pub"
    echo "-----------------------------------------------------"
    echo "1. Copy the key above."
    echo "2. Go to: https://github.com/settings/ssh/new"
    echo "3. Paste it and save."
    echo ""
    read -r -p "Press Enter once you have added the key to test the connection..."
    ssh -T git@github.com 2>&1 | grep -q "successfully authenticated" && log_success "GitHub connection verified!" || log_warn "Could not verify connection. You may need to add the key to GitHub first."
fi

log_success "Git and SSH setup complete!"