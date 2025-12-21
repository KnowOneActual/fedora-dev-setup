# Fedora Dev Setup Bootstrap - Development Roadmap

**Version:** 1.0.0  
**Last Updated:** December 20, 2025  
**Repository:** https://github.com/KnowOneActual/fedora-dev-setup

---

## 📋 Quick Reference: Files Still Needed

### ✅ Already Created
- [x] `bootstrap-fedora.sh` (211 lines)

### ⏳ Still Need to Create (11 files)

**In `scripts/` directory:**
- [ ] `scripts/00-system-base.sh` (55 lines)
- [ ] `scripts/10-python-dev.sh` (76 lines)
- [ ] `scripts/20-vscodium.sh` (106 lines)
- [ ] `scripts/99-validate.sh` (68 lines)

**In `scripts/lib/` directory:**
- [ ] `scripts/lib/logging.sh` (48 lines)
- [ ] `scripts/lib/utils.sh` (89 lines)

**In root:**
- [ ] `SETUP_SPEC.md` (347 lines)
- [ ] `CHANGELOG.md` (347 lines)

**In `config/` directory:**
- [ ] `config/packages.txt` (39 lines)
- [ ] `config/python-tools.txt` (21 lines)
- [ ] `config/extensions.txt` (12 lines)

**Total remaining: 1,208 lines**

---

## 🗺️ Step-by-Step Creation Plan

### Phase 1: Core Setup (What You're Doing Now)

**Status:** In Progress  
**Time Estimate:** 2-3 hours total to create all remaining files  
**Difficulty:** Low - mostly copy/paste from chat

#### Step 1: Create Directory Structure
```bash
cd ~/fedora-dev-setup
mkdir -p scripts/lib
mkdir -p config
```

#### Step 2: Create Shared Libraries (High Priority)
These are needed by other scripts. Create these first:

**Create `scripts/lib/logging.sh`** (48 lines)
- Provides: colored output, timestamped logging, log file writing
- Required by: All other scripts
- [Request content from chat when ready]

**Create `scripts/lib/utils.sh`** (89 lines)
- Provides: 20+ utility functions (command checks, package install, system info)
- Required by: All other scripts
- [Request content from chat when ready]

#### Step 3: Create Setup Scripts (In Order)
**Create `scripts/00-system-base.sh`** (55 lines)
- Installs: gcc, git, tmux, zsh, python3, etc. (30+ packages)
- Depends on: logging.sh, utils.sh
- [Request content from chat when ready]

**Create `scripts/10-python-dev.sh`** (76 lines)
- Installs: uv, pipx, black, ruff, mypy, pytest, ipython, httpie
- Depends on: logging.sh, utils.sh
- [Request content from chat when ready]

**Create `scripts/20-vscodium.sh`** (106 lines)
- Installs: VSCodium + 4 extensions
- Depends on: logging.sh, utils.sh
- [Request content from chat when ready]

**Create `scripts/99-validate.sh`** (68 lines)
- Validates: All installed components work
- Depends on: logging.sh, utils.sh
- [Request content from chat when ready]

#### Step 4: Create Documentation
**Create `SETUP_SPEC.md`** (347 lines)
- Technical reference for the entire system
- What gets installed, how it works
- [Request content from chat when ready]

**Create `CHANGELOG.md`** (347 lines)
- Version 1.0.0 details
- Roadmap for v1.1.0, v1.2.0, v1.3.0+
- [Request content from chat when ready]

#### Step 5: Create Config References
**Create `config/packages.txt`** (39 lines)
- List of all system packages
- [Request content from chat when ready]

**Create `config/python-tools.txt`** (21 lines)
- List of all Python tools
- [Request content from chat when ready]

**Create `config/extensions.txt`** (12 lines)
- List of all VSCodium extensions
- [Request content from chat when ready]

#### Step 6: Make Scripts Executable
```bash
chmod +x bootstrap-fedora.sh
chmod +x scripts/*.sh
chmod +x scripts/lib/*.sh
```

