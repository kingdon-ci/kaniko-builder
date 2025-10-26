# hephy-builder: Resurrect "git push deis main" with Modern Tooling

**Vision**: Bring back the elegant simplicity of Platform-as-a-Service deployment using secure, multi-platform container and WebAssembly builds.

> *"Sometimes you need the Rube Goldberg harmony of multiple tools working together. Sometimes you need both GitHub and GitLab. Sometimes you need containers AND WebAssembly. These are ingredients. We're not here to tell developers where they can shop, or what they're allowed to cook with."*

## 🚀 **Quick Start**

### **I want to build containers right now**
- 📖 **[Build Configuration Guide](docs/BUILD_CONFIG_SPEC.md)** - Complete build-config.yaml reference
- 🚀 **[Deployment Guide](docs/DEPLOYMENT.md)** - Deploy the pipeline to your GitLab CI

### **I want to understand the vision**  
- 🏛️ **[The Deis Heritage Story](docs/lore/DEIS_HERITAGE.md)** - The PaaS magic we're bringing back
- 🎯 **[hephy-builder Vision](docs/lore/HEPHY_VISION.md)** - Modern "git push deis main" for 2025

### **I want to contribute**
- 🔨 **[Project Roadmap](ROADMAP.md)** - Current development priorities
- 🐛 **[GitHub Issues](https://github.com/kingdon-ci/kaniko-builder/issues)** - Active tasks and features
- 📚 **[Documentation Hub](docs/README.md)** - Comprehensive project navigation

## 📋 **What This Project Provides**

### **Current Capabilities** *(Production Ready)*
- **Multi-architecture builds**: AMD64 + ARM64 container images
- **Secure builds**: Rootless Kaniko execution, no Docker daemon required
- **Smart pipelines**: Change detection, architecture filtering, dependency resolution
- **Professional tagging**: Support for latest, version tags, and custom naming
- **Remote repositories**: Build any GitHub repository with multi-arch support

### **Future Vision** *(Roadmap)*
- **Ko Backend**: Optimized Go application builds with distroless images
- **Spin Backend**: WebAssembly applications with millisecond startup
- **BuildKit Backend**: Advanced Dockerfile features and enhanced caching
- **GitHub Actions**: Portable workflows equivalent to GitLab CI
- **Git Remote Server**: True "git push hephy main" experience with real-time logs

## 📊 **Current Status: MVP Complete → Transformation Phase**

### **✅ Production Ready Foundation**
- Multi-architecture CI/CD pipeline (AMD64 + ARM64)
- Remote repository building (validated with real-world Go applications)
- Professional image tagging and registry management
- Clean architecture with no circular dependencies

### **🚀 Active Development** *(Post-Merger)*
- **Backend diversification**: Adding Ko, Spin, and BuildKit support
- **Platform expansion**: GitHub Actions workflow components
- **Developer experience**: Git remote server for "push to deploy" workflow
- **Community growth**: Documentation, examples, and contributor onboarding

## 🏗️ **Architecture Overview**

### **Current Implementation**
```yaml
GitLab CI Pipeline (.gitlab-ci.yml)
├── prepare: Change detection & architecture filtering  
├── build_amd64: Kaniko builds for AMD64
├── build_arm64: Kaniko builds for ARM64
└── manifest: Multi-arch manifest creation
```

### **Future Vision** *(hephy-builder)*
```yaml
Multi-Backend Builder
├── backends: kaniko | ko | buildkit | spin
├── platforms: gitlab-ci | github-actions  
├── git-server: SSH with real-time log streaming
└── deployment: FluxCD | direct-k8s | traditional
```

## 🌍 **The Deis Heritage Connection**

### **What We Lost**
In the golden age of Platform-as-a-Service (2014-2017), Deis Workflow provided the magical experience:
```bash
git push deis main
# → Real-time build logs streamed back
# → Automatic deployment 
# → "-----> myapp deployed to https://myapp.deis.example.com"
```

**No YAML configuration files. No pipeline definitions. Just git push.**

### **What We're Building Back**
hephy-builder resurrects that elegant simplicity using modern, secure tooling:
- **Multiple build backends**: Choose the optimal tool (Kaniko/Ko/Spin/BuildKit)
- **Platform portability**: Works with GitHub Actions OR GitLab CI
- **Security-first**: Rootless builds, WebAssembly sandboxing  
- **Heritage-inspired**: "git push hephy main" experience for 2025

## 🤝 **Getting Started**

### **Current Users (kaniko-builder)**
✅ **Zero breaking changes** - your existing configurations continue working  
✅ **Immediate benefits** - multi-arch builds, remote repositories, professional tagging  
✅ **Future compatibility** - automatic migration path to hephy-builder features

### **New Users**
1. **Deploy the pipeline**: Follow the [Deployment Guide](docs/DEPLOYMENT.md)
2. **Configure your builds**: Use [Build Configuration Spec](docs/BUILD_CONFIG_SPEC.md)  
3. **Explore the vision**: Read the [Heritage Story](docs/lore/DEIS_HERITAGE.md)

### **Contributors**
- 🐛 **[Active Issues](https://github.com/kingdon-ci/kaniko-builder/issues)** - Pick up a task
- 📚 **[Documentation Hub](docs/README.md)** - Comprehensive project navigation
- 🎯 **[Development Roadmap](ROADMAP.md)** - See where we're heading

## 📁 **Project Structure**

```
hephy-builder/
├── docs/                   # 📚 Complete documentation hub
│   ├── README.md          #     Navigation and contribution guide  
│   ├── BUILD_CONFIG_SPEC.md #   Configuration reference
│   ├── DEPLOYMENT.md       #     GitLab CI deployment guide
│   └── lore/              #     Heritage and vision
├── .gitlab-ci.yml         # 🚀 Production GitLab CI pipeline  
├── hack/                  # 🔧 Build scripts and utilities
├── curl/                  # 📦 Bootstrap utility example
├── kaniko/                # 📦 Main build target (disabled)
├── manifest-tool/         # 📦 Multi-arch manifest creation
└── test-app/              # 📦 Example application builds
```

## 💡 **Why hephy-builder?**

### **For Developers**
- **Elegant workflow**: Approaching "git push hephy main" simplicity
- **Modern security**: Rootless builds, no Docker daemon required
- **Performance**: Optimal backend selection (Ko for Go, Spin for WASM)
- **Platform freedom**: GitHub Actions or GitLab CI, your choice

### **For Platform Teams**  
- **Multi-architecture**: Native AMD64 + ARM64 support
- **Enterprise ready**: Self-hosted environments, compliance features
- **Cost optimization**: Spot instances, smart change detection
- **Heritage proven**: Built on lessons from Deis Workflow success

### **For The Community**
- **Open source**: No vendor lock-in, community-driven development
- **Educational**: Learn PaaS evolution and modern container/WASM tooling  
- **Contributor friendly**: Clear issues, good documentation, welcoming community

---

**Welcome to hephy-builder. Let's make "git push deis main" magic again.** ✨

*Continuing the Deis Workflow heritage with modern tooling for 2025 and beyond.*
