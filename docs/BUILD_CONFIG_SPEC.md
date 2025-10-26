# BUILD_CONFIG_SPEC.md - Formal Specification for build-config.yaml

**Status**: Specification Document  
**Version**: 1.0 (Current Implementation)  
**Purpose**: Define the exact structure and behavior of build-config.yaml files

## 📋 **File Purpose**

Each buildable directory in hephy-builder contains a `build-config.yaml` file that defines:
- **Build source**: Local context or remote repository
- **Build target**: Dockerfile location and build context
- **Output configuration**: Multi-architecture targets and image tags

## 🏗️ **Current Schema (v1.0)**

### **Local Context Build**
```yaml
# Required for local builds
use_local_context: true
dockerfile_path: Dockerfile        # Path to Dockerfile (required)
context_path: .                    # Build context path (optional, default: .)

# Multi-architecture configuration
platforms:                         # Array of target platforms (required)
  - linux/amd64
  - linux/arm64

# Tagging configuration  
additional_tags:                    # Array of additional image tags (optional)
  - latest
  - v1.0.0

# Build arguments (optional)
build_args: []                      # Array of build arguments (optional)
```

### **Remote Repository Build**
```yaml
# Required for remote builds
upstream_repo: https://github.com/owner/repo  # Git repository URL (required)
upstream_ref: main                            # Git reference: branch, tag, or commit (required)
dockerfile_path: Dockerfile                   # Path to Dockerfile in repo (required)
context_path: .                              # Build context within repo (optional, default: .)

# Multi-architecture configuration (same as local)
platforms:
  - linux/amd64
  - linux/arm64

# Tagging configuration (same as local)
additional_tags:
  - latest
  - pipeline-test

# Build arguments (optional)
build_args: []
```

## 🔧 **Field Specifications**

### **Required Fields**

#### **Build Source** (Mutually Exclusive)
- **`use_local_context: true`**: Use files in the current directory
- **`upstream_repo` + `upstream_ref`**: Clone from remote Git repository

#### **Build Configuration**
- **`dockerfile_path`**: Path to Dockerfile (relative to context_path)
  - Type: `string`
  - Example: `Dockerfile`, `deploy/Dockerfile`, `build/Containerfile`
- **`platforms`**: Target architectures for multi-arch builds
  - Type: `array[string]`
  - Valid values: `linux/amd64`, `linux/arm64`, `linux/arm/v7`, etc.
  - Example: `["linux/amd64", "linux/arm64"]`

### **Optional Fields**

#### **Context Configuration**
- **`context_path`**: Build context directory
  - Type: `string`
  - Default: `.`
  - Example: `.`, `src/`, `apps/backend/`

#### **Tagging Configuration**
- **`additional_tags`**: Extra tags beyond the default date-based tag
  - Type: `array[string]`
  - Default: `[]`
  - Example: `["latest", "v1.0.0", "stable"]`

#### **Build Arguments**
- **`build_args`**: Arguments passed to Docker/Kaniko build
  - Type: `array[string]`
  - Default: `[]`
  - Example: `["VERSION=1.0.0", "BUILD_ENV=production"]`

## 🎯 **Target Architecture Specification**

### **Supported Platforms**
- **`linux/amd64`**: Intel/AMD 64-bit (most common)
- **`linux/arm64`**: ARM 64-bit (Apple Silicon, AWS Graviton)
- **`linux/arm/v7`**: ARM 32-bit v7 (Raspberry Pi, etc.)

### **Platform Selection Logic**
1. **Pipeline detects required architectures** from all changed directories
2. **Builds run only on matching runners** (amd64 runner, arm64 runner)
3. **Manifest stage combines** all architectures into multi-arch manifests

## 📁 **Working Examples**

### **Example 1: Local Simple Build**
```yaml
# curl/build-config.yaml
use_local_context: true
dockerfile_path: Dockerfile
platforms:
  - linux/amd64
additional_tags:
  - latest
```

### **Example 2: Remote Repository Build**
```yaml
# test-app/build-config.yaml  
upstream_repo: https://github.com/spkane/scratch-helloworld
upstream_ref: main
dockerfile_path: Dockerfile
platforms:
  - linux/amd64
  - linux/arm64
additional_tags:
  - latest
  - pipeline-test
```

### **Example 3: Complex Multi-Stage Build**
```yaml
# manifest-tool/build-config.yaml
use_local_context: true
dockerfile_path: Dockerfile
context_path: .
platforms:
  - linux/amd64
  - linux/arm64
build_args:
  - ECR_REGISTRY=${ECR_REGISTRY}
  - CURL_TAG=${CURL_TAG}
additional_tags:
  - latest
```

## 🔄 **Future Enhancements (Proposed)**

### **Backend Selection** (Issue #12)
```yaml
# PROPOSED: Multi-backend support
build_backend: ko                    # kaniko|buildkit|ko|spin
ko_config:                          # Backend-specific configuration
  import_path: ./cmd/server
  base_image: distroless.dev/static-debian12
```

### **Platform-Agnostic Variables** (Issue #10)
```yaml
# PROPOSED: Cross-platform variable support
additional_tags:
  - latest
  - ${BRANCH_NAME}                   # Works on both GitHub/GitLab
  - ${BUILD_NUMBER}                  # Platform abstraction
```

## ⚡ **Pipeline Integration**

### **Discovery Process**
1. **`hack/prepare_diff.sh`** scans for directories with `build-config.yaml`
2. **Validates configuration** and determines required architectures
3. **Generates build matrix** for parallel execution

### **Tag Generation**
```bash
# Default tag format
{directory}-{YYYYMMDD}-{arch}
# Example: curl-20251024-amd64

# Multi-arch manifest (no arch suffix)  
{directory}-{YYYYMMDD}
# Example: curl-20251024

# Additional tags (from config)
{directory}-{additional_tag}
# Example: curl-latest
```

## 🐛 **Validation Rules**

### **Required Validations**
- **Mutual exclusion**: Cannot have both `use_local_context: true` AND `upstream_repo`
- **Required fields**: Must have either local context OR remote repo configuration
- **Platform validation**: All platforms must be valid Docker platform strings
- **Path validation**: `dockerfile_path` must exist (for local builds)

### **Warning Conditions**
- **No additional_tags**: Results in date-only tags
- **Single platform**: Missing multi-arch benefits
- **Empty build_args**: May indicate missing configuration

## 🔍 **Implementation Notes**

### **Current Pipeline Logic**
```bash
# In .gitlab-ci.yml build stage
if [ -f "build-config.yaml" ]; then
  USE_LOCAL_CONTEXT=$(yq '.use_local_context // false' build-config.yaml)
  UPSTREAM_REPO=$(yq '.upstream_repo // ""' build-config.yaml)
  # ... configuration parsing logic
fi
```

### **Dependency Resolution**
Pipeline automatically resolves image dependencies:
```bash
# manifest-tool depends on curl
CURL_TAG=$(cat curl-${ARCH}.tag 2>/dev/null || echo "curl-latest")
```

**File Location**: Each buildable directory contains its own `build-config.yaml`  
**Validation**: Performed during `prepare` stage  
**Documentation**: See working examples in `curl/`, `manifest-tool/`, `test-app/` directories