#!/bin/bash
# scripts/26-setup-tmux.sh
# Phase 2.6: Terminal Multiplexer Setup
# Focuses on usability, mouse support, and session persistence.

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"

log_header "Phase 2.6: Tmux Setup"

ACTUAL_USER="${SUDO_USER:-$(whoami)}"
ACTUAL_HOME=$(eval echo "~$ACTUAL_USER")
TMUX_CONF="$ACTUAL_HOME/.tmux.conf"

#######################################
# 1. Install Tmux Plugin Manager (TPM)
#######################################
if [[ ! -d "$ACTUAL_HOME/.tmux/plugins/tpm" ]]; then
    log_info "Installing Tmux Plugin Manager..."
    sudo -u "$ACTUAL_USER" git clone https://github.com/tmux-plugins/tpm "$ACTUAL_HOME/.tmux/plugins/tpm"
fi

#######################################
# 2. Write User-Friendly Config
#######################################
log_info "Configuring .tmux.conf with mouse support and persistence..."

cat > "$TMUX_CONF" <<EOF
# --- General Settings ---
set -g mouse on               # Enable mouse for scrolling, clicking, and resizing
set -g history-limit 50000    # Increase scrollback buffer
set -g base-index 1           # Start window numbering at 1
setw -g pane-base-index 1     # Start pane numbering at 1
set -g renumber-windows on    # Automatically renumber windows when one is closed

# --- Keybindings (Non-VIM) ---
# Use Alt-arrow keys without prefix key to switch panes
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Shift arrow to switch windows
bind -n S-Left  previous-window
bind -n S-Right next-window

# Easier splits
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# --- Plugins ---
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'   # Save/Restore sessions (Ctrl-s to save, Ctrl-r to restore)
set -g @plugin 'tmux-plugins/tmux-continuum'   # Auto-save sessions every 15 mins
set -g @plugin 'jimeh/tmux-themepack'          # Visual themes

set -g @themepack 'powerline/block/blue'
set -g @continuum-restore 'on'                 # Auto-restore on startup

# Initialize TMUX plugin manager (keep this at the very bottom)
run '~/.tmux/plugins/tpm/tpm'
EOF

chown "$ACTUAL_USER:$ACTUAL_USER" "$TMUX_CONF"
log_success "Tmux configured! (Tip: Press 'Prefix + I' inside Tmux to install plugins)"