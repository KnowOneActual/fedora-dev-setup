# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned for v1.1.0 (January 2026)

#### Backup & Restore Pipeline
- `scripts/export-config.sh` – Export system state snapshots
  - Package list export (dnf)
  - VSCodium extensions backup
  - Editor settings export (settings.json)
  - Dotfiles backup (.bashrc, .zshrc, etc.)
  - Hardware profile capture
  - Target: < 30 seconds export time

- `scripts/restore-config.sh` – Replay from backup
  - Package list restoration
  - Extension re-installation
  - Settings application
  - Dotfiles linking
  - System state verification
  - Target: < 5 minutes restore time

- Timestamped snapshots for version control
- Git-based dotfiles management
- Disaster recovery documentation

#### Enhanced Documentation
- `docs/ARCHITECTURE.md` – Internal design explanation
  - Script interaction diagram
  - Library dependency graph
  - Data flow documentation
  - Extension points for customization

- `docs/CUSTOMIZE.md` – Personalization guide
  - How to add packages
  - How to modify Python tools
  - How to add extensions
  - How to change settings
  - How to exclude steps

- `docs/TROUBLESHOOTING.md` – Common issues and solutions
  - Installation failures and recovery
  - PATH configuration issues
  - Extension problems
  - Permission errors
  - Network connectivity troubleshooting
  - Fedora version compatibility

#### CI/Testing Infrastructure
- `.github/workflows/validate.yml` – Continuous validation
  - Shellcheck linting on every push
  - Bash syntax validation
  - Script execution simulation
  - Documentation link validation
  - File presence verification

- `.github/workflows/release.yml` – Automated releases
  - Automated version tagging
  - Release notes generation
  - Asset packaging

#### Enhancements
- Contextual error messages with recovery steps
- Enhanced logging with more detail
- Configuration customization UI (optional)
- Extended test matrix (Fedora 40, 41, 42)

**Timeline:** December 21, 2025 → January 17, 2026  
**Effort:** 36-50 hours  
**Status:** Planned

---

### Planned for v1.2.0 (March 2026)

#### Hardware Detection & Optimization
- `scripts/detect-hardware.sh` – Profile system
  - GPU detection (Intel/AMD/NVIDIA)
  - RAM and storage profiling
  - CPU detection
  - Battery/power detection
  - Kernel version detection
  - JSON-based hardware profile output

#### GPU Acceleration Support
- NVIDIA CUDA setup
  - CUDA toolkit installation
  - cuDNN (deep learning libraries)
  - TensorRT (inference optimization)
  - GPU availability verification
  - Performance testing

- AMD ROCm setup
  - ROCm toolkit installation
  - MIOpen (deep learning libraries)
  - HIP (compute API)
  - GPU availability verification

#### Hardware-Specific Optimization
- Laptop optimization
  - Power management configuration
  - Thermal management setup
  - Battery life optimization
  - Fan control optimization
  - Display refresh rate settings

- Workstation optimization
  - Maximum performance configuration
  - Cooling strategy optimization
  - Memory optimization
  - Disk optimization
  - Development speed focus

- Server optimization (headless)
  - Stability configuration
  - Memory optimization
  - Disk I/O tuning
  - Headless-specific settings

#### Extended Language Support (Optional)
- Node.js/JavaScript stack
  - Node.js installation (latest LTS)
  - npm, yarn, pnpm
  - VSCodium extensions
  - Development tools

- Go language stack
  - Go installation (latest)
  - gopls (language server)
  - golangci-lint
  - VSCodium extensions
  - Development tools

- Rust stack
  - Rust/rustup installation
  - Cargo configuration
  - rust-analyzer setup
  - VSCodium extensions
  - Development tools

#### Additional Features
- Performance profiling tools (py-spy, memory-profiler)
- Benchmark utilities and guidelines
- Advanced documentation for GPU and hardware
- Hardware variant testing (5+ configurations)

**Timeline:** January 18, 2026 → March 17, 2026  
**Effort:** 80-100 hours  
**Status:** Planned

---

### Planned for v1.3.0+ (Future)

#### Infrastructure & Automation
- Ansible playbook generation
- Docker image generation for CI/CD
- Cloud VM automation (AWS, GCP, Azure templates)
- Kubernetes manifests for distributed setups

#### User Interface & Tools
- Web-based interactive setup wizard
- Mobile companion app for monitoring
- Real-time progress dashboard
- System metrics visualization

#### Enterprise Features
- Team configuration sharing and synchronization
- Organization-wide default settings
- Version pinning and lock files
- Dependency vulnerability scanning
- Security hardening options
- Compliance reporting

