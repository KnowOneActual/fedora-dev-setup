#!/bin/bash
# scripts/lib/logging.sh
# Shared logging library for Fedora Dev Setup

# Prevent double sourcing
[[ -n "${_LOGGING_SH_LOADED:-}" ]] && return
_LOGGING_SH_LOADED=true

# Set up log directory
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
CURRENT_LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"

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
    
    # Print to file without color, with timestamp
    echo "[${timestamp}] [${level}] ${msg}" >> "$CURRENT_LOG_FILE"
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
    echo "" >> "$CURRENT_LOG_FILE"
    echo "=== ${msg} ===" >> "$CURRENT_LOG_FILE"
}

# Export functions
export -f log_info log_success log_warn log_error log_header