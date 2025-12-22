# Fedora Dev Setup Bootstrap - Development Roadmap

**Version:** 1.1.0  
**Last Updated:** December 22, 2025  
**Repository:** https://github.com/KnowOneActual/fedora-dev-setup

---

## 📅 Phase 2: Backup & Restore (Completed)

**Status:** ✅ Released v1.1.0  
**Completed:** December 22, 2025

### Delivered Features
- ✅ **Backup Pipeline** (`scripts/export-config.sh`)
  - Exports DNF package list, Pipx tools, and VSCodium extensions.
  - Backs up Shell (`.bashrc`, `.zshrc`) and Git (`.gitconfig`) configs.
  - Creates timestamped tarball archives.
- ✅ **Restore Pipeline** (`scripts/restore-config.sh`)
  - Intelligent package re-installation (skips existing).
  - VSCodium extension restoration.
  - Config file placement with automatic backups of existing files.
- ✅ **Safety**
  - Full `DRY_RUN` support for both export and restore.

---

## 🚀 Phase 3: Hardware & GPU (March 2026)

**Target Release:** v1.2.0  
**Focus:** Performance and hardware-specific features.

### Planned Features

#### 1. Hardware Detection
- `scripts/detect-hardware.sh` – Profile system
  - GPU detection (Intel/AMD/NVIDIA).
  - RAM and storage profiling.
  - Output JSON-based hardware profile.

#### 2. GPU Acceleration
- **NVIDIA CUDA Setup**
  - Install CUDA toolkit and cuDNN.
  - Verify GPU availability.
- **AMD ROCm Setup**
  - Install ROCm toolkit and HIP.

#### 3. Extended Language Support
- **Node.js Stack**: Install Node (LTS), npm, and Yarn.
- **Go Stack**: Install Go and gopls.
- **Rust Stack**: Install Rustup and Cargo.

---

## 📊 Project Statistics (v1.1.0)

| Metric | Value |
|--------|-------|
| **Architecture** | Modular (Orchestrator + Libs) |
| **Scripts** | 7 Core Scripts (`00`, `10`, `20`, `25`, `export`, `restore`, `validate`) |
| **Libraries** | 2 (`logging`, `utils`) |
| **Testing** | Dry-Run Verified on macOS |