#### Step 7: Test & Commit
```bash
# Verify all files exist
ls -la
ls -la scripts/
ls -la scripts/lib/
ls -la config/

# Commit to GitHub
git add -A
git commit -m "Phase 1: Complete Fedora Bootstrap System

- bootstrap-fedora.sh: Main orchestrator
- 4 setup scripts: system, Python, VSCodium, validation
- 2 shared libraries: logging, utils
- Documentation: SETUP_SPEC, CHANGELOG
- Config references: packages, tools, extensions"

git tag -a v1.0.0 -m "Phase 1 Release"
git push origin main --tags
```

---

## 📅 Phase 2: Backup & Restore (January 2026)

**Target Release:** v1.1.0 - January 17, 2026  
**Duration:** 3-4 weeks  
**Effort:** 36-50 hours

### Features to Implement

1. **`scripts/export-config.sh`** (50 lines)
   - Export system state (packages, extensions, settings)
   - Save to timestamped backup directory
   - Target: < 30 seconds

2. **`scripts/restore-config.sh`** (60 lines)
   - Restore from backup directory
   - Re-install packages and extensions
   - Apply settings
   - Target: < 5 minutes

3. **Documentation**
   - `docs/ARCHITECTURE.md` (150 lines)
     - How scripts work together
     - Extension points for customization
     - Internal design decisions
   
   - `docs/CUSTOMIZE.md` (120 lines)
     - How to add packages
     - How to add Python tools
     - How to add extensions
     - How to modify scripts
   
   - `docs/TROUBLESHOOTING.md` (140 lines)
     - Common issues and solutions
     - How to debug scripts
     - Fedora version-specific notes

4. **CI/CD**
   - `.github/workflows/validate.yml`
     - Run shellcheck on every push
     - Verify syntax
     - Test on Fedora 40, 41, 42
   
   - `.github/workflows/release.yml`
     - Auto-generate release notes
     - Create GitHub releases

### Success Criteria
- ✅ Backup export < 30 seconds
- ✅ Restore < 5 minutes
- ✅ 3 new documentation files
- ✅ CI pipeline runs on every push
- ✅ v1.1.0 released
- ✅ Zero critical bugs

---

## 🚀 Phase 3: Hardware & GPU (March 2026)

**Target Release:** v1.2.0 - March 17, 2026  
**Duration:** 8 weeks  
**Effort:** 80-100 hours

### Features to Implement

1. **Hardware Detection** (40 lines)
   - Detect GPU (Intel, AMD, NVIDIA)
   - Profile CPU and RAM
   - Detect battery/power
   - Output JSON hardware profile

2. **GPU Acceleration** (200 lines)
   - NVIDIA CUDA setup (60 lines)
   - AMD ROCm setup (60 lines)
   - GPU verification (40 lines)
   - Performance testing (40 lines)

3. **Hardware Optimization** (120 lines)
   - Laptop optimization (power, thermal) (40 lines)
   - Workstation optimization (performance) (40 lines)
   - Server optimization (headless) (40 lines)

4. **Extended Language Support** (180 lines)
   - Node.js/JavaScript stack (60 lines)
   - Go language stack (60 lines)
   - Rust language stack (60 lines)

5. **Documentation**
   - `docs/GPU.md` (100 lines)
   - `docs/HARDWARE.md` (100 lines)
   - `docs/LANGUAGES.md` (100 lines)

### Success Criteria
- ✅ Hardware detection on 5+ configs
- ✅ GPU acceleration functional
- ✅ Performance improvements measurable
- ✅ Extended language support working
- ✅ v1.2.0 released
- ✅ 3 new docs

---

## 💭 Phase 4+: Future (TBD)

**Timeline:** 2026 and beyond  
**Status:** Planning stage

### Potential Features

**Infrastructure Automation**
- Ansible playbooks for team setup
- Docker image for CI/CD
- Cloud VM templates (AWS, GCP, Azure)

**User Interface**
- Web-based setup wizard
- Real-time progress dashboard
- System metrics visualization

