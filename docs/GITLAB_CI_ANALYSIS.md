# GitLab CI Architecture Analysis & GitHub Actions Migration Strategy

**Document**: Understanding Current Architecture & Planning Multi-Platform Support  
**Date**: October 27, 2025  
**Purpose**: Document limitations, analyze requirements, plan GitHub Actions migration

## 🏗️ **Current GitLab CI Architecture**

### **Three-Stage Pipeline Design**

#### **Stage 1: Prepare (alpine/git:latest)**
**Purpose**: Change detection, architecture filtering, remote repository pre-cloning  
**Capabilities**: Full shell, git, tar/gzip, filesystem operations  
**Key Functions**:
- Runs `hack/prepare_diff.sh` for intelligent change detection
- Filters directories to only those with `build-config.yaml`
- Determines required architectures (AMD64/ARM64) per project
- **Critical Innovation**: Pre-clones remote repositories as `.tar.gz` artifacts
- Creates `dirs.txt`, `need_amd64.txt`, `need_arm64.txt`, `*-source.tar.gz`

#### **Stage 2: Build (martizih/kaniko:v1.26.0-debug)**
**Purpose**: Multi-architecture container builds  
**Severe Limitations**: No shell, no git, no package manager  
**Key Constraints**:
- **Matrix execution**: Separate jobs for AMD64/ARM64 with architecture-specific runners
- **Dependency resolution**: Complex build arg injection for ECR registry references
- **Script limitations**: Cannot extract scripts from YAML due to no shell in Kaniko
- **Remote repo handling**: Must extract pre-cloned `.tar.gz` artifacts
- **Backend support**: Currently only Kaniko, Ko prototype exists but unused

#### **Stage 3: Manifest (custom manifest-tool image)**
**Purpose**: Multi-architecture manifest creation and tagging  
**Capabilities**: manifest-tool, crane, ECR authentication  
**Key Functions**:
- Creates multi-arch manifests from AMD64/ARM64 builds
- Handles additional tags using crane
- Provides professional image tagging (latest, version tags)

### **Critical GitLab CI Limitations**

#### **1. Script Extraction Impossible**
```bash
# CANNOT DO THIS in GitLab CI with Kaniko:
script:
  - ./scripts/build.sh  # Kaniko has no shell to execute this
```

#### **2. No Git in Build Environment**
```bash
# CANNOT DO THIS in Kaniko:
script:
  - git clone $REPO  # No git binary available
```

#### **3. Monolithic Script Embedding**
All build logic must be embedded directly in `.gitlab-ci.yml` because:
- Cannot reference external shell scripts from Kaniko stage
- Cannot use `include:` for shared script libraries effectively
- Results in 600+ line YAML file with complex embedded bash

#### **4. Backend Switching Complexity**
Current Ko support exists but is complex to activate:
```yaml
# Ko backend requires different execution path:
if [ "$BUILD_BACKEND" = "ko" ]; then
  # Ko-specific build logic embedded in YAML
else
  # Kaniko logic embedded in YAML
fi
```

---

## 🎯 **GitHub Actions Migration Strategy**

### **Architecture Advantages in GitHub Actions**

#### **1. Shell Availability**
```yaml
# GitHub Actions can do this:
- name: Build with backend
  run: ./scripts/build-with-backend.sh
```

#### **2. Modular Script Extraction**
```yaml
# Extract common logic to reusable scripts:
- name: Setup build environment  
  run: ./scripts/setup-environment.sh
- name: Build with selected backend
  run: ./scripts/build-images.sh
```

#### **3. Unified Runner Environment**
```yaml
# GitHub Actions runners have git, shell, package managers:
runs-on: ubuntu-latest  # Full Ubuntu environment, not minimal container
```

#### **4. Matrix Build Elegance**
```yaml
strategy:
  matrix:
    arch: [amd64, arm64]
    backend: [kaniko, ko, buildkit]
```

### **Proposed GitHub Actions Workflow Structure**

#### **1. Prepare Job (ubuntu-latest)**
```yaml
prepare:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Run change detection
      run: ./hack/prepare_diff.sh
    - name: Filter and pre-clone
      run: ./scripts/prepare-repos.sh
    - name: Upload artifacts
      uses: actions/upload-artifact@v4
```

#### **2. Build Jobs (ubuntu-latest with matrix)**
```yaml
build:
  needs: prepare
  strategy:
    matrix:
      arch: [amd64, arm64]
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Download artifacts
      uses: actions/download-artifact@v4
    - name: Setup build environment
      run: ./scripts/setup-environment.sh
    - name: Build with backend
      run: ./scripts/build-images.sh
      env:
        ARCH: ${{ matrix.arch }}
```

