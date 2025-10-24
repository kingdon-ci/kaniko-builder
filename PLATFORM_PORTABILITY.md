# PLATFORM_PORTABILITY.md - GitHub Actions vs GitLab CI Configuration

**Status**: Stub Document - Implementation Planning  
**Purpose**: Guide for adapting hephy-builder workflows between CI platforms

## 🔄 **Platform Support Matrix**

### **Current State**: GitLab CI Native
- ✅ **GitLab CI**: Full implementation in `.gitlab-ci.yml`
- ❌ **GitHub Actions**: Not yet implemented

### **Target State**: Dual Platform Support
- ✅ **GitHub Actions**: Equivalent workflow components
- ✅ **GitLab CI**: Maintain existing functionality  
- 🔧 **Hybrid**: Same repository supporting both platforms
- 🔧 **Enterprise**: Self-hosted GitHub/GitLab environments

**Scope Note**: This is about **CI integration only**. Deployment is handled by FluxCD with Image Update Automation, Semver Wildcards, and GitOps patterns. We're not rebuilding Deis Controller or complex CD pipelines—FluxCD already solved that problem elegantly.

## **Architecture Patterns**

### **Component-Based Design**
```
hephy-builder/
├── github/
│   ├── workflows/
│   │   ├── hephy-build.yml     # Reusable workflow
│   │   └── hephy-deploy.yml    # Optional deployment
│   └── actions/
│       ├── prepare/            # Change detection
│       ├── build/              # Multi-arch builds  
│       └── manifest/           # Manifest creation
├── gitlab/
│   ├── hephy-build.yml         # Include template
│   └── components/             # Job templates
└── shared/
    ├── scripts/                # Platform-agnostic scripts
    └── configs/                # Default configurations
```

### **Configuration Abstraction**
```yaml
# .hephy/config.yaml (PROPOSED - NOT YET IMPLEMENTED)
# This is a mock structure showing potential future configuration
build_backend: ko
platforms:
  - linux/amd64
  - linux/arm64
registry: ${REGISTRY_URL}
additional_tags:
  - latest
  - ${CI_COMMIT_REF_NAME}  # GitLab variable
  - ${GITHUB_REF_NAME}     # GitHub variable
```

**Current Reality**: We use `build-config.yaml` in each directory. The above is a **proposed enhancement** for platform-agnostic configuration.

**Current Specification**: See `BUILD_CONFIG_SPEC.md` for the complete, formal specification of the existing `build-config.yaml` format.

## **Current build-config.yaml Specification**

### **Existing Format** (Currently Implemented)
```yaml
# Example: curl/build-config.yaml (WORKING)
use_local_context: true
dockerfile_path: Dockerfile
context_path: .
platforms:
  - linux/amd64
  - linux/arm64
additional_tags:
  - latest
```

```yaml
# Example: Remote repository (WORKING)  
upstream_repo: https://github.com/spkane/scratch-helloworld
upstream_ref: main
dockerfile_path: Dockerfile
context_path: .
platforms:
  - linux/amd64
  - linux/arm64
additional_tags:
  - latest
  - pipeline-test
```

**Documentation**: See existing `build-config.yaml` files in `curl/`, `manifest-tool/`, `test-app/` directories for working examples.

## **Platform-Specific Implementations**

### **GitHub Actions Pattern** (PROPOSED)
```yaml
# .github/workflows/hephy-build.yml (NOT YET IMPLEMENTED)
name: Hephy Build
on: [push, pull_request]
jobs:
  build:
    uses: kingdon-ci/hephy-builder/.github/workflows/build.yml@main
    with:
      backend: ${{ inputs.backend || 'kaniko' }}
      platforms: 'linux/amd64,linux/arm64'
    secrets: inherit
```

*[TODO: Research GitHub Actions reusable workflows best practices]*

### **GitLab CI Pattern** (CURRENTLY WORKING)
```yaml
# .gitlab-ci.yml (IMPLEMENTED AND FUNCTIONAL)
stages:
  - prepare
  - build
  - manifest

prepare:
  stage: prepare
  image: alpine/git:latest
  script: ./hack/prepare_diff.sh
  # ... (see actual .gitlab-ci.yml for complete implementation)
```

