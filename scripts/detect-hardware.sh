#!/bin/bash
# scripts/detect-hardware.sh
# Phase 3: Hardware Detection
# Profiles the system (GPU, CPU, Chassis) and outputs JSON.

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"

log_header "Phase 3: Hardware Detection"

# Dependencies check
if ! command_exists "lspci"; then
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        log_info "[DRY RUN] Would install pciutils"
    else
        install_dnf_packages "pciutils" "util-linux" "jq"
    fi
fi

#######################################
# 1. Detect GPU
#######################################
detect_gpu() {
    local vendor="unknown"
    local model="unknown"
    
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        echo '{"vendor": "nvidia", "model": "RTX 4090 (Mock)"}'
        return
    fi

    # Check for NVIDIA
    if lspci | grep -i "nvidia" > /dev/null; then
        vendor="nvidia"
        model=$(lspci | grep -i "nvidia" | head -n 1 | cut -d ':' -f 3 | xargs)
    elif lspci | grep -i "amd" | grep -i "vga" > /dev/null; then
        vendor="amd"
        model=$(lspci | grep -i "amd" | grep -i "vga" | head -n 1 | cut -d ':' -f 3 | xargs)
    elif lspci | grep -i "intel" | grep -i "vga" > /dev/null; then
        vendor="intel"
        model=$(lspci | grep -i "intel" | grep -i "vga" | head -n 1 | cut -d ':' -f 3 | xargs)
    fi

    echo "{\"vendor\": \"$vendor\", \"model\": \"$model\"}"
}

#######################################
# 2. Detect Chassis (Laptop/Desktop)
#######################################
detect_chassis() {
    local chassis="desktop" # Default
    
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        echo "laptop"
        return
    fi

    if command_exists "hostnamectl"; then
        chassis=$(hostnamectl --json 2>/dev/null | jq -r '.Chassis // "desktop"')
        # Fallback if jq fails or field missing
        [[ "$chassis" == "null" ]] && chassis="desktop"
    elif [[ -d "/sys/class/power_supply" ]]; then
        # If we see a battery, it's likely a laptop
        if ls /sys/class/power_supply | grep -q "BAT"; then
            chassis="laptop"
        fi
    fi

    echo "$chassis"
}

#######################################
# 3. Detect Resources
#######################################
detect_cpu() {
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        echo "8"
        return
    fi
    nproc --all
}

detect_ram() {
    if [[ "${DRY_RUN:-}" == "true" ]]; then
        echo "16" # GB
        return
    fi
    # Get total RAM in GB
    free -g | awk '/^Mem:/{print $2}'
}

#######################################
# 4. Generate Profile
#######################################
log_info "Scanning hardware..."

GPU_INFO=$(detect_gpu)
GPU_VENDOR=$(echo "$GPU_INFO" | jq -r .vendor)
GPU_MODEL=$(echo "$GPU_INFO" | jq -r .model)
CHASSIS=$(detect_chassis)
CPU_CORES=$(detect_cpu)
RAM_GB=$(detect_ram)

log_info "Detected System Profile:"
echo "  - Chassis: $CHASSIS"
echo "  - GPU:     $GPU_VENDOR ($GPU_MODEL)"
echo "  - CPU:     $CPU_CORES cores"
echo "  - RAM:     $RAM_GB GB"

# Save to file for other scripts to use
PROFILE_FILE="/tmp/fedora-hardware-profile.json"
cat > "$PROFILE_FILE" <<EOF
{
  "chassis": "$CHASSIS",
  "gpu": {
    "vendor": "$GPU_VENDOR",
    "model": "$GPU_MODEL"
  },
  "cpu": {
    "cores": $CPU_CORES
  },
  "ram_gb": $RAM_GB,
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

echo ""
log_success "Hardware profile saved to $PROFILE_FILE"