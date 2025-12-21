#!/bin/bash

################################################################################
# Fedora Python Development Setup - Step 2: Git Configuration
# Description: Configure Git with user info, SSH keys, and GitHub CLI
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

read_input() {
    local prompt="$1"
    local var_name="$2"
    local default="${3:-}"
    
    if [[ -n "$default" ]]; then
        echo -n -e "${BLUE}?​${NC} $prompt [${YELLOW}$default${NC}]: "
    else
        echo -n -e "${BLUE}?​${NC} $prompt: "
    fi
    
    read -r value
    
    if [[ -z "$value" && -n "$default" ]]; then
        value="$default"
    fi
    
    eval "$var_name='$value'"
}

################################################################################
# Step 1: Get Git User Information
################################################################################

echo ""
log_info "Git Configuration Setup"
echo ""
log_info "Please provide your Git user information:"
echo ""

# Check if git is already configured
if git config --global user.name &>/dev/null; then
    CURRENT_NAME=$(git config --global user.name)
    CURRENT_EMAIL=$(git config --global user.email)
    log_info "Current Git config:"
    echo "  Name: $CURRENT_NAME"
    echo "  Email: $CURRENT_EMAIL"
    echo ""
    echo -n -e "${BLUE}?​${NC} Update Git configuration? [y/N]: "
    read -r update_git
    if [[ "$update_git" != "y" && "$update_git" != "Y" ]]; then
        log_info "Skipping Git user configuration (already configured)"
        SKIP_GIT_CONFIG=true
    else
        SKIP_GIT_CONFIG=false
    fi
else
    SKIP_GIT_CONFIG=false
fi

if [[ "$SKIP_GIT_CONFIG" != "true" ]]; then
    read_input "Git user name" GIT_NAME "$(whoami)"
    read_input "Git user email" GIT_EMAIL ""
    
    if [[ -z "$GIT_EMAIL" ]]; then
        log_error "Email is required for Git configuration"
        exit 1
    fi
    
    # Configure git
    log_info "Configuring Git globally..."
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    log_success "Git user configured: $GIT_NAME <$GIT_EMAIL>"
fi

################################################################################
# Step 2: Git Preferences
################################################################################

log_info "Configuring Git preferences..."

# Set default branch name to main
git config --global init.defaultBranch main
log_success "Default branch set to 'main'"

# Configure color output
git config --global color.ui true
log_success "Color output enabled"

# Configure pull to rebase by default (prevents merge commits)
git config --global pull.rebase true
log_success "Pull configured to use rebase"

# Set core editor to neovim if available, otherwise nano
if command -v nvim &> /dev/null; then
    git config --global core.editor nvim
    log_success "Core editor set to nvim"
elif command -v vim &> /dev/null; then
    git config --global core.editor vim
    log_success "Core editor set to vim"
else
    git config --global core.editor nano
    log_success "Core editor set to nano"
fi

################################################################################
# Step 3: SSH Key Setup
################################################################################

log_info "Checking SSH key setup..."

SSH_KEY="$HOME/.ssh/id_ed25519"
SSH_PUBKEY="$HOME/.ssh/id_ed25519.pub"

if [[ -f "$SSH_KEY" ]]; then
    log_success "SSH key found at $SSH_KEY"
    
    # Add to SSH agent
    if command -v ssh-add &> /dev/null; then
        eval "$(ssh-agent -s)" &>/dev/null || true
        ssh-add "$SSH_KEY" 2>/dev/null || true
        log_success "SSH key added to ssh-agent"
    fi
else
    log_warning "No SSH key found. Creating one now..."
    echo ""
    read_input "SSH key email (for identification)" SSH_EMAIL "$GIT_EMAIL"
    
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$SSH_KEY" -N ""
    log_success "SSH key created at $SSH_KEY"
    
    # Set proper permissions
    chmod 600 "$SSH_KEY"
    chmod 644 "$SSH_PUBKEY"
    
    # Add to SSH config for GitHub
    SSH_CONFIG="$HOME/.ssh/config"
    if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
        echo "" >> "$SSH_CONFIG"
        cat >> "$SSH_CONFIG" << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes
EOF
        chmod 600 "$SSH_CONFIG"
        log_success "SSH config updated for GitHub"
    fi
    
    echo ""
    log_warning "Next step: Add your SSH public key to GitHub"
    echo "  Public key file: $SSH_PUBKEY"
    echo "  GitHub SSH Keys: https://github.com/settings/keys"
    echo ""
    echo "  To display your public key:"
    echo "    cat $SSH_PUBKEY"
    echo ""
fi

################################################################################
# Step 4: GitHub CLI (gh) Authentication
################################################################################

if command -v gh &> /dev/null; then
    log_info "GitHub CLI (gh) is installed"
    
    if gh auth status &>/dev/null; then
        log_success "GitHub CLI is already authenticated"
    else
        echo ""
        log_info "Authenticating with GitHub..."
        echo "  You'll be prompted to choose an authentication method."
        echo "  SSH is recommended since you just set up SSH keys."
        echo ""
        gh auth login
    fi
else
    log_warning "GitHub CLI (gh) not installed. Install with: sudo dnf install gh"
fi

################################################################################
# Step 5: Display Git Configuration
################################################################################

echo ""
log_success "Git configuration complete!"
echo ""
log_info "Current Git configuration:"
git config --global --list | grep -E '^user\.|^core\.|^init\.|^pull\.' || true
echo ""

################################################################################
# Summary
################################################################################

echo "Next steps:"
echo "  1. If you created a new SSH key, add it to GitHub (see instructions above)"
echo "  2. Run: sudo bash scripts/03-python-setup.sh"
echo "  3. Then: bash scripts/04-vscodium-setup.sh"
echo ""
log_info "For detailed information, see docs/SETUP_GUIDE.md"
echo ""