**Documentation**: See `.gitlab-ci.yml` (495 lines) for the complete, working implementation.

## **Variable Mapping**

### **Common Variables**
| Concept | GitHub Actions | GitLab CI | Notes |
|---------|---------------|-----------|-------|
| Commit SHA | `${{ github.sha }}` | `$CI_COMMIT_SHA` | Full commit hash |
| Branch name | `${{ github.ref_name }}` | `$CI_COMMIT_REF_NAME` | Branch/tag name |
| Repository | `${{ github.repository }}` | `$CI_PROJECT_PATH` | owner/repo format |
| Build number | `${{ github.run_number }}` | `$CI_PIPELINE_IID` | Incremental build ID |

*[TODO: Complete variable mapping table, edge case handling]*

## **Authentication Patterns**

### **Registry Authentication**
- **GitHub**: OIDC tokens, repository secrets
- **GitLab**: CI/CD variables, project access tokens
- **Enterprise**: Custom credential providers

*[TODO: Research OIDC federation, credential security best practices]*

### **Multi-Registry Support** (PROPOSED)
```yaml
# Platform-agnostic registry configuration (NOT YET IMPLEMENTED)
registries:
  - name: ghcr
    url: ghcr.io
    auth: github-token
  - name: gitlab
    url: registry.gitlab.com  
    auth: gitlab-token
  - name: ecr
    url: ${ECR_REGISTRY}
    auth: aws-oidc
```

*[TODO: Design registry abstraction layer]*

**Current Reality**: Registry configuration is handled via environment variables in `.gitlab-ci.yml`. See `ECR_REGISTRY` usage in working pipeline.

## **Migration Strategies**

### **GitLab to GitHub**
1. **Analysis**: Scan existing `.gitlab-ci.yml`
2. **Translation**: Convert to GitHub Actions syntax
3. **Testing**: Validate in GitHub environment
4. **Gradual rollout**: Parallel CI during transition

### **GitHub to GitLab**
1. **Workflow mapping**: Actions → GitLab jobs
2. **Secret migration**: Repository secrets → CI/CD variables
3. **Runner compatibility**: Ensure equivalent execution environment

### **Hybrid Approach**
- **Same repository**: Both `.gitlab-ci.yml` and `.github/workflows/`
- **Conditional logic**: Platform-specific optimizations
- **Shared components**: Maximum code reuse

*[TODO: Create migration tools, validation scripts]*

## **Enterprise Considerations**

### **Self-Hosted Environments**
- **Custom runners**: On-premises GitLab/GitHub
- **Network restrictions**: Air-gapped, proxy configurations
- **Compliance**: Security scanning, audit trails

### **Multi-Platform Teams**
- **Developer choice**: GitHub or GitLab preference
- **Organizational standards**: Consistent policies across platforms
- **Migration support**: Moving between platforms

*[TODO: Research enterprise deployment patterns]*

## **Deployment Integration**

### **FluxCD-First Approach**
hephy-builder focuses on **CI integration only**. Deployment is handled by **FluxCD** using modern GitOps patterns:

- **Image Update Automation**: Automatic updates when new images are built
- **Semver Wildcards**: Smart version selection without complex CD pipelines  
- **GitOps**: Declarative configuration in Git repositories

### **Deployment Targets** (Outside hephy-builder scope)
- **Flux + Crossplane**: Infrastructure provisioning
- **Flux + Helm**: Application deployment
- **Flux + Terraform**: Hybrid infrastructure/application management

**Philosophy**: Don't rebuild what FluxCD already does well. Focus on making great container/WASM images, let Flux handle deployment elegantly.

## **Future Platforms**

### **Additional CI Support** (Community-driven)
- **Azure DevOps**: Community could port hephy-builder patterns
- **Self-hosted solutions**: Enterprise GitLab/GitHub instances

**Scope Limitation**: We're building GitHub Actions + GitLab CI support. Other platforms are **community porting opportunities**, not core development targets.

*[TODO: Create community contribution guidelines for platform ports]*