#### **3. Manifest Job**
```yaml
manifest:
  needs: build
  runs-on: ubuntu-latest
  steps:
    - name: Create multi-arch manifests
      run: ./scripts/create-manifests.sh
```

### **Script Modularization Strategy**

#### **Extract from GitLab CI YAML → Reusable Scripts**
```bash
# hack/prepare_diff.sh (exists)
# scripts/setup-environment.sh (new)
# scripts/build-images.sh (extracted from YAML)
# scripts/create-manifests.sh (extracted from YAML)
# scripts/backend-selector.sh (new)
```

---

## 🔧 **Multi-Backend Implementation Design**

### **Backend Selection Interface**
```yaml
# build-config.yaml - Unified interface for all backends
build_backend: kaniko|ko|buildkit|spin

# Backend-specific configuration sections:
kaniko_config:
  dockerfile_path: Dockerfile
  target: production
  
ko_config:
  import_path: ./cmd/server
  base_image: cgr.dev/chainguard/static:latest
  
buildkit_config:
  frontend: dockerfile.v0
  cache_from: [type=gha]
  
spin_config:
  template: http-rust
  component_name: my-app
```

### **Backend Implementation Strategy**
```bash
# scripts/build-images.sh
case "$BUILD_BACKEND" in
  "kaniko")
    ./scripts/backends/kaniko-build.sh
    ;;
  "ko")
    ./scripts/backends/ko-build.sh
    ;;
  "buildkit")
    ./scripts/backends/buildkit-build.sh
    ;;
  "spin")
    ./scripts/backends/spin-build.sh
    ;;
esac
```

### **Dogfood Build Strategy**

#### **Target: Build hephy-builder Components**
```yaml
# .github/workflows/hephy-dogfood.yml
# Purpose: Build hephy-builder components using hephy-builder
name: Hephy-Builder Self-Build

on: [push, pull_request]

jobs:
  dogfood-build:
    uses: ./.github/workflows/hephy-build.yml
    with:
      directories: |
        manifest-tool
        builder-image
        ko-backend-test
```

#### **Components to Build**
1. **manifest-tool**: Existing working component
2. **builder-image**: All-in-one image with Ko, Kaniko, BuildKit, crane
3. **ko-backend-test**: Go application using Ko backend
4. **action-runner**: GitHub Actions runner image

---

## 🎯 **Implementation Priority & Success Criteria**

### **Phase 1: GitHub Actions Foundation (This Conversation)**
- [ ] Create `.github/workflows/hephy-build.yml`
- [ ] Extract scripts from GitLab CI YAML
- [ ] Test Ko backend with simple Go application
- [ ] Test Kaniko backend maintains compatibility
- [ ] Validate multi-arch matrix builds

### **Phase 2: Backend Parity**
- [ ] Ko backend fully functional in GitHub Actions
- [ ] Kaniko backend maintains feature parity
- [ ] BuildKit backend for advanced Docker features
- [ ] Script modularization complete

### **Phase 3: Interface Stability**
- [ ] Unified `build-config.yaml` format across all backends
- [ ] No breaking changes between backend selections
- [ ] Clear migration path GitLab CI ↔ GitHub Actions
- [ ] Comprehensive documentation and examples

### **Phase 4: Dogfood Validation**
- [ ] hephy-builder builds itself using Ko backend
- [ ] All components build successfully in GitHub Actions
- [ ] Performance benchmarks vs GitLab CI
- [ ] Issue discovery and iteration cycle functional

---

## 💡 **Key Strategic Insights**

### **GitHub Actions Removes Core Limitations**
- ✅ **Shell availability**: Can extract scripts from YAML
- ✅ **Git availability**: Can clone repositories directly in build environment
- ✅ **Package managers**: Can install backend tools dynamically
- ✅ **Matrix elegance**: Native multi-arch + multi-backend matrix support

### **Interface Design Principles**
- **Backend agnostic**: Same configuration format for all backends
- **Progressive enhancement**: Start with minimal viable, add advanced features
- **Migration friendly**: Easy to switch between backends without breaking changes
- **Performance optimized**: Each backend serves its optimal use case

### **Dogfood Benefits**
- **Real-world validation**: Discover issues through actual usage
- **Performance benchmarking**: Compare backends with real applications
- **Contributor onboarding**: Self-contained example of how system works
- **Iteration velocity**: Fast feedback loop for improvements

This architecture analysis forms the foundation for implementing multi-backend, multi-platform hephy-builder with GitHub Actions support while preserving GitLab CI compatibility.