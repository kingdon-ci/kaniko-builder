# AGENTS.md - AI Assistant Context for hephy-builder

**Purpose**: This document provides comprehensive context for AI assistants to quickly understand the hephy-builder project, its current state, architecture, and capabilities.

**Repository**: `kingdon-ci/kaniko-builder` (GitHub)  
**Last Updated**: October 26, 2025 (Post-PR #13 merge - hephy-builder transformation complete)  
**Status**: ✅ **MVP COMPLETE - TRANSFORMATION PHASE** 🚀  
**Vision**: **Resurrect "git push deis main" with modern tooling**

## 🔒 Security Guidelines for AI Assistants

**CRITICAL**: When creating GitHub issues or public documentation, **NEVER** expose sensitive information:
- ❌ **AWS Account Numbers**: Never include account IDs like `[redacted 12-digit AWS account id]`
- ❌ **ECR Registry URLs**: Use `<ECR-REGISTRY>` placeholder instead of real URLs
- ❌ **Internal hostnames**: Use generic examples instead of actual infrastructure
- ❌ **API keys, tokens, credentials**: Obviously never expose these

**Safe Approach**: Always use placeholders like `<ECR-REGISTRY>`, `<ACCOUNT-ID>`, `<REGION>` in public issues and documentation. The goal is to document technical patterns without exposing infrastructure details.

## Project Status

### ✅ MVP Complete (October 16, 2025)
The project has achieved a functional multi-architecture container build pipeline that meets the original specifications.

### 🚀 Evolution to Hephy Builder (October 24, 2025)
**New Vision**: Transform from single-purpose kaniko pipeline to comprehensive builder supporting the modern resurrection of Deis Workflow experience.

### Current Capabilities
- **Remote repository builds**: Clone and build GitHub repositories with multi-arch support
- **Professional image tagging**: Support for `latest`, `v1.0.0` style tags with full multi-arch support
- **Smart pipeline**: Change detection, architecture filtering, dependency resolution
- **Production validated**: Go applications built successfully (spkane/scratch-helloworld)
- **Clean architecture**: No circular dependencies

### Future Capabilities (Hephy Builder Vision)
- **Multi-platform CI**: Support for both GitHub Actions and GitLab CI
- **Multiple build backends**: Kaniko, BuildKit, Ko (Go-optimized), Spin (WebAssembly)
- **Portable workflows**: Drop-in components for any Git repository
- **Modern PaaS resurrection**: "git push deis main" experience with modern tooling

### Core Mission Evolution
**Original**: Build Kaniko itself since upstream no longer publishes builds  
**Current**: Sandbox-validated pipeline using maintained external Kaniko with support for building additional projects  
**Future**: Comprehensive hephy-builder supporting multiple backends and modern "git push deis main" workflow resurrection

### Key Features (Sandbox-Validated)
- **Multi-architecture support**: amd64 + arm64 builds functional
- **Remote repository cloning**: GitHub integration validated in sandbox
- **Professional tagging**: Additional tags support implemented
- **Smart change detection**: Builds only changed directories
- **Multi-arch manifests**: Automatic architecture selection functional
- **External project support**: Generalized framework validated in sandbox

## 📁 Repository Structure

```
kaniko-builder/
├── .gitlab-ci.yml              # Main CI pipeline (495 lines)
├── hack/
│   ├── prepare_diff.sh         # Change detection script (adapted from minimal-base-image)
│   └── README.md
├── README.md                   # Basic project info
├── SPEC.md                     # Original specification (222 lines)
├── IMPLEMENTATION_PLAN.md      # Multi-arch runner setup plan (297 lines)
├── PROGRESS_REPORT.md          # Detailed status report (current state)
├── rebuild-weekly.txt          # List for scheduled builds: kaniko, curl
├── curl/                       # Bootstrap utility (WORKING)
│   ├── build-config.yaml
│   ├── Dockerfile
│   └── README.md
├── kaniko/                     # Main target (BLOCKED by remote cloning)
│   ├── build-config.yaml
│   └── README.md
├── manifest-tool/              # Manifest creation tool (WORKING)
│   ├── build-config.yaml
│   ├── Dockerfile
│   └── README.md
└── attic/                      # Reference configs and examples
    ├── crossplane-node-pool-objects.yaml
    ├── example-gitlab-runner.yaml
    ├── gitlab-runner-amd64.yaml
    ├── gitlab-runner-arm64.yaml
    ├── minimal-example.gitlab-ci.yml
    └── docs/
```

## 🔧 Build Configuration System

### build-config.yaml Format
Each buildable directory contains a `build-config.yaml` file:

```yaml
# Remote repository mode (CURRENTLY BROKEN)
upstream_repo: https://github.com/chainguard-dev/kaniko
upstream_ref: v1.25.3
dockerfile_path: deploy/Dockerfile
target: "debug"

# Local context mode (WORKING)
use_local_context: true
dockerfile_path: Dockerfile

# Common fields
context_path: .
build_args: []
platforms:
  - linux/amd64
  - linux/arm64
additional_tags:
  - latest
  - v1.25.3
```

### Key Differences Between Modes
- **Local context** (`use_local_context: true`): Uses files in the directory - WORKING
- **Remote repository**: Clones from `upstream_repo` - BROKEN (needs git in Kaniko image)

## 🚦 Current Pipeline Flow

### Stage 1: Prepare
- **Runner**: Uses `$CICD_TAG` (general purpose)
- **Image**: `alpine/git:latest`
- **Purpose**: Change detection and architecture filtering
- **Script**: `hack/prepare_diff.sh`
- **Outputs**:
  - `dirs.txt`: Directories to build (only those with build-config.yaml)
  - `need_amd64.txt`: "true" if any directory needs amd64 builds
  - `need_arm64.txt`: "true" if any directory needs arm64 builds

### Stage 2: Build (Parallel)
- **build_amd64**: Uses `$CICD_TAG_AMD64` runner
- **build_arm64**: Uses `$CICD_TAG_ARM64` runner
- **Image**: `gcr.io/kaniko-project/executor:debug`
- **Smart filtering**: Jobs exit early if their architecture isn't needed
- **Outputs**: `*.tag` files containing arch-specific image tags

### Stage 3: Manifest
- **Runner**: Uses `$CICD_TAG` (general purpose)
- **Image**: `$ECR_REGISTRY:manifest-tool-20251015-amd64`
- **Purpose**: Creates multi-arch manifests from arch-specific builds
- **Issue**: Missing `prepare` dependency (documented bug)

## ✅ What's Working (Bootstrap Complete)

### Successful Builds
1. **curl**: Bootstrap utility image
   - Tag: `curl-20251015-amd64`
   - Uses local context
   - Based on `curlimages/curl:latest`

2. **manifest-tool**: Manifest creation utility
   - Tag: `manifest-tool-20251015-amd64`
   - Uses curl as base image (dependency chaining works!)
   - Contains manifest-tool binary for creating multi-arch manifests

### Working Infrastructure
- ✅ Multi-arch runners deployed (AMD64 and ARM64 spot instances)
- ✅ ECR authentication via ecr-login credential helper
- ✅ Architecture detection and filtering
- ✅ Dependency chaining (manifest-tool → curl)
- ✅ Change detection with prepare_diff.sh
- ✅ Single-arch builds for local context projects

## Critical Issues Resolved

### Issue #2: Remote Repository Cloning - Resolved
**Status**: GitHub Issue #2 CLOSED - Pre-clone artifact system functional

**Evidence**:
```bash
- spkane/scratch-helloworld built successfully from GitHub
- test-app-20251016-main multi-arch manifest created  
- Remote cloning validated with Go HTTP server example
```

**Solution Implemented**: Pre-clone in prepare stage using alpine/git, package as tar.gz artifacts, extract in build stage.

### Issue #4: Additional Tags Support - Resolved
**Status**: GitHub Issue #4 CLOSED - Professional tagging functional

**Evidence**:
```bash
- test-app-latest (multi-arch)
- test-app-pipeline-test (multi-arch)  
- crane integration functional
```

**Solution Implemented**: Added crane to manifest-tool, implemented additional tags logic in manifest stage.

### Circular Dependencies - Resolved
**Status**: manifest-tool made self-contained

**Solution Implemented**: manifest-tool now uses Alpine base instead of depending on curl image.

## Remaining Opportunities (Non-Blocking)

### Issue #3: Multi-Target Builds - Enhancement
**Goal**: Build multiple Kaniko variants (executor, debug, warmer) from single repo clone
**Status**: GitHub Issue #3 OPEN - Infrastructure ready, design needed
**Priority**: Medium (enhancement feature)

**Root Cause**: Manifest stage only depends on build jobs, not prepare stage.

**Fix**:
```yaml
manifest:
  dependencies:
    - prepare      # ADD THIS LINE
    - build_arm64
    - build_amd64
```

### Issue 3: Multi-Target Kaniko Builds - Design Challenge
**Problem**: Kaniko has multiple build targets (executor, debug, etc.) but current directory-based system expects one image per directory.

**Evidence**: Kaniko Makefile has `make images` with multiple targets - need to investigate structure.

**Current Limitation**: kaniko/ directory only builds one variant (debug), but we need all of them.

**Design Options**:
1. **Multiple directories**: kaniko-executor/, kaniko-debug/ (awkward naming)
2. **Enhanced config**: Support `targets: [executor, debug]` array in build-config.yaml
3. **Matrix builds**: Single config generates multiple build jobs
4. **Separate repos**: Different directories for different variants

**Recommended**: Option 2 (enhanced config) - most flexible and maintains clean structure.

### Issue 4: Additional Tags Not Implemented - Feature
**Problem**: `additional_tags` field is parsed but not used.

**Root Cause**: Need `crane` or similar tool to copy/tag images after build.

**Solutions**:
1. Add crane to manifest-tool image (RECOMMENDED)
2. Use Kaniko's multiple `--destination` flags (wasteful)
3. Separate tagging stage

## 🧪 Unit Testing Strategy

### Testable Components (Bottom-Up)

#### 1. Build Config Validation Tests
```bash
# Test build-config.yaml parsing
test_parse_build_config() {
  # Valid configs
  validate_config "curl/build-config.yaml"
  validate_config "kaniko/build-config.yaml"
  
  # Invalid configs
  expect_failure validate_config "invalid/build-config.yaml"
}

# Test architecture filtering
test_architecture_filtering() {
  # Should detect amd64 only
  assert_needs_amd64 "curl/"
  assert_not_needs_arm64 "curl/"
  
  # Should detect both
  assert_needs_amd64 "kaniko/"
  assert_needs_arm64 "kaniko/"
}
```

#### 2. Change Detection Tests
```bash
test_prepare_diff_script() {
  # Test with different git scenarios
  test_merge_request_diff
  test_direct_push_diff
  test_scheduled_build
  
  # Test filtering
  test_readme_only_changes_ignored
  test_build_config_changes_detected
}
```

#### 3. Local Context Build Tests
```bash
test_local_context_builds() {
  # These should work right now
  test_build_curl_amd64
  test_build_manifest_tool_amd64
  
  # Test dependency chaining
  test_manifest_tool_uses_curl_image
}
```

#### 4. ECR Integration Tests
```bash
test_ecr_operations() {
  test_ecr_authentication
  test_image_push
  test_image_pull
  test_manifest_creation
}
```

#### 5. Pipeline Stage Tests
```bash
test_prepare_stage() {
  # Mock git operations
  test_dirs_txt_generation
  test_architecture_flags
}

test_build_stage() {
  # Mock Kaniko operations
  test_tag_generation
  test_dependency_resolution
}

test_manifest_stage() {
  # Mock manifest-tool operations
  test_manifest_yaml_generation
  test_multi_arch_manifest_push
}
```

### E2E Test Composition

#### E2E Test 1: Full Local Context Pipeline
```bash
test_e2e_local_context() {
  # Should work right now
  prepare_stage_with_curl_changes
  build_amd64_curl
  manifest_stage_for_curl
  verify_multi_arch_manifest
}
```

#### E2E Test 2: Multi-Project Build
```bash
test_e2e_multi_project() {
  # Test dependency chaining
  prepare_stage_with_curl_and_manifest_tool_changes
  build_amd64_curl
  build_amd64_manifest_tool  # Should use curl image
  manifest_stage_for_both
}
```

#### E2E Test 3: Architecture Filtering
```bash
test_e2e_architecture_filtering() {
  # Only arm64 needed
  prepare_stage_with_arm64_only_changes
  verify_amd64_build_skipped
  build_arm64_only
}
```

#### E2E Test 4: Remote Repository (BLOCKED)
```bash
test_e2e_remote_repository() {
  # This will fail until Issue 1 is fixed
  prepare_stage_with_kaniko_changes
  expect_failure build_kaniko_remote
}
```

## 🔍 Technical Deep Dive

### GitLab CI Variables Required
```bash
# ECR Configuration
ECR_REGISTRY=<REDACTED>.dkr.ecr.us-east-1.amazonaws.com/redacted/sandbox

# Runner Tags
CICD_TAG=redacted-sandbox          # General purpose (prepare, manifest)
CICD_TAG_AMD64=redacted-sandbox-amd64  # AMD64 builds
CICD_TAG_ARM64=redacted-sandbox-arm64  # ARM64 builds
```

### Image Tagging Convention
```bash
# Default tags (date-based)
{directory}-{YYYYMMDD}-{arch}
# Examples: curl-20251015-amd64, kaniko-20251016-arm64

# Multi-arch manifest (no arch suffix)
{directory}-{YYYYMMDD}
# Example: curl-20251015

# Additional tags (from build-config.yaml)
{directory}-{tag}
# Examples: curl-latest, kaniko-v1.25.3
```

### Dependency Resolution
The pipeline supports image dependencies:
```yaml
# manifest-tool Dockerfile
ARG ECR_REGISTRY
ARG CURL_TAG
FROM ${ECR_REGISTRY}:${CURL_TAG}
```

Pipeline automatically resolves:
1. Checks for `{dependency}-{arch}.tag` files
2. Falls back to `{dependency}-latest` if not found
3. Passes as build args to Kaniko

### ECR Authentication
Uses credential helper approach:
```json
{
  "credsStore": "ecr-login"
}
```

Stored in `/kaniko/.docker/config.json` for builds and `~/.docker/config.json` for manifest stage.

## 🛠️ Development Environment

### Prerequisites
- GitLab instance with CI/CD enabled
- Kubernetes cluster with multi-arch node support
- GitLab runners deployed for amd64/arm64
- ECR registry access configured
- AWS credentials for ECR authentication

### Local Testing
```bash
# Test change detection
./hack/prepare_diff.sh

# Validate build configs
find . -name "build-config.yaml" -exec yq '.' {} \;

# Test Docker builds locally
docker build -t test-curl curl/
docker build -t test-manifest-tool \
  --build-arg ECR_REGISTRY=your-registry \
  --build-arg CURL_TAG=curl-latest \
  manifest-tool/
```

### Debugging Pipeline Issues
1. **Check runner availability**: Ensure both amd64/arm64 runners are online
2. **Verify ECR access**: Test authentication from runners
3. **Examine artifacts**: Check `dirs.txt`, `need_*.txt`, and `*.tag` files
4. **Review logs**: Each stage produces detailed output

## 🎯 Next Steps (Updated Priority Based on Requirements)

### Priority 1: Enable Remote Cloning (CRITICAL - Non-negotiable)
**Goal**: Make remote repository cloning work so we can build Kaniko

**Approach**: Pre-clone in prepare stage, package as artifacts
1. **Modify prepare stage** to clone remote repos using alpine/git
2. **Package cloned repos** as tar.gz artifacts 
3. **Extract in build stage** before Kaniko execution
4. **Test with Kaniko repo** to prove concept

**Time Estimate**: 2-4 hours

### Priority 2: Design Multi-Target Kaniko Builds
**Goal**: Support multiple Kaniko variants (executor, debug, etc.) from single clone

**Research Needed**: Examine Kaniko Makefile and understand build targets
- Check `make images` target structure
- Identify all buildable variants
- Design config structure to avoid directory naming issues

**Options**:
1. **Enhanced build-config.yaml**: Support multiple targets in single directory
2. **Subdirectory approach**: kaniko-executor/, kaniko-debug/, etc.  
3. **Matrix builds**: Single kaniko/ dir with target matrix

**Time Estimate**: 1-2 hours research + implementation

### Priority 3: Build Multi-Arch Kaniko (Self-Hosting Goal)
**Goal**: Replace upstream Kaniko with our own multi-arch builds

**Dependencies**: Priorities 1 & 2 must be complete
1. **Test single-arch Kaniko build** first (amd64 only)
2. **Add arm64 builds** once working
3. **Create multi-arch manifests**
4. **Switch pipeline to use our Kaniko** images

**Time Estimate**: 2-3 hours (assuming priorities 1-2 work)

### Priority 4: Quick Wins (Parallel to above)
**Goal**: Fix obvious issues that don't block main priorities

1. **Fix manifest stage dependency** (5 minutes):
   ```yaml
   manifest:
     dependencies:
       - prepare  # Add this line
   ```

2. **Add comprehensive logging** for debugging

### Priority 5: Polish & Optimization (Later)
**Goal**: Complete the vision once core functionality works

1. **Multi-arch curl image** (currently single-arch amd64)
2. **Additional tags implementation** (add crane to manifest-tool)
3. **Comprehensive testing suite**
4. **Build caching optimization**

## 💡 Key Insights for AI Assistants

### What Works Well
- **Local context builds**: Reliable and fast
- **Architecture detection**: Smart filtering reduces costs
- **Dependency chaining**: Images can build on each other
- **Change detection**: Only builds what changed

### Common Pitfalls
- **Git availability**: Kaniko debug image lacks git
- **Shell quoting**: Build args need careful handling
- **Artifact dependencies**: Stages must depend on right artifacts
- **ECR authentication**: Different approaches for different stages

### Design Patterns
- **Pre-clone approach**: Prepare stage clones remote repos as artifacts
- **Self-contained tools**: No circular dependencies (manifest-tool independent)
- **External dependencies**: Use maintained external tools (martizih/kaniko)
- **Configuration-driven**: Everything controlled by build-config.yaml

### Testing Strategy
- **E2E proven**: spkane/scratch-helloworld validates entire pipeline
- **Real-world validation**: Actual Go HTTP server applications
- **Multi-arch verified**: Both AMD64 and ARM64 working
- **Professional tagging**: Additional tags system operational

## Documentation Status (October 21, 2025)

### Recent Cleanup Completed
- **Cold Storage Protocol**: Implemented retirement system in `attic/cold-storage/`
- **Document Audit**: 15 root directory files categorized and organized
- **Retirement Records**: 5 resolved issue documents properly archived
- **Status Updates**: SPEC.md and AGENTS.md updated to reflect MVP completion

### Current Important Files
When diving deeper into this project, prioritize reading:

1. **ROADMAP.md**: Post-MVP roadmap with 4-phase plan and cleanup strategy
2. **.gitlab-ci.yml**: Complete pipeline implementation (working!)
3. **SPEC.md**: Original requirements (marked MVP complete)
4. **build-config.yaml files**: Understand the configuration format
5. **hack/prepare_diff.sh**: Change detection logic
6. **attic/cold-storage/**: Retired documentation from resolved issues

### 📋 **Active GitHub Issues**
- **Issue #10**: Epic: Transform to hephy-builder with multi-platform CI support (OPEN)
- **Issue #11**: Add Spin (WebAssembly) build backend support (OPEN)
- **Issue #12**: Add Ko build backend for optimized Go application builds (OPEN)
- **Issue #3**: Multi-target build system design (OPEN)
- **Issue #7**: Clean up remaining outdated planning documents (OPEN)
- **Issue #8**: Update Mecris documentation references (CLOSED - Context confusion, moved to correct repository)
- **Issue #2**: Remote repository cloning (CLOSED - RESOLVED)
- **Issue #4**: Additional tags support (CLOSED - RESOLVED)

## Success Metrics

- **Pipeline Success Rate**: Functional for supported features (remote cloning, multi-arch, additional tags) in sandbox environment
- **Build Speed**: ~5-10 minutes for multi-arch builds
- **Resource Efficiency**: Smart architecture filtering reduces costs
- **Maintainability**: Clean architecture, no circular dependencies
- **Documentation Health**: Organized structure with proper archival system

---

## Next Priorities (Post-MVP)

### Phase 1: Stability & Polish (Current)
1. Issue #3: Multi-target build system design
2. Issue #7: Complete documentation cleanup
3. Dependency Graph: Controlled build ordering system

### Phase 2: Advanced Features
1. Real-world adoption: Enterprise application use cases
2. Performance optimization: Build caching, parallel builds
3. Advanced tagging: Version detection, semantic tagging

### Phase 3: Ecosystem & Documentation
1. Missing documentation: ARCHITECTURE.md, DEVELOPMENT.md, TROUBLESHOOTING.md
2. Testing framework: Comprehensive unit and E2E tests
3. Community features: Templates, examples, best practices

**Note**: This system has been validated in sandbox environment with clean documentation and a clear roadmap. The foundation is functional for continued development.
