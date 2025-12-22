#!/bin/bash
# scripts/40-languages.sh
# Phase 3: Extended Language Support
# Installs Node.js, Go, and Rust development stacks.

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"

log_header "Phase 3: Extended Language Support"

check_root
check_internet

ACTUAL_USER="${SUDO_USER:-$(whoami)}"
ACTUAL_HOME=$(eval echo "~$ACTUAL_USER")

#######################################
# 1. Node.js Stack
#######################################
log_info "Setting up Node.js stack..."

# Fedora provides a solid stable Node.js stream
if command_exists "node"; then
    log_info "Node.js is already installed."
else
    install_dnf_packages "nodejs" "npm"
fi

# Global tools (Yarn, PNPM)
# We use npm to install these globally. Since we are root, these go to system bin.
NODE_TOOLS=("yarn" "pnpm" "typescript")

for tool in "${NODE_TOOLS[@]}"; do
    if ! command_exists "$tool"; then
        if [[ "${DRY_RUN:-}" == "true" ]]; then
            log_info "[DRY RUN] Would npm install -g $tool"
        else
            npm install -g "$tool"
            log_success "Installed global node tool: $tool"
        fi
    else
        log_info "$tool is already installed."
    fi
done

#######################################
# 2. Go (Golang) Stack
#######################################
log_info "Setting up Go stack..."

if command_exists "go"; then
    log_info "Go is already installed."
else
    install_dnf_packages "golang"
fi

# Setup GOPATH/Workspace
GOPATH="$ACTUAL_HOME/go"
ensure_directory "$GOPATH" "$ACTUAL_USER"
ensure_in_path 'export GOPATH="$HOME/go"' "$ACTUAL_HOME/.bashrc" "$ACTUAL_USER"
ensure_in_path 'export PATH="$PATH:$GOPATH/bin"' "$ACTUAL_HOME/.bashrc" "$ACTUAL_USER"

if [[ "${DRY_RUN:-}" == "true" ]]; then
    log_info "[DRY RUN] Would install Go tools (gopls, dlv)"
else
    # Install standard tools
    # We run this as user to install into GOPATH/bin
    sudo -u "$ACTUAL_USER" go install golang.org/x/tools/gopls@latest 2>/dev/null || log_warn "Failed to install gopls"
    sudo -u "$ACTUAL_USER" go install github.com/go-delve/delve/cmd/dlv@latest 2>/dev/null || log_warn "Failed to install dlv"
fi

#######################################
# 3. Rust Stack
#######################################
log_info "Setting up Rust stack..."

if command_exists "rustc"; then
    log_info "Rust is already installed."
else
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would download and run rustup-init"
    else
        # Rustup is the preferred way to install Rust
        log_info "Installing Rust via rustup as user '$ACTUAL_USER'..."
        sudo -u "$ACTUAL_USER" curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
            sudo -u "$ACTUAL_USER" sh -s -- -y
        
        # Ensure the user's shell loads Rust environment persistently
        ensure_in_path '. "$HOME/.cargo/env"' "$ACTUAL_HOME/.bashrc" "$ACTUAL_USER"
        ensure_in_path '. "$HOME/.cargo/env"' "$ACTUAL_HOME/.zshrc" "$ACTUAL_USER"

        # Source env immediately for this script to pass verification below
        if [[ -f "$ACTUAL_HOME/.cargo/env" ]]; then
            source "$ACTUAL_HOME/.cargo/env"
        fi
        
        log_success "Rust installed successfully."
    fi
fi

#######################################
# 4. Verification
#######################################
log_info "Verifying language versions..."

if [[ "${DRY_RUN:-}" == "true" ]]; then
    log_success "[DRY RUN] Node: v20.x (mock)"
    log_success "[DRY RUN] Go:   go1.22 (mock)"
    log_success "[DRY RUN] Rust: 1.77 (mock)"
else
    if command_exists "node"; then
        log_success "Node: $(node -v)"
    fi
    if command_exists "go"; then
        log_success "Go:   $(go version | awk '{print $3}')"
    fi
    
    # FIX: Use 'sh -c' to run the built-in 'command' inside sudo [SC2232]
    if sudo -u "$ACTUAL_USER" sh -c "command -v rustc" >/dev/null 2>&1; then
         RUST_VER=$(sudo -u "$ACTUAL_USER" rustc --version | awk '{print $2}')
         log_success "Rust: $RUST_VER"
    elif command_exists "rustc"; then
         log_success "Rust: $(rustc --version | awk '{print $2}')"
    else
         log_warn "Rust installed but not found in current PATH (requires restart)"
    fi
fi

log_success "Extended language support complete!"