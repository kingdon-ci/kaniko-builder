# PLATFORM_PORTABILITY.md - GitHub Actions vs GitLab CI Configuration

**Status**: Stub Document - Implementation Planning  
**Purpose**: Guide for adapting hephy-builder workflows between CI platforms

## 🔄 **Platform Support Matrix**

### **Current State**: GitLab CI Native
- ✅ **GitLab CI**: Full implementation in `.gitlab-ci.yml`
- ❌ **GitHub Actions**: Not yet implemented
- ❌ **Other platforms**: Jenkins, CircleCI, etc. (future)

### **Target State**: Platform Agnostic
- ✅ **GitHub Actions**: Equivalent workflow components
- ✅ **GitLab CI**: Maintain existing functionality  
- 🔧 **Hybrid**: Same repository supporting both platforms
- 🔧 **Enterprise**: Self-hosted Git/CI environments

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
# .hephy/config.yaml (platform-agnostic)
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

## **Platform-Specific Implementations**

### **GitHub Actions Pattern**
```yaml
# .github/workflows/hephy-build.yml
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

### **GitLab CI Pattern**
```yaml
# .gitlab-ci.yml
include:
  - remote: 'https://raw.githubusercontent.com/kingdon-ci/hephy-builder/main/gitlab/hephy-build.yml'

variables:
  HEPHY_BACKEND: kaniko
  HEPHY_PLATFORMS: 'linux/amd64,linux/arm64'
```

*[TODO: Research GitLab CI include patterns, variable inheritance]*

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

### **Multi-Registry Support**
```yaml
# Platform-agnostic registry configuration
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

## **Future Platforms**

### **Potential Integrations**
- **Jenkins**: Pipeline as code support
- **CircleCI**: Configuration translation
- **Azure DevOps**: YAML pipeline compatibility
- **AWS CodeBuild**: CloudFormation integration

*[TODO: Assess demand for additional platforms]*