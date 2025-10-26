# HEPHY_VISION.md - Resurrect "Git Push Deis Main" with Modern Tooling

**Status**: Vision Document - Future Roadmap  
**Target**: hephy-builder v2.0  
**Heritage**: Deis Workflow → Hephy Workflow → Modern Container/WASM Builds

## 🏛️ **The Deis Workflow Heritage**

### **What We Lost**
Back in the day, Deis Workflow provided the **"Heroku in a box"** experience:
- `git push deis main` → automatic builds → running application
- Simple, elegant developer experience
- Platform-as-a-Service without vendor lock-in
- **One command deploy** from any Git repository

### **What Happened**
- **Deis v1**: CoreOS + Fleet + systemd + Docker (worked!)
- **Deis Workflow**: Kubernetes orchestration (advanced!)
- **Acquisition**: Microsoft acquired the team, donated code to CNCF
- **Legacy**: Hephy Workflow continues the vision

### **Modern Reality**
- Everyone wants to **build their own PaaS**
- Complex CI/CD pipelines with dozens of steps
- **Lost simplicity** of `git push` deployment
- Modern tools (Kaniko, Ko, Spin) need integration

## 🎯 **The Hephy Builder Vision**

### **Core Mission: "Git Push Deis Main Again"**
Recreate the **simple deployment experience** with modern, secure, multi-platform tooling.

```bash
# The dream workflow
git add .
git commit -m "fix: update API endpoint"
git push hephy main

# Behind the scenes: 
# 1. Multi-platform CI detection (GitHub Actions or GitLab CI)
# 2. Smart build backend selection (Kaniko/BuildKit/Ko/Spin)
# 3. Multi-arch builds and manifest creation  
# 4. Deploy to modern orchestrator (Kubernetes/SpinKube)
# 5. Tail deployment logs automatically
```

### **Technical Architecture Evolution**

#### **Phase 1: Multi-Backend Builder** (Current Focus)
```yaml
# Enhanced build-config.yaml
build_backend: kaniko|buildkit|ko|spin
ci_platform: gitlab|github  
upstream_repo: https://github.com/owner/repo
platforms:
  - linux/amd64
  - linux/arm64
  - wasm32-wasi  # For Spin builds
```

#### **Phase 2: Platform Portability**
- **GitHub Actions** components equivalent to GitLab CI
- **Portable workflow** files that work in any repository
- **Enterprise support** for self-hosted Git/CI platforms

#### **Phase 3: Modern PaaS Integration**
- **SpinKube integration** for WebAssembly workloads
- **Hephy Workflow compatibility** for container workloads  
- **Post-receive hooks** with log tailing (`gh run watch` equivalent)

## 🛠️ **Build Backend Matrix**

### **Kaniko: The Foundation**
- ✅ **Current working solution**
- ✅ **Security model**: Rootless, no Docker daemon
- ❌ **Limitation**: Cannot build advanced BuildKit features

### **BuildKit: The Advanced**
- 🎯 **Target**: Handle what Kaniko cannot
- ✅ **Features**: `RUN --mount=cache`, `RUN --mount=secret`
- ✅ **Kaniko itself needs BuildKit** to build
- 🔧 **Integration**: Hybrid approach for complex Dockerfiles

### **Ko: The Go Optimizer** 
- 🎯 **Target**: Superior Go application builds
- ✅ **Benefits**: "Far and away superior in the niche it serves, at a lower price"
- ✅ **Features**: No Dockerfile needed, distroless images, fast builds
- 🔧 **Use case**: Automatic backend for Go projects

### **Spin: The Future**
- 🎯 **Target**: WebAssembly application builds
- ✅ **Benefits**: Fast startup, secure sandbox, great developer experience
- ✅ **Orchestration**: SpinKube for Kubernetes deployment
- 🔧 **Vision**: Modern alternative to traditional containers

## 🌉 **Platform Portability Strategy**

### **Current State**: GitLab CI Specific
```yaml
# .gitlab-ci.yml (current)
prepare:
  stage: prepare
  image: alpine/git:latest
  script: ./hack/prepare_diff.sh
```

### **Target State**: Platform Agnostic Components
```yaml
# GitHub Actions (.github/workflows/hephy-build.yml)
name: Hephy Build
on: [push, pull_request]
jobs:
  build:
    uses: kingdon-ci/hephy-builder/.github/workflows/build.yml@main
    with:
      backend: ko  # or kaniko, buildkit, spin
```

```yaml
# GitLab CI (.gitlab-ci.yml)  
include:
  - remote: 'https://raw.githubusercontent.com/kingdon-ci/hephy-builder/main/gitlab/hephy-build.yml'

variables:
  HEPHY_BACKEND: spin  # or kaniko, buildkit, ko
```

## 🎪 **The Developer Experience**

### **Repository Setup** (One-time)
```bash
# Add hephy-builder to any repository
curl -sSL https://install.hephy.dev | bash
# Creates: .hephy/build-config.yaml, CI workflow files
```

### **Project Build Configuration**
```yaml
# .hephy/build-config.yaml
build_backend: ko  # Auto-detected for Go projects
platforms:
  - linux/amd64
  - linux/arm64
additional_tags:
  - latest
  - ${GITHUB_REF_NAME}
```

### **The Magic Moment**
```bash
git push origin main
# → Automatic detection of optimal build backend
# → Multi-arch builds on appropriate CI platform  
# → Registry push with professional tagging
# → Optional: SpinKube/Hephy deployment
# → Log tailing until completion
```

## 🏗️ **Implementation Roadmap**

### **Phase 1: Backend Diversification** (Issues #11, #12)
1. **Add Ko backend** for Go application optimization
2. **Add Spin backend** for WebAssembly builds  
3. **Maintain Kaniko** as stable foundation
4. **Plan BuildKit** integration for advanced features

### **Phase 2: Platform Expansion** (Issue #10)
1. **GitHub Actions** workflow equivalent
2. **Component library** for easy inclusion
3. **Enterprise support** for self-hosted platforms
4. **Migration tools** from GitLab CI to GitHub Actions

### **Phase 3: PaaS Integration** (Future)
1. **SpinKube integration** for WASM orchestration
2. **Hephy Workflow compatibility** for container deployment
3. **Developer experience tools** (log tailing, status monitoring)
4. **Documentation and community building**

## 🎭 **Success Metrics**

### **Technical Excellence**
- **Multi-backend builds**: Ko faster than Kaniko for Go projects
- **Platform portability**: Same config works on GitHub/GitLab
- **Developer experience**: One command from commit to running app

### **Community Impact**
- **Resurrection of simplicity**: "git push deis main" workflow returns
- **Modern security**: WebAssembly + container hybrid deployments
- **Enterprise adoption**: Self-hosted Git/CI platform support

### **Heritage Connection**
- **Deis spirit**: Simple, powerful, developer-focused
- **Modern tooling**: Leverage best of 2025 ecosystem
- **Open source**: Community-driven development and adoption

---

## 💭 **The Vision Statement**

**hephy-builder resurrects the elegant simplicity of "git push deis main" using modern, secure, multi-platform tooling. By supporting multiple build backends (Kaniko, Ko, Spin) and CI platforms (GitHub, GitLab), we provide developers the best tool for each job while maintaining the one-command deployment experience that made Deis Workflow magical.**

**Whether you're building Go microservices with Ko, WebAssembly components with Spin, or traditional containers with Kaniko—hephy-builder handles the complexity so you can focus on code, not CI/CD configuration.**

---
*The future is simple again. `git push hephy main` 🚀*