**Enterprise Features**
- Team configuration sharing
- Organization-wide defaults
- Dependency scanning
- Security hardening
- Compliance reporting

**Advanced**
- Remote SSH setup
- Multi-machine coordination
- Configuration drift detection
- Automated system updates

---

## 📊 Project Statistics

| Metric | Phase 1 | Phase 2 | Phase 3 | Total |
|--------|---------|---------|---------|--------|
| **Lines of Code** | 500+ | 300+ | 600+ | 1,400+ |
| **Lines of Docs** | 700+ | 400+ | 300+ | 1,400+ |
| **Total Lines** | 1,200+ | 700+ | 900+ | 2,800+ |
| **Scripts** | 8 | 3 | 6+ | 17+ |
| **Documentation** | 3 | 3 | 3 | 9+ |
| **Time to Complete** | 40h | 40h | 100h | 180h |
| **Status** | ✅ In Progress | 📅 Planned | 📅 Planned | |

---

## 🎯 When You Have Time: Quick Checklist

### Session 1 (30 min)
- [ ] Create `scripts/` and `scripts/lib/` directories
- [ ] Request and create `scripts/lib/logging.sh` from chat
- [ ] Request and create `scripts/lib/utils.sh` from chat

### Session 2 (45 min)
- [ ] Request and create `scripts/00-system-base.sh`
- [ ] Request and create `scripts/10-python-dev.sh`

### Session 3 (45 min)
- [ ] Request and create `scripts/20-vscodium.sh`
- [ ] Request and create `scripts/99-validate.sh`

### Session 4 (45 min)
- [ ] Request and create `SETUP_SPEC.md`
- [ ] Request and create `CHANGELOG.md`

### Session 5 (30 min)
- [ ] Create `config/` directory
- [ ] Request and create 3 config files
- [ ] Make scripts executable: `chmod +x bootstrap-fedora.sh scripts/*.sh scripts/lib/*.sh`

### Session 6 (15 min)
- [ ] Test directory structure
- [ ] Commit and push to GitHub
- [ ] Tag v1.0.0

**Total Time:** ~4 hours spread across multiple sessions

---

## 📝 How to Request Files from Chat

When you're ready to create a file, just ask:

> "I need the content for `scripts/lib/logging.sh`"

Then I'll paste the complete content, and you copy/paste it into your editor.

---

## ✅ Success = When This is Done

- ✅ All 12 files created
- ✅ All scripts executable
- ✅ All pushed to GitHub
- ✅ Tagged v1.0.0
- ✅ Ready to test on Fedora 41 KDE VM

---

## 🎁 What You'll Have at Each Phase

### Phase 1 Complete (NOW)
- Single-command Fedora setup
- 30+ system packages auto-installed
- 8 Python development tools
- 4 VSCodium extensions
- Production-ready code
- Professional logging and validation

### Phase 2 Complete (January)
- Disaster recovery (backup/restore)
- Advanced documentation
- CI/CD automation
- Better troubleshooting guides

### Phase 3 Complete (March)
- Hardware-aware setup
- GPU acceleration (NVIDIA/AMD)
- Multiple language support (Node.js, Go, Rust)
- Performance optimization

---

## 📞 Support During Development

**When stuck:**
1. Check SETUP_SPEC.md (Phase 1) or docs/ARCHITECTURE.md (Phase 2+)
2. Review CHANGELOG.md for version details
3. Ask in this chat for specific file content

**When testing:**
1. Run `./bootstrap-fedora.sh --dry-run` (preview mode)
2. Check `logs/bootstrap-*.log` for details
3. Report issues with log excerpts

---

## 🚀 Ready When You Are

**This roadmap is your guide.** When you have time:

1. Pick a session (30-45 min)
2. Ask for the file content you need
3. Create it in your repo
4. Move to next session
5. Push to GitHub when all done

**No rush. This will be here whenever you're ready.** 🎯

---

**Repository:** https://github.com/KnowOneActual/fedora-dev-setup  
**Status:** Phase 1 in progress (1/12 files created)  
**Next File:** Ask for `scripts/lib/logging.sh` when ready!