#### Advanced Capabilities
- Remote setup capability over SSH
- Multi-machine coordination
- Configuration drift detection
- Automated system updates
- Performance profiling integration
- Cost estimation for cloud deployments

---

## [1.0.0] - 2025-12-20

### Added

#### Bootstrap Orchestration (`bootstrap-fedora.sh` - 211 lines)
Main entry point with comprehensive CLI options:
- `--dry-run` – Preview changes without applying
- `--headless` – Automated mode (no prompts)
- `--verbose` – Debug output with command trace
- `--skip SCRIPT` – Skip specific setup steps
- `--help` – Full usage documentation

Preflight validation (5 checks):
- Fedora OS detection
- Fedora version validation (40+)
- Internet connectivity check
- Sudo privilege verification
- Disk space validation (5GB minimum)

Comprehensive logging:
- Automatic timestamped logs: `logs/bootstrap-YYYYMMDD-HHMMSS.log`
- Colored, formatted console output
- 50+ logged checkpoints
- Clear next-steps guidance

#### Shared Libraries (DRY Principle)

**`scripts/lib/logging.sh`** (48 lines)
- Centralized logging with consistent formatting
- Colored output: info (blue), success (green), warn (yellow), error (red)
- Automatic timestamps on every log line (YYYY-MM-DD HH:MM:SS)
- Dual output to console and log file
- Section headers and visual dividers
- Exported functions for use across all scripts

**`scripts/lib/utils.sh`** (89 lines)
- Command existence checks: `command_exists()`
- Package installation status: `package_installed()`
- System information: `get_fedora_version()`, `is_fedora()`, `check_internet()`
- Path management: `ensure_in_path()`, `reload_path()`
- Idempotent package installation: `install_dnf_packages()`
- File utilities: `backup_file()`, `ensure_directory()`, `download_file()`
- Validation helpers: `validate_command()`
- Formatted output: `print_success_list()`, `print_info_list()`
- 20+ reusable functions eliminating code duplication

#### Setup Scripts (Modular, Idempotent)

**`scripts/00-system-base.sh`** (55 lines)
- System package updates via dnf
- Core development tools: gcc, g++, make, cmake, kernel-devel, openssl-devel, libffi-devel
- Shell utilities: tmux, zsh, fzf, direnv
- System utilities: htop, jq, yq, unzip, tree, bat, ripgrep, fd-find, vim, nano
- Python 3 with development headers
- Optional Nix package manager
- Idempotent (checks if installed before installing)

**`scripts/10-python-dev.sh`** (76 lines)
- uv installation (from official astral.sh installer)
- pipx installation (via pip3)
- Global Python tools via pipx:
  - black – Code formatter
  - ruff – Fast Python linter
  - mypy – Static type checker
  - pytest – Testing framework
  - ipython – Enhanced Python REPL
  - httpie – CLI HTTP client
- PATH configuration for ~/.local/bin and ~/.cargo/bin
- Retry logic with backoff for reliability
- Installation verification with version checks

**`scripts/20-vscodium.sh`** (106 lines)
- VSCodium repository setup (Fedora)
- GPG key import and verification
- VSCodium package installation
- Extension installation via CLI:
  - ms-python.python (Official Python support)
  - ms-python.black-formatter (Format on save)
  - njpwerner.autodocstring (Docstring generation)
  - github.copilot-chat (AI assistance)
- JSON-based settings configuration
- Format on save with Black
- Ruff linting enabled
- 88-character line length rule
- 4-space indentation (spaces, no tabs)

**`scripts/99-validate.sh`** (68 lines)
- System packages verification
- Python tools accessibility check
- VSCodium and extensions validation
- Configuration file verification
- PATH correctness check
- Shell reload guidance for tools
- Clear pass/fail per component
- Actionable next-steps recommendations

#### Documentation

**`README.md`** (260 lines)
- User-focused quick-start guide (3 lines to setup)
- What gets installed (categorized breakdown)
- Usage options (all 6 modes explained with examples)
- Repository structure with descriptions
- System requirements table
- Idempotency guarantee
- Post-installation next steps
- Troubleshooting introduction
- Support and contribution guidelines

**`SETUP_SPEC.md`** (347 lines)
- Complete target environment specification
- Full package inventory with descriptions
- Setup architecture and design explanation
- Usage examples for all CLI modes
- Detailed system requirements
- Repository structure with line counts
- Customization instructions
- Testing status documentation
- Known limitations per version
- Future enhancement roadmap (Phase 2 & 3)

