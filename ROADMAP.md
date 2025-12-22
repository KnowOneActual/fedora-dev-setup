# Fedora Dev Setup Bootstrap - Development Roadmap

**Version:** 1.2.0  
**Last Updated:** December 22, 2025  
**Repository:** https://github.com/KnowOneActual/fedora-dev-setup

## 🛠️ Phase 4: Maintenance & Hardening (In Progress)

**Target Release:** v1.3.0
**Focus:** Automation, Security, and Containerization.

### Delivered Features
- ✅ **CI/CD Pipeline** (`.github/workflows/validate.yml`)
  - Automated ShellCheck linting.
  - Integration testing on Fedora 41 Docker containers.
  - Verification of Backup/Restore scripts in CI.

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

## 🚀 Future Maintenance

**Target:** v1.3.0+  
**Focus:** Maintenance, security updates, and community requests.

- **Containerization:** Optional Docker/Podman setup script.
- **Security Audit:** Automated Lynis scan integration.
- **CI/CD:** GitHub Actions to validate install scripts on fresh images.

---

## 📊 Project Statistics (v1.2.0)

| Metric | Value |
|--------|-------|
| **Architecture** | Modular (Orchestrator + Libs + Hardware Awareness) |
| **Scripts** | 12 Core Scripts |
| **Libraries** | 2 (`logging`, `utils`) |
| **Capabilities** | GPU-Aware, Chassis-Aware, Power-User Shell |