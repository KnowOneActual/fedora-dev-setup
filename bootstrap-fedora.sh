#!/usr/bin/env bash
# bootstrap-fedora.sh - Fedora Development Environment Bootstrapper v1.0.0
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" 1>&2; exit 1; }

usage() {
  cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
  --help        Show this help
  --dry-run     Show what would be done (no changes)
  --install     Run full Phase 1 setup
  --validate    Verify prerequisites only
EOF
}

main() {
  [[ $# -eq 0 ]] && { usage; return; }
  
  for arg; do
    case "$arg" in
      --help) usage; return 0 ;;
      --dry-run) echo "DRY RUN MODE"; return 0 ;;
      --install)
        log "Starting Phase 1: Initial Setup"
        [[ -d scripts/ ]] || error "Missing scripts/ directory. Clone full repo."
        bash scripts/01-initial-setup.sh || error "01-initial-setup failed"
        log "✅ Phase 1 bootstrap complete!"
        ;;
      --validate)
        log "Validating prerequisites..."
        command -v dnf >/dev/null || error "dnf not found (Fedora required)"
        [[ $(id -u) -ne 0 ]] || warn "Run as non-root user"
        log "✅ Prerequisites OK"
        ;;
      *) error "Unknown option: $arg" ;;
    esac
  done
}

main "$@"