**`ROADMAP.md`** (File created December 20, 2025)
- Development roadmap for all phases
- Quick reference of files needed
- Step-by-step creation plan
- Phase 1, 2, 3, and 4+ planning
- Session breakdown for implementation
- Project statistics and timeline
- Success criteria for each phase

**`CHANGELOG.md`** (this file)
- Version history and release notes
- Detailed feature lists per release
- Known limitations per version
- Testing status documentation
- Complete development roadmap
- Contributing guidelines
- Support information

#### Configuration Templates
- `config/packages.txt` – System packages reference list
- `config/python-tools.txt` – Python tools reference list
- `config/extensions.txt` – VSCodium extensions reference list

### Design & Quality

#### Architecture Principles
- **Idempotency** – Every script checks before installing, safe to run multiple times
- **Modularity** – Each script handles one concern, can be re-run independently
- **Logging** – All operations timestamped and traceable to `logs/`
- **Validation** – Post-install verification ensures setup success
- **User Control** – Multiple modes for different scenarios
- **Reproducibility** – Same setup produces identical results across machines
- **Best Practices** – Shellcheck compliant, professional code
- **DRY Principle** – Shared libraries eliminate duplication

#### Technology Choices
- **Python Tooling:** uv + pipx (modern, lightweight vs Conda)
- **Desktop:** KDE Plasma (latest, feature-rich vs GNOME)
- **Editor:** VSCodium (open-source, non-telemetry vs VS Code)
- **Shell:** Bash (ubiquitous, portable)
- **Build Pattern:** Modular scripts + shared libraries

### Statistics

| Metric | Value |
|--------|-------|
| **Total Lines** | 1,360+ |
| **Shell Scripts** | 8 files |
| **Code Lines** | 553 |
| **Documentation Lines** | 807+ |
| **System Packages** | 30+ |
| **Python Tools** | 8 |
| **VSCodium Extensions** | 4 |
| **CLI Modes** | 6 |
| **Preflight Checks** | 5 |
| **Logged Checkpoints** | 50+ |
| **Utility Functions** | 20+ |
| **Setup Time** | 10-15 minutes |

### Known Limitations

- No backup/restore pipeline (planned v1.1.0)
- No hardware-specific optimizations (planned v1.2.0)
- No GPU acceleration setup (planned v1.2.0)
- No extended language support (planned v1.2.0)
- Manual SSH/Git configuration needed post-install

### Testing Status

- ✅ Scripts follow shellcheck best practices (`set -euo pipefail`)
- ✅ Idempotent operation verified in design
- ✅ Error handling comprehensive
- ✅ Logging integrated throughout
- ✅ Documentation thorough
- ⏳ End-to-end test on Fedora 41 KDE VM (ready for testing)
- ⏳ Extended hardware variant testing (Phase 2)
- ⏳ CI validation pipeline (Phase 3)

---

## Development Roadmap

### v1.1.0 – Backup & Restore (January 2026)
- **Start:** December 21, 2025
- **Release:** January 17, 2026
- **Duration:** 3-4 weeks
- **Effort:** 36-50 hours
- **Features:** Backup/restore pipeline, advanced docs, CI/testing

### v1.2.0 – Hardware & GPU (March 2026)
- **Start:** January 18, 2026
- **Release:** March 17, 2026
- **Duration:** 8 weeks
- **Effort:** 80-100 hours
- **Features:** Hardware detection, GPU acceleration, extended languages

### v1.3.0+ – Enterprise (Future)
- **Start:** March 18, 2026+
- **Focus:** Infrastructure automation, UI/tools, enterprise features
- **Timeline:** TBD based on community feedback

---

## Contributing

To contribute to this project:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Make your changes
4. Test thoroughly
5. Submit a pull request to `main` branch

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## Support

- **Issues:** Report bugs on GitHub Issues
- **Discussions:** Share ideas on GitHub Discussions
- **Documentation:** See README.md and SETUP_SPEC.md
- **Troubleshooting:** See docs/TROUBLESHOOTING.md (v1.1.0+)
- **Architecture:** See docs/ARCHITECTURE.md (v1.1.0+)

---

## License

MIT License – See [LICENSE](LICENSE) file

---

## Acknowledgments

Built with ❤️ for reproducible, maintainable Fedora development setups.

**Repository:** https://github.com/KnowOneActual/fedora-dev-setup  
**Maintainer:** Beau Bremer (@KnowOneActual)  
**Version:** 1.0.0  
**Last Updated:** December 20, 2025
