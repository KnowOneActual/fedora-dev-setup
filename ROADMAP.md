# Fedora Dev Setup Bootstrap - Development Roadmap

**Version:** 1.3.0  
**Last Updated:** December 23, 2025  
**Repository:** https://github.com/KnowOneActual/fedora-dev-setup


## 🚀 Future Maintenance

- **Security Audit:** Automated Lynis scan integration (`scripts/60-security.sh`).
- **Dotfile Management:** Replace simple copy with GNU Stow support.
- **Nix Support:** Optional Nix package manager installation.

### Planned Features
- [ ] **Containerization Support** (`scripts/45-containers.sh`)
  - Podman (Native) & Docker CE setup.
- [ ] **Security Auditing** (`scripts/50-security-audit.sh`)
  - Lynis installation and automated system scanning.




## 🛠️ Phase 5: Workstation Polish (Completed)

**Status:** ✅ Released v1.3.0  
**Completed:** December 23, 2025

### Delivered Features
- ✅ **Containerization** (`scripts/45-containers.sh`)
  - Podman, Distrobox, and Docker CE setup.
- ✅ **Desktop Applications** (`scripts/50-desktop-apps.sh`)
  - Flatpak ecosystem integration.
  - Productivity suite: LibreOffice, Obsidian, Postman, DBeaver.
  - Multimedia codecs (FFmpeg, GStreamer).
- ✅ **Backup Upgrades**
  - Full support for backing up and restoring Flatpak applications.

---

## 📅 Phase 4: Maintenance & Hardening (Completed)

**Status:** ✅ Released v1.2.1  
**Completed:** December 23, 2025

### Delivered Features
- ✅ **CI/CD Pipeline** (`.github/workflows/validate.yml`)
  - Automated ShellCheck linting.
  - Integration testing on Fedora 41 Docker containers.

---

## 🚀 Future Maintenance

- **Security Audit:** Automated Lynis scan integration (`scripts/60-security.sh`).
- **Dotfile Management:** Replace simple copy with GNU Stow support.
- **Nix Support:** Optional Nix package manager installation.

### Planned Features
- [ ] **Containerization Support** (`scripts/45-containers.sh`)
  - Podman (Native) & Docker CE setup.
- [ ] **Security Auditing** (`scripts/50-security-audit.sh`)
  - Lynis installation and automated system scanning.


---

## 📅 Phase 3: Hardware & GPU (Completed)

**Status:** ✅ Released v1.2.0  
**Completed:** December 22, 2025

### Delivered Features
- ✅ **Hardware Detection** (`scripts/detect-hardware.sh`)
  - Profiles GPU (NVIDIA/AMD/Intel), CPU cores, and Chassis type.
  - Outputs a JSON hardware profile for other scripts to consume.
- ✅ **GPU Acceleration** (`scripts/30-gpu-setup.sh`)
  - **NVIDIA:** Automated installation of drivers, CUDA, and libs.
  - **AMD:** Installation of ROCm and HIP compute stacks.
- ✅ **Hardware Optimization** (`scripts/31-hardware-optimization.sh`)
  - **Laptops:** Installs TLP for battery and thermal management.
  - **Workstations:** Tunes CPU governor for performance.
- ✅ **Extended Languages** (`scripts/40-languages.sh`)
  - Node.js (with Yarn/PNPM), Go (with tools), and Rust (via Rustup).

---

## 📅 Phase 2: Backup & Restore (Completed)

**Status:** ✅ Released v1.1.0  
**Completed:** December 22, 2025

- **Backup Pipeline:** `scripts/export-config.sh`
- **Restore Pipeline:** `scripts/restore-config.sh`

---

