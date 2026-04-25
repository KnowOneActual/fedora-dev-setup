#!/bin/bash
# shellcheck disable=SC2034
# scripts/lib/variables.sh
# Central configuration file for Fedora Dev Setup

# ==============================================================================
# CLI Tools (Phase 1.5 - scripts/05-modern-tools.sh)
# ==============================================================================
MODERN_CLI_TOOLS=(
    "eza" 
    "bat" 
    "fd-find" 
    "du-dust" 
    "git-delta" 
    "ripgrep" 
    "fzf" 
    "zoxide" 
    "htop" 
    "direnv" 
    "tldr"
)

# ==============================================================================
# Python Tools (Phase 2 - scripts/10-python-dev.sh)
# ==============================================================================
PYTHON_GLOBAL_TOOLS=(
    "black"         # Formatter
    "ruff"          # Fast Linter
    "mypy"          # Type Checker
    "pytest"        # Testing
    "ipython"       # Better REPL
    "httpie"        # Modern curl alternative
    "poetry"        # Dependency management
    "cookiecutter"  # Project scaffolding
)

# ==============================================================================
# VSCodium Extensions (Phase 3 - scripts/20-vscodium.sh)
# ==============================================================================
VSCODIUM_EXTENSIONS=(
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

# ==============================================================================
# Node.js Global Tools (Phase 3 - scripts/40-languages.sh)
# ==============================================================================
NODE_GLOBAL_TOOLS=(
    "yarn" 
    "pnpm" 
    "typescript"
)

# ==============================================================================
# Desktop Applications (Flatpak) (Phase 5 - scripts/50-desktop-apps.sh)
# ==============================================================================
FLATPAK_APPS=(
    "org.libreoffice.LibreOffice"
    "md.obsidian.Obsidian"
    "com.getpostman.Postman"
    "io.dbeaver.DBeaverCommunity"
    "com.slack.Slack"
    "us.zoom.Zoom"
    "com.discordapp.Discord"
    "com.google.Chrome"
)

# ==============================================================================
# Validation Targets (Phase 6 - scripts/99-validate.sh)
# ==============================================================================
VALIDATE_SYSTEM_TOOLS=(
    "git" "curl" "jq" "make" "gcc" "zsh" "tmux" "htop" "fzf" "direnv"
)

VALIDATE_CONTAINER_TOOLS=(
    "docker" "podman" "distrobox"
)

VALIDATE_FLATPAK_APPS=(
    "org.libreoffice.LibreOffice" "md.obsidian.Obsidian"
)