# MIGRATION_GUIDE.md - From kaniko-builder to hephy-builder

**Status**: Stub Document - Implementation Planning  
**Purpose**: Step-by-step guide for existing users to adopt hephy-builder features

## 🚀 **Migration Overview**

### **What's Changing**
- **Name**: kaniko-builder → hephy-builder
- **Scope**: Single backend → Multiple backends (Kaniko, Ko, BuildKit, Spin)
- **Platforms**: GitLab CI only → GitHub Actions + GitLab CI
- **Vision**: Container builds → Modern PaaS resurrection

### **What's NOT Changing**
- ✅ **Existing configurations**: Current `build-config.yaml` still works
- ✅ **GitLab CI pipeline**: Continues to function unchanged
- ✅ **Registry destinations**: ECR/Docker Hub/etc. still supported
- ✅ **Multi-arch builds**: Same architecture support

## **Migration Phases**

### **Phase 1: Backward Compatibility** (Immediate)
**Current kaniko-builder users can continue without changes**

```yaml
# Existing build-config.yaml works as-is
upstream_repo: https://github.com/owner/repo
dockerfile_path: Dockerfile
platforms:
  - linux/amd64  
  - linux/arm64
additional_tags:
  - latest
```

### **Phase 2: Backend Selection** (Opt-in)
**Add backend selection for optimization**

```yaml
# Enhanced build-config.yaml
build_backend: kaniko  # Default, no change
# OR
build_backend: ko      # Optimize Go applications
# OR  
build_backend: spin    # WebAssembly builds
```

### **Phase 3: Platform Expansion** (Choose your CI)
**Add GitHub Actions support while maintaining GitLab CI**

```yaml
# New .hephy/config.yaml (optional)
build_backend: ko
ci_platforms:
  - gitlab
  - github  # Enable GitHub Actions
platforms:
  - linux/amd64
  - linux/arm64
```

## **Step-by-Step Migration**

### **Step 1: Update Documentation References**
```bash
# Update any references in your documentation
# kaniko-builder → hephy-builder
# "container builds" → "modern PaaS builds"
```

### **Step 2: Evaluate Build Backend**
```bash
# For Go applications
build_backend: ko      # Faster builds, smaller images

# For complex Dockerfiles  
build_backend: buildkit # Advanced features

# For WebAssembly
build_backend: spin     # Modern WASM deployment

# For maximum compatibility
build_backend: kaniko   # Existing behavior (default)
```

### **Step 3: Choose CI Platform Strategy**
- **GitLab CI only**: No changes required
- **GitHub Actions only**: Migrate workflows
- **Both platforms**: Hybrid configuration
- **Enterprise**: Custom runner setup

*[TODO: Create platform migration scripts]*

### **Step 4: Test New Features**
```yaml
# Gradual adoption approach
directories:
  old-app/:
    build_backend: kaniko    # Keep existing
  new-service/:  
    build_backend: ko        # Optimize new projects
  experimental/:
    build_backend: spin      # Try WebAssembly
```

## **Configuration Mapping**

### **Kaniko Backend** (Default)
```yaml
# No changes needed - existing configs work
build_backend: kaniko  # Optional, this is default
dockerfile_path: Dockerfile
context_path: .
```

### **Ko Backend** (Go Optimization)
```yaml
build_backend: ko
ko_config:
  import_path: ./cmd/server
  base_image: distroless.dev/static-debian12
  ldflags: ["-s", "-w"]
```

### **Spin Backend** (WebAssembly)
```yaml
build_backend: spin
spin_config:
  template: http-rust
  component_name: my-wasm-app
platforms:
  - wasm32-wasi  # Different platform target
```

*[TODO: Complete configuration examples for all backends]*

## **Troubleshooting Common Issues**

### **Build Backend Selection**
```bash
# Problem: Don't know which backend to choose
# Solution: Start with current (kaniko), optimize later

# Go application?
build_backend: ko

# Complex Dockerfile with BuildKit features?
build_backend: buildkit

# Want to try WebAssembly?
build_backend: spin

# Maximum compatibility?
build_backend: kaniko  # (default)
```

### **Platform Migration**
```bash
# Problem: GitLab CI works, GitHub Actions fails
# Solution: Check runner availability, secret configuration

# Problem: Authentication differences between platforms  
# Solution: Use platform-specific credential configuration
```

*[TODO: Add common error scenarios and solutions]*

## **Performance Optimization**

### **Build Speed Improvements**
- **Ko**: Typically 2-3x faster than Kaniko for Go apps
- **BuildKit**: Better caching, parallel builds  
- **Spin**: Fast WASM compilation

### **Image Size Reductions**
- **Ko**: Distroless base images, optimized binaries
- **Spin**: WASM modules typically smaller than containers

*[TODO: Add benchmark comparisons]*

## **Feature Parity Matrix**

| Feature | kaniko-builder | hephy-builder | Notes |
|---------|---------------|---------------|-------|
| Multi-arch builds | ✅ | ✅ | Same functionality |
| Remote repositories | ✅ | ✅ | Same pre-clone system |
| Additional tags | ✅ | ✅ | Same crane integration |
| GitLab CI | ✅ | ✅ | Maintained compatibility |
| GitHub Actions | ❌ | 🔧 | New feature |
| Ko builds | ❌ | 🔧 | New backend |
| Spin builds | ❌ | 🔧 | New backend |

*[TODO: Complete feature comparison table]*

## **Migration Timeline**

### **Immediate** (Available Now)
- ✅ Backward compatibility maintained
- ✅ New backend selection (opt-in)
- ✅ Documentation updates

### **Short Term** (Next Release)
- 🔧 GitHub Actions workflows
- 🔧 Platform portability tools
- 🔧 Migration automation

### **Long Term** (Future Releases)
- 🔧 SpinKube integration
- 🔧 Advanced enterprise features
- 🔧 Community templates

## **Support and Community**

### **Getting Help**
- **GitHub Issues**: Technical problems and feature requests
- **Documentation**: Updated guides and examples
- **Community**: Deis/Hephy heritage discussions

### **Contributing Back**
- **Backend implementations**: New build system support
- **Platform adapters**: Additional CI/CD platforms
- **Documentation**: Usage examples and best practices

*[TODO: Set up community channels, contribution guidelines]*