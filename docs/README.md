# 📚 hephy-builder Documentation

**Vision**: Resurrect the magic of `git push deis main` with modern, secure, multi-platform tooling.

> *"Sometimes you need the Rube Goldberg harmony of multiple tools working together. Sometimes you need both GitHub and GitLab. Sometimes you need containers AND WebAssembly. These are ingredients. We're not here to tell developers where they can shop, or what they're allowed to cook with."*

## 🚀 **Quick Start**

### **I want to build containers right now**
- 📖 **[BUILD_CONFIG_SPEC.md](BUILD_CONFIG_SPEC.md)** - Complete build-config.yaml reference
- 🚀 **[DEPLOYMENT.md](DEPLOYMENT.md)** - Deploy the pipeline to your GitLab CI

### **I want to understand the vision**  
- 🏛️ **[lore/DEIS_HERITAGE.md](lore/DEIS_HERITAGE.md)** - The story that brought us here
- 🎯 **[lore/HEPHY_VISION.md](lore/HEPHY_VISION.md)** - Where we're going: "git push deis main" for 2025

### **I want to contribute**
- 🔨 **[../ROADMAP.md](../ROADMAP.md)** - Current development priorities
- 🐛 **[GitHub Issues](https://github.com/kingdon-ci/kaniko-builder/issues)** - Active tasks and features
- 💡 **[MANUAL_BUILD_PROCESS.md](MANUAL_BUILD_PROCESS.md)** - Advanced BuildKit workflows

---

## 📋 **Documentation Map**

### **📖 Technical Documentation**
| Document | Purpose | Audience |
|----------|---------|----------|
| **[BUILD_CONFIG_SPEC.md](BUILD_CONFIG_SPEC.md)** | Complete build-config.yaml specification | Developers, CI Engineers |
| **[DEPLOYMENT.md](DEPLOYMENT.md)** | GitLab CI deployment guide | DevOps, Platform Teams |
| **[MANUAL_BUILD_PROCESS.md](MANUAL_BUILD_PROCESS.md)** | BuildKit manual build procedures | Advanced Users |

### **🏛️ Heritage & Vision (`lore/`)**
| Document | Purpose | Audience |
|----------|---------|----------|
| **[lore/DEIS_HERITAGE.md](lore/DEIS_HERITAGE.md)** | The PaaS story and what we lost | Architects, Product Managers |
| **[lore/HEPHY_VISION.md](lore/HEPHY_VISION.md)** | Future roadmap and philosophy | Contributors, Stakeholders |

### **🗂️ Legacy Documentation (`../attic/`)**
| Directory | Content | Status |
|-----------|---------|--------|
| **[../attic/cold-storage/](../attic/cold-storage/)** | Resolved issues and historical context | Archived ✅ |
| **[../attic/docs/](../attic/docs/)** | Bootstrap process documentation | Reference 📚 |

---

## 🎯 **The hephy-builder Journey**

### **Phase 1: Multi-Backend Foundation** *(Current)*
- ✅ **Kaniko**: Rootless container builds (production ready)
- 🎯 **Ko**: Optimized Go application builds ([Issue #12](https://github.com/kingdon-ci/kaniko-builder/issues/12))
- 🎯 **Spin**: WebAssembly builds ([Issue #11](https://github.com/kingdon-ci/kaniko-builder/issues/11))

### **Phase 2: Platform Expansion** *(Roadmap)*
- 🎯 **GitHub Actions**: Portable workflow components
- 🎯 **Enterprise**: Self-hosted Git/CI platform support
- 🎯 **Component Library**: Drop-in hephy-builder for any repository

### **Phase 3: PaaS Resurrection** *(Vision)*
- 🎯 **SpinKube Integration**: WebAssembly orchestration
- 🎯 **FluxCD-First Deployment**: GitOps without CD pipeline complexity
- 🎯 **Developer Experience**: `git push hephy main` reality

---

## 🤝 **Contributing to hephy-builder**

### **🚀 Quick Contribution Paths**
1. **📝 Documentation**: Improve guides, add examples, fix typos
2. **🧪 Testing**: Try builds in your environment, report issues
3. **🔧 Backend Implementation**: Help add Ko, BuildKit, or Spin support
4. **🌍 Platform Support**: GitHub Actions workflow components

### **🎯 High-Impact Opportunities**
- **Backend Research**: Complete the builder comparison matrix
- **GitHub Actions**: Port GitLab CI pipeline to GitHub workflows  
- **Real-World Testing**: Validate builds with complex applications
- **Enterprise Features**: Self-hosted platform support

### **📞 Get Involved**
- 🐛 **[Open Issues](https://github.com/kingdon-ci/kaniko-builder/issues)** - Pick up a task
- 💬 **[Discussions](https://github.com/kingdon-ci/kaniko-builder/discussions)** - Share ideas
- 📖 **[Contributing Guide](../MIGRATION_GUIDE.md)** - Migration and contribution patterns

---

## 🏗️ **Architecture Overview**

### **Current Implementation** *(Production Ready)*
```
GitLab CI Pipeline (.gitlab-ci.yml)
├── prepare: Change detection & architecture filtering  
├── build_amd64: Kaniko builds for AMD64
├── build_arm64: Kaniko builds for ARM64
└── manifest: Multi-arch manifest creation
```

### **Future Vision** *(Multi-Platform, Multi-Backend)*
```
hephy-builder Core
├── backends/
│   ├── kaniko: Secure rootless builds
│   ├── ko: Optimized Go applications  
│   ├── buildkit: Advanced Dockerfile features
│   └── spin: WebAssembly applications
├── platforms/
│   ├── gitlab-ci: Current implementation
│   ├── github-actions: Portable workflows
│   └── enterprise: Self-hosted platforms
└── deployment/
    ├── fluxcd: GitOps deployment
    ├── spinkube: WASM orchestration
    └── traditional: Kubernetes manifests
```

---

## 🎨 **Design Philosophy**

### **🏛️ Deis Heritage**
- **Simplicity First**: `git push` should just work
- **Developer Experience**: Tools should disappear, applications should shine
- **No Vendor Lock-in**: Platform portability is essential

### **🔧 Modern Reality**  
- **Security**: Rootless builds, capability-based sandboxing
- **Performance**: Optimal tool selection per project type
- **Flexibility**: Multiple backends, multiple platforms

### **🌉 The Bridge**
**hephy-builder** connects the elegant simplicity of Deis Workflow with the power and security of modern container/WASM tooling. We're not rebuilding the entire PaaS—we're rebuilding the developer experience.

---

*Welcome to hephy-builder. Let's make `git push deis main` magic again.* ✨