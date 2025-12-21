# Fedora Dev Setup Bootstrap - Development Roadmap

**Version:** 1.0.0  
**Last Updated:** December 21, 2025  
**Repository:** https://github.com/KnowOneActual/fedora-dev-setup

---

## 📅 Phase 2: Backup & Restore (January 2026)

**Target Release:** v1.1.0  
**Focus:** Disaster recovery and user customization.

### Planned Features

#### 1. Backup & Restore Pipeline
- `scripts/export-config.sh` – Export system state snapshots
  - Package list export (dnf)
  - VSCodium extensions backup
  - Hardware profile capture
- `scripts/restore-config.sh` – Replay from backup
  - Package list restoration
  - Extension re-installation
  - System state verification

#### 2. Enhanced Documentation
- `docs/ARCHITECTURE.md` – Internal design explanation
- `docs/CUSTOMIZE.md` – Guide for adding packages/tools
- **NEW: Dotfiles Integration Guide**
  - Best practices for mapping existing `.zshrc` and `.gitconfig` files.
  - How to use `stow` or simple symlinks with this setup.
  - Manual steps for migrating GPG keys and secrets.

#### 3. CI/Testing Infrastructure
- `.github/workflows/validate.yml` – Continuous validation
  - Shellcheck linting on every push
  - Bash syntax validation

---

## 🚀 Phase 3: Hardware & GPU (March 2026)

**Target Release:** v1.2.0  
**Focus:** Performance and hardware-specific features.

- **Hardware Detection**: Profile GPU (Intel/AMD/NVIDIA).
- **GPU Acceleration**: CUDA/ROCm setup.
- **Extended Language Support**: Node.js, Go, Rust.

---

## 📊 Project Statistics (v1.0.0)

| Metric | Value |
|--------|-------|
| **Architecture** | Modular (Orchestrator + Libs) |
| **Scripts** | 5 Core Scripts (`00`, `10`, `20`, `99`, `bootstrap`) |
| **Libraries** | 2 (`logging`, `utils`) |
| **Testing** | Dry-Run Verified on macOS |