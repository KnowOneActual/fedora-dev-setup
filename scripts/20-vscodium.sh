#!/bin/bash
# scripts/20-vscodium.sh
# Phase 3: VSCodium & Extensions
# Installs VSCodium, configures settings, and installs extensions.

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"

log_header "Phase 3: VSCodium Setup"

check_root
check_internet

# Define user home (handle sudo case)
ACTUAL_USER="${SUDO_USER:-$(whoami)}"
ACTUAL_HOME=$(eval echo "~$ACTUAL_USER")

#######################################
# 1. Install VSCodium
#######################################
log_info "Setting up VSCodium..."

if ! package_installed "codium"; then
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would add VSCodium repo and install package"
    else
        # Add repo
        log_info "Adding VSCodium repository..."
        rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
        printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" > /etc/yum.repos.d/vscodium.repo
        
        # Install
        dnf install -y codium
    fi
else
    log_info "VSCodium already installed"
fi

#######################################
# 2. Configure Settings
#######################################
log_info "Configuring VSCodium settings..."

VSCODE_DIR="$ACTUAL_HOME/.config/VSCodium/User"
SETTINGS_FILE="$VSCODE_DIR/settings.json"

ensure_directory "$VSCODE_DIR" "$ACTUAL_USER"

if [[ "${DRY_RUN:-}" == "true" ]]; then
    log_info "[DRY RUN] Would write settings to $SETTINGS_FILE"
else
    # Backup existing
    backup_file "$SETTINGS_FILE"
    
    # Write settings
    cat > "$SETTINGS_FILE" << 'EOF'
{
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.rulers": [88, 120],
    "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
    "python.analysis.typeCheckingMode": "basic",
    "files.trimTrailingWhitespace": true,
    "workbench.colorTheme": "Default Dark Modern",
    "git.autofetch": true,
    "errorLens.enabled": true
}
EOF
    chown "$ACTUAL_USER:$ACTUAL_USER" "$SETTINGS_FILE"
    log_success "VSCodium settings configured"
fi

#######################################
# 3. Install Extensions
#######################################
# Combined list: Project Defaults + User Favorites
EXTENSIONS=(
    # --- Core Python Stack ---
    "ms-python.python"
    "charliermarsh.ruff"            # Linter/Formatter (Fast)
    "ms-python.mypy-type-checker"   # Static Typing
    "ms-python.debugpy"             # Debugging

    # --- Git Integration ---
    "eamodio.gitlens"
    "mhutchie.git-graph"

    # --- Formatting & Linting ---
    "esbenp.prettier-vscode"
    "dbaeumer.vscode-eslint"
    "rvest.vs-code-prettier-eslint"
    "stylelint.vscode-stylelint"

    # --- Productivity & AI ---
    "usernamehw.errorlens"          # Inline errors (Crucial)
    "codeium.codeium"               # AI Autocomplete
    "christian-kohler.path-intellisense"
    "formulahendry.auto-rename-tag"
    "formulahendry.code-runner"
    "yzhang.markdown-all-in-one"    # Markdown Power tools
    "tomoki1207.pdf"

    # --- Visualization & Data ---
    "mechatroner.rainbow-csv"       # CSV highlighting
    "grapecity.gc-excelviewer"      # Excel viewer
    "pkief.material-icon-theme"     # Icons
    "catppuccin.catppuccin-vsc"     # Theme
    "felixicaza.andromeda"          # Theme
    "johnpapa.vscode-peacock"       # Workspace coloring

    # --- Web/Remote ---
    "htmlhint.vscode-htmlhint"
    "webhint.vscode-webhint"
    "nishikanta12.live-server-lite"
    "jeanp413.open-remote-ssh"      # Open Source SSH Remote
)

log_info "Installing extensions..."

for ext in "${EXTENSIONS[@]}"; do
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would install extension: $ext"
    else
        # Run as user, not root
        # We use --force to update if already installed
        if sudo -u "$ACTUAL_USER" codium --install-extension "$ext" --force >/dev/null 2>&1; then
            log_success "Installed $ext"
        else
            log_warn "Failed to install $ext (or already latest)"
        fi
    fi
done

log_success "VSCodium setup complete!"