#!/bin/bash
# scripts/lib/logging.sh
# Shared logging library for Fedora Dev Setup

# Prevent double sourcing
[[ -n "${_LOGGING_SH_LOADED:-}" ]] && return
_LOGGING_SH_LOADED=true

# Set up log directory at the repository root
# BASH_SOURCE[0] is /path/to/fedora-dev-setup/scripts/lib/logging.sh
LIB_DIR_ABS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR_ABS="$(cd "$LIB_DIR_ABS/../.." && pwd)"
LOG_DIR="$ROOT_DIR_ABS/logs"

# Ensure log directory exists
if [[ ! -d "$LOG_DIR" ]]; then
    mkdir -p "$LOG_DIR" 2>/dev/null || true
fi

CURRENT_LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"

# Touch the file to initialize it, if directory is writable
if [[ -d "$LOG_DIR" && -w "$LOG_DIR" ]]; then
    touch "$CURRENT_LOG_FILE" 2>/dev/null || true
    # If run as root but via sudo, make it writable by the actual user so future dry-runs don't crash
    if [[ -n "${SUDO_USER:-}" ]]; then
        chown "$SUDO_USER:$SUDO_USER" "$CURRENT_LOG_FILE" 2>/dev/null || true
        chown "$SUDO_USER:$SUDO_USER" "$LOG_DIR" 2>/dev/null || true
    fi
fi

# Capture all subsequent output (stdout and stderr) to the log file via tee if writable
if [[ -f "$CURRENT_LOG_FILE" && -w "$CURRENT_LOG_FILE" ]]; then
    exec > >(tee -i -a "$CURRENT_LOG_FILE") 2>&1
fi

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

_log() {
    local level="$1"
    local color="$2"
    local msg="$3"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Print to console with color
    echo -e "${color}[${level}]${NC} ${msg}"
    
    # Print to file without color, with timestamp (best-effort)
    if [[ -f "$CURRENT_LOG_FILE" && -w "$CURRENT_LOG_FILE" ]]; then
        echo "[${timestamp}] [${level}] ${msg}" >> "$CURRENT_LOG_FILE"
    fi
}

log_info() {
    _log "INFO" "$BLUE" "$*"
}

log_success() {
    _log "OK" "$GREEN" "$*"
}

log_warn() {
    _log "WARN" "$YELLOW" "$*"
}

log_error() {
    _log "ERROR" "$RED" "$*" >&2
}

log_header() {
    local msg="$*"
    echo ""
    echo -e "${BLUE}================================================================================${NC}"
    echo -e "${BLUE} ${msg}${NC}"
    echo -e "${BLUE}================================================================================${NC}"
    if [[ -f "$CURRENT_LOG_FILE" && -w "$CURRENT_LOG_FILE" ]]; then
        echo "" >> "$CURRENT_LOG_FILE"
        echo "=== ${msg} ===" >> "$CURRENT_LOG_FILE"
    fi
}

# Export functions
export -f log_info log_success log_warn log_error log_header