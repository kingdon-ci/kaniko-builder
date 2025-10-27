# Ko Test Directory

**Purpose**: Test Ko backend integration in GitHub Actions  
**Status**: Ready for GitHub Actions testing

## 🧪 **What This Tests**

This directory validates:
- ✅ **Ko backend detection** in GitHub Actions workflow
- ✅ **Multi-arch builds** (AMD64 + ARM64) with Ko
- ✅ **GHCR integration** with GitHub Container Registry
- ✅ **Performance benefits** vs traditional Kaniko builds

## 🚀 **Testing the Go Monolith Vision**

### **Monolith Example:**
```bash
# This simulates the Go monolith structure:
my-company/
├── api-service/build-config.yaml      # Ko backend
├── worker-service/build-config.yaml   # Ko backend  
├── admin-portal/build-config.yaml     # Ko backend
└── shared/                            # Common Go modules
```

### **Single Push → Multiple Services:**
```bash
git push origin main
# → GitHub Actions detects multiple Ko services
# → Builds all services 3x faster with Ko backend
# → Pushes to ghcr.io/kingdon-ci/kaniko-builder
# → Creates multi-arch manifests for each service
```

## 🎯 **Expected Results**

When this `ko-test/` directory is changed and pushed:

1. **GitHub Actions triggers** hephy-builder workflow
2. **Change detection** finds `ko-test/` with `build-config.yaml`
3. **Backend detection** identifies `build_backend: ko`
4. **Ko builds execute** for AMD64 and ARM64
5. **Images pushed** to `ghcr.io/kingdon-ci/kaniko-builder:ko-test-*`
6. **Multi-arch manifest** created as `ko-test-latest`

## 📊 **Performance Comparison**

| Metric | Traditional Docker | Ko Backend |
|--------|-------------------|------------|
| **Build Time** | ~2-3 minutes | ~45 seconds |
| **Image Size** | ~45 MB | ~12 MB |
| **Security** | Full OS | Distroless |
| **Maintenance** | Dockerfile + deps | Go config only |

## 🔧 **Testing Steps**

1. **Make a change** to this directory
2. **Commit and push** to trigger workflow
3. **Watch GitHub Actions** for Ko backend execution
4. **Verify images** in GitHub Container Registry
5. **Test deployment** with optimized Ko images

This proves the **Go monolith framework** concept with real performance benefits!

---

**Delete this directory after successful testing to keep the repository clean.**