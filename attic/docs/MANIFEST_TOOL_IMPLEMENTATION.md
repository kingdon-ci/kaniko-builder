# Manifest Tool Implementation

## Overview

This document describes the implementation of a custom manifest-tool image and the pipeline modifications to support single-architecture builds, local context builds, and build dependency chaining.

## Problem Statement

The initial implementation attempted to use `gcr.io/go-containerregistry/gcrane:debug` for creating multi-architecture manifests, but this was based on incorrect assumptions. The actual Kaniko documentation does not recommend gcrane for this purpose.

Additionally, the `mplatform/manifest-tool` image does not include a shell (`sh`), causing GitLab CI to fail with:
```
OCI runtime create failed: runc create failed: unable to start container process: 
error during container init: exec: "sh": executable file not found in $PATH
```

## Solution

We implemented a custom manifest-tool image based on our curl image, following the approach described in the ArborXR blog post: [Building Unprivileged Multi-Arch Images with Kaniko and GitLab CI](https://arborxr.com/blog/developers-journal-building-unprivileged-multi-arch-images-with-kaniko-and-gitlab-ci).

### Key Components

#### 1. Custom manifest-tool Image

**Location**: `manifest-tool/`

**Files**:
- `Dockerfile` - Builds on curl image, installs manifest-tool binary
- `build-config.yaml` - Configures local context build
- `README.md` - Documentation

**Dockerfile**:
```dockerfile
ARG ECR_REGISTRY
ARG CURL_TAG
FROM ${ECR_REGISTRY}:${CURL_TAG}

# Install manifest-tool from GitHub releases
RUN apk add --no-cache wget ca-certificates && \
    wget -O /usr/local/bin/manifest-tool \
    https://github.com/estesp/manifest-tool/releases/download/v2.1.6/binaries-manifest-tool-2.1.6/manifest-tool-linux-amd64 && \
    chmod +x /usr/local/bin/manifest-tool && \
    apk del wget

RUN mkdir -p /root/.docker
ENTRYPOINT ["/bin/sh"]
```

**Key Features**:
- Based on Alpine Linux (via curl image) - provides shell support
- Includes manifest-tool v2.1.6 binary
- Configured for ECR authentication
- Shell entrypoint for GitLab CI compatibility

#### 2. Local Context Builds

**New Field**: `use_local_context: true` in `build-config.yaml`

When set, the pipeline:
- Uses `$CI_PROJECT_DIR/$dir` as the workspace instead of cloning
- Skips git operations
- Uses simpler tagging (no commit SHA)

**Example** (`manifest-tool/build-config.yaml`):
```yaml
use_local_context: true
dockerfile_path: Dockerfile
context_path: .
platforms:
  - linux/amd64
```

#### 3. Single-Architecture Builds

**Implementation**: Platform filtering in pipeline

The pipeline now checks if each architecture is in the `platforms` list:
```bash
PLATFORMS=$(grep -A 10 "^platforms:" "$dir/build-config.yaml" | grep "linux/${ARCH}" || echo "")
if [ -z "$PLATFORMS" ]; then
  echo "Architecture ${ARCH} not in platforms list for $dir. Skipping."
  continue
fi
```

**Example** (`curl/build-config.yaml`):
```yaml
platforms:
  - linux/amd64  # Only build amd64
```

**Behavior**:
- arm64 build job skips curl (not in platforms list)
- amd64 build job builds curl
- manifest stage skips curl (no arm64 tag file exists)

#### 4. Build Dependency Chain

**Implementation**: Alphabetic ordering + build arg passing

The pipeline detects dependencies and passes required build args:
```bash
if [ "$dir" = "manifest-tool" ]; then
  if [ -f "curl-${ARCH}.tag" ]; then
    CURL_TAG=$(cat "curl-${ARCH}.tag")
    BUILD_ARGS="--build-arg ECR_REGISTRY=$ECR_REGISTRY --build-arg CURL_TAG=$CURL_TAG"
  fi
fi
```

**Dependency Chain**:
1. curl builds first (alphabetically before manifest-tool)
2. curl creates `curl-amd64.tag` artifact
3. manifest-tool reads tag file
4. manifest-tool passes ECR_REGISTRY and CURL_TAG as build args
5. Dockerfile uses these to pull curl as base image

#### 5. Manifest Creation

**Implementation**: manifest-tool YAML spec

The manifest stage creates a YAML specification and uses manifest-tool to push:
```bash
echo "image: $ECR_REGISTRY:$BASE_TAG" > /tmp/manifest-${dir}.yaml
echo "manifests:" >> /tmp/manifest-${dir}.yaml
echo "  - image: $ECR_REGISTRY:$AMD64_TAG" >> /tmp/manifest-${dir}.yaml
echo "    platform:" >> /tmp/manifest-${dir}.yaml
echo "      architecture: amd64" >> /tmp/manifest-${dir}.yaml
echo "      os: linux" >> /tmp/manifest-${dir}.yaml
# ... (arm64 section)

manifest-tool push from-spec /tmp/manifest-${dir}.yaml
```

**Note**: We use line-by-line echo instead of heredoc to avoid YAML parsing issues in GitLab CI.

## Pipeline Flow

### Single-Arch Build (curl)
1. **prepare**: Detects curl directory changed
2. **build_amd64**: Builds curl for amd64, creates `curl-amd64.tag`
3. **build_arm64**: Skips curl (not in platforms list)
4. **manifest**: Skips curl (no arm64 tag file)

### Local Context Build (manifest-tool)
1. **prepare**: Detects manifest-tool directory changed
2. **build_amd64**: 
   - Reads `curl-amd64.tag`
   - Passes ECR_REGISTRY and CURL_TAG as build args
   - Builds from local directory
   - Creates `manifest-tool-amd64.tag`
3. **build_arm64**: Skips (not in platforms list)
4. **manifest**: Skips (no arm64 tag file)

### Multi-Arch Build (future - kaniko)
1. **prepare**: Detects kaniko directory changed
2. **build_amd64**: Builds kaniko for amd64, creates `kaniko-amd64.tag`
3. **build_arm64**: Builds kaniko for arm64, creates `kaniko-arm64.tag`
4. **manifest**: Creates multi-arch manifest using manifest-tool image

## Testing Strategy

### Phase 1: Single-Arch Validation
- Test curl builds successfully (amd64 only)
- Verify curl image pushed to ECR
- Confirm arm64 job skips curl

### Phase 2: Dependency Chain Validation
- Test manifest-tool builds successfully
- Verify it uses curl as base image
- Confirm manifest-tool image pushed to ECR

### Phase 3: Multi-Arch Validation (Future)
- Enable arm64 for curl
- Test both architectures build
- Verify manifest creation works
- Test multi-arch pull behavior

## References

- **Primary Source**: [ArborXR - Building Unprivileged Multi-Arch Images with Kaniko and GitLab CI](https://arborxr.com/blog/developers-journal-building-unprivileged-multi-arch-images-with-kaniko-and-gitlab-ci)
- **manifest-tool**: [estesp/manifest-tool on GitHub](https://github.com/estesp/manifest-tool)
- **Kaniko**: [chainguard-dev/kaniko on GitHub](https://github.com/chainguard-dev/kaniko)

## Future Enhancements

1. **Additional Tags**: Parse `additional_tags` from build-config.yaml using yq
2. **Dependency Declaration**: Add explicit `depends_on` field instead of relying on alphabetic order
3. **Caching**: Implement build caching for faster iterations
4. **Parallel Builds**: Build independent projects in parallel
5. **Conditional Architecture Jobs**: Skip architecture-specific build jobs when not needed
   - **Problem**: Currently, both amd64 and arm64 jobs always run, even if a directory only needs one architecture
   - **Impact**: Wastes runner resources and time waiting for runners we don't need
   - **Example**: curl with `platforms: [linux/amd64]` still triggers arm64 job, which then skips the build
   - **Solution**: Add a dynamic job generation stage that:
     - Reads all `build-config.yaml` files in `dirs.txt`
     - Determines which architectures are actually needed
     - Only creates build jobs for required architectures
     - Could use GitLab's `rules:` with variables or dynamic child pipelines
   - **Priority**: Low (pipeline is designed for multi-arch builds, so single-arch is edge case)
   - **Complexity**: Medium-High (requires significant pipeline restructuring)

## Troubleshooting

### Issue: "git: not found"
**Solution**: Install git in Kaniko debug image via `before_script`:
```yaml
before_script:
  - apk add --no-cache git
```

### Issue: "sh: executable file not found"
**Solution**: Use custom image with shell support (our manifest-tool image)

### Issue: YAML parsing errors with heredoc
**Solution**: Use line-by-line echo instead of heredoc in GitLab CI scripts

### Issue: Workspace collision between projects
**Solution**: Use unique workspace per directory: `/workspace-${dir}`
