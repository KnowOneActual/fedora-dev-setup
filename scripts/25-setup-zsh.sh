#!/bin/bash
# scripts/25-setup-zsh.sh
# Phase 2.5: Shell Configuration
# Installs Oh My Zsh, plugins, and ports user aliases/functions.

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
# Fallback if libs are missing (during dev)
if [[ -f "$LIB_DIR/logging.sh" ]]; then
    source "$LIB_DIR/logging.sh"
    source "$LIB_DIR/utils.sh"
else
    echo "Libraries not found, using simple fallback"
    log_header() { echo "=== $1 ==="; }
    log_info() { echo "[INFO] $1"; }
    log_success() { echo "[OK] $1"; }
    check_internet() { return 0; }
    ensure_directory() { mkdir -p "$1"; }
fi

log_header "Phase 2.5: Shell Configuration"

check_internet

ACTUAL_USER="${SUDO_USER:-$(whoami)}"
ACTUAL_HOME=$(eval echo "~$ACTUAL_USER")

#######################################
# 1. Install Oh My Zsh (Unattended)
#######################################
if [[ ! -d "$ACTUAL_HOME/.oh-my-zsh" ]]; then
    log_info "Installing Oh My Zsh..."
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would clone Oh My Zsh"
    else
        # Run as user
        sudo -u "$ACTUAL_USER" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
else
    log_info "Oh My Zsh already installed"
fi

#######################################
# 2. Install Zsh Plugins
#######################################
ZSH_CUSTOM="$ACTUAL_HOME/.oh-my-zsh/custom"
PLUGINS_DIR="$ZSH_CUSTOM/plugins"

ensure_directory "$PLUGINS_DIR" "$ACTUAL_USER"

# Zsh Syntax Highlighting
if [[ ! -d "$PLUGINS_DIR/zsh-syntax-highlighting" ]]; then
    log_info "Installing zsh-syntax-highlighting..."
    if [[ "${DRY_RUN:-}" != "true" ]]; then
        sudo -u "$ACTUAL_USER" git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGINS_DIR/zsh-syntax-highlighting"
    fi
else
    log_info "zsh-syntax-highlighting already installed"
fi

# Zsh Autosuggestions
if [[ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ]]; then
    log_info "Installing zsh-autosuggestions..."
    if [[ "${DRY_RUN:-}" != "true" ]]; then
        sudo -u "$ACTUAL_USER" git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions"
    fi
else
    log_info "zsh-autosuggestions already installed"
fi

#######################################
# 3. Inject User Configuration
#######################################
ZSHRC="$ACTUAL_HOME/.zshrc"
log_info "Injecting custom configuration into .zshrc..."

# We append a block if it's not already there
if grep -q "Fedora Dev Setup: Custom Aliases" "$ZSHRC" 2>/dev/null; then
    log_info "Custom configuration already present in .zshrc"
else
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would append aliases to $ZSHRC"
    else
        # Backup first
        if [[ -f "$ZSHRC" ]]; then
             cp "$ZSHRC" "${ZSHRC}.backup.$(date +%s)"
        fi
        
        # Append the specific aliases and functions from your zshrc
        cat >> "$ZSHRC" << 'EOF'

# --- Fedora Dev Setup: Custom Aliases ---
# Python & Virtual Envs
alias py='python3'
alias z='zoxide'
alias venv='python3 -m venv .venv && source .venv/bin/activate'

# Git shortcuts
alias gc="git commit -m"
alias gp="git push origin HEAD"
alias gst="git status"
alias ga='git add -p'
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"

# --- Tools ---
# Initialize zoxide (smart cd)
eval "$(zoxide init zsh)"

# Initialize thefuck (auto-correct)
eval $(thefuck --alias)

# --- Functions ---

# Yazi Wrapper (Shell integration)
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# cheat.sh wrapper
cs() {
  curl "https://cheat.sh/${(j:+:)@}"
}
EOF
        
        # Enable plugins in .zshrc (simple replacement)
        # Replaces the default plugins line with our enhanced list
        sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions thefuck)/' "$ZSHRC"
        
        log_success "Shell configuration updated"
    fi
fi

log_success "Phase 2.5: Shell Setup Complete"