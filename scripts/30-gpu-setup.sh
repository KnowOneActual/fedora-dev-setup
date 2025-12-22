#!/bin/bash
# scripts/30-gpu-setup.sh
# Phase 3: GPU Acceleration
# Installs drivers and compute stacks based on hardware profile.

# Source libraries
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/lib" && pwd)"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/utils.sh"

log_header "Phase 3: GPU Setup"

check_root
check_internet

PROFILE_FILE="/tmp/fedora-hardware-profile.json"

#######################################
# 1. Load Hardware Profile
#######################################
# If profile doesn't exist, try to generate it
if [[ ! -f "$PROFILE_FILE" ]]; then
    log_warn "Hardware profile not found. Running detection..."
    DETECT_SCRIPT="$(dirname "${BASH_SOURCE[0]}")/detect-hardware.sh"
    if [[ -x "$DETECT_SCRIPT" ]]; then
        "$DETECT_SCRIPT"
    else
        log_error "Cannot find detect-hardware.sh to generate profile."
        exit 1
    fi
fi

# Read Vendor from JSON (requires jq, which detect-hardware ensures)
if [[ "${DRY_RUN:-}" == "true" ]]; then
    GPU_VENDOR="nvidia" # Mock for testing logic
    log_info "[DRY RUN] Mocking GPU vendor as: $GPU_VENDOR"
else
    GPU_VENDOR=$(jq -r '.gpu.vendor // "unknown"' "$PROFILE_FILE")
fi

log_info "Configuring drivers for vendor: $GPU_VENDOR"

#######################################
# 2. NVIDIA Setup
#######################################
setup_nvidia() {
    log_info "Detected NVIDIA GPU. Installing drivers and CUDA..."

    # 1. Enable Non-Free Repos (needed for drivers)
    if ! package_installed "rpmfusion-nonfree-release"; then
        if [[ "${DRY_RUN:-}" == "true" ]]; then
            log_info "[DRY RUN] Would enable RPM Fusion Non-Free"
        else
            dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-nonfree-release-$(get_fedora_version).noarch.rpm
        fi
    fi

    # 2. Install Drivers & CUDA
    # akmod-nvidia: Kernel module
    # xorg-x11-drv-nvidia-cuda: CUDA libs
    PACKAGES=(
        "akmod-nvidia"
        "xorg-x11-drv-nvidia-cuda"
        "nvidia-settings"
        "vulkan-loader"
    )

    install_dnf_packages "${PACKAGES[@]}"
    
    log_success "NVIDIA drivers installed. Reboot required."
}

#######################################
# 3. AMD Setup
#######################################
setup_amd() {
    log_info "Detected AMD GPU. Installing ROCm and HIP..."

    # Fedora has excellent open source support, but we add compute (ROCm)
    PACKAGES=(
        "rocm-hip"
        "rocm-opencl"
        "rocm-clinfo"
        "radeontop"
    )

    install_dnf_packages "${PACKAGES[@]}"
    log_success "AMD compute stack installed."
}

#######################################
# 4. Intel Setup
#######################################
setup_intel() {
    log_info "Detected Intel GPU. Installing media drivers..."

    # Mostly VA-API for hardware video decode
    PACKAGES=(
        "intel-media-driver"
        "libvdpau-va-gl"
    )

    install_dnf_packages "${PACKAGES[@]}"
    log_success "Intel media drivers installed."
}

#######################################
# 5. Execute Logic
#######################################

case "$GPU_VENDOR" in
    nvidia)
        setup_nvidia
        ;;
    amd)
        setup_amd
        ;;
    intel)
        setup_intel
        ;;
    *)
        log_warn "No specific GPU setup found for vendor: $GPU_VENDOR"
        log_info "Standard Mesa drivers should already be active."
        ;;
esac

log_success "GPU setup complete!"