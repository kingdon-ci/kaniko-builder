# Bootstrap Process Documentation

## The Dependency Problem

We have a circular dependency issue:
1. We need `manifest-tool` to create multi-arch manifests
2. `manifest-tool` needs to be built with Kaniko
3. Kaniko's debug image doesn't have `apk` or `git` installed
4. We can't install packages in the Kaniko debug image at runtime
5. We need to build from local context, but that requires having images already built

## Bootstrap Solution

We solve this by using a **two-phase bootstrap process**:

### Phase 1: Bootstrap with Well-Known Images (Current)

#### Step 1: Build curl from well-known image
- **Location**: `curl/`
- **Strategy**: Use `use_local_context: true` with a simple Dockerfile
- **Base Image**: `curlimages/curl:latest` (public, well-known, Alpine-based)
- **Purpose**: Create our own curl image in ECR that we control

**curl/Dockerfile**:
```dockerfile
FROM curlimages/curl:latest
USER root
RUN apk add --no-cache ca-certificates
USER curl_user
```

**curl/build-config.yaml**:
```yaml
use_local_context: true
dockerfile_path: Dockerfile
platforms:
  - linux/amd64  # Single-arch for bootstrap
```

#### Step 2: Build manifest-tool on top of curl
- **Location**: `manifest-tool/`
- **Strategy**: Use `use_local_context: true`, depends on curl
- **Base Image**: Our curl image from Step 1
- **Purpose**: Create manifest-tool image for creating multi-arch manifests

**manifest-tool/Dockerfile**:
```dockerfile
ARG ECR_REGISTRY
ARG CURL_TAG
FROM ${ECR_REGISTRY}:${CURL_TAG}

RUN apk add --no-cache wget ca-certificates && \
    wget -O /usr/local/bin/manifest-tool \
    https://github.com/estesp/manifest-tool/releases/download/v2.1.6/binaries-manifest-tool-2.1.6/manifest-tool-linux-amd64 && \
    chmod +x /usr/local/bin/manifest-tool && \
    apk del wget

RUN mkdir -p /root/.docker
ENTRYPOINT ["/bin/sh"]
```

**manifest-tool/build-config.yaml**:
```yaml
use_local_context: true
dockerfile_path: Dockerfile
platforms:
  - linux/amd64  # Single-arch for bootstrap
```

#### Step 3: Verify manifest-tool works
- Test that manifest-tool can create multi-arch manifests
- Verify ECR authentication works
- Confirm the tool is functional

### Phase 2: Switch to Proper Builds (Future)

Once we have a working manifest-tool image:

#### Step 1: Enable multi-arch for curl
**curl/build-config.yaml**:
```yaml
use_local_context: false  # Switch to remote
upstream_repo: https://github.com/curlimages/curl
upstream_ref: master
dockerfile_path: Dockerfile
platforms:
  - linux/amd64
  - linux/arm64  # Add arm64
```

#### Step 2: Build curl multi-arch
- Pipeline builds curl for both architectures
- manifest-tool creates multi-arch manifest
- Now we have a proper multi-arch curl image

#### Step 3: Update manifest-tool to use multi-arch curl
**manifest-tool/build-config.yaml**:
```yaml
platforms:
  - linux/amd64
  - linux/arm64  # Add arm64
```

#### Step 4: Build manifest-tool multi-arch
- Pipeline builds manifest-tool for both architectures
- Uses the multi-arch curl image as base
- Creates multi-arch manifest-tool image

### Phase 3: Add Kaniko (Final Goal)

Once we have working multi-arch infrastructure:

#### Add kaniko directory
**kaniko/build-config.yaml**:
```yaml
upstream_repo: https://github.com/chainguard-dev/kaniko
upstream_ref: v1.25.3
dockerfile_path: deploy/Dockerfile
target: debug
platforms:
  - linux/amd64
  - linux/arm64
```

#### Build Kaniko
- Pipeline clones Kaniko repo
- Builds for both architectures
- Creates multi-arch manifest
- Now we have our own Kaniko builds!

## Key Constraints

### Why We Can't Install Git in Kaniko Debug Image
The Kaniko debug image is minimal and doesn't include package managers:
- Not Alpine-based (no `apk`)
- Not Debian-based (no `apt`)
- Not Red Hat-based (no `yum`/`dnf`)
- Designed to be minimal for security

### Why We Need Local Context Initially
Without git, we can't clone repositories. Therefore:
- All initial builds must use `use_local_context: true`
- Dockerfiles must be in the repo
- We bootstrap from public images we can pull

### Why Alphabetic Order Matters
The pipeline processes directories in alphabetical order:
- `curl` builds before `manifest-tool` ✅
- `manifest-tool` can use curl's tag file ✅
- If order was reversed, manifest-tool would fail ❌

## Build Order Dependencies

```
Phase 1 (Bootstrap):
  curl (local, amd64) → manifest-tool (local, amd64)

Phase 2 (Proper):
  curl (remote, multi-arch) → manifest-tool (multi-arch)

Phase 3 (Final):
  curl (remote, multi-arch) → manifest-tool (multi-arch) → kaniko (remote, multi-arch)
```

## Testing Each Phase

### Phase 1 Testing
```bash
# Commit curl and manifest-tool with use_local_context: true
git add curl/ manifest-tool/
git commit -m "Bootstrap: Add curl and manifest-tool with local context"
git push

# Verify:
# - curl builds successfully (amd64)
# - manifest-tool builds successfully (amd64)
# - Both images pushed to ECR
# - manifest-tool image has working shell and manifest-tool binary
```

### Phase 2 Testing
```bash
# Update curl to use remote repo and multi-arch
# Commit and push
git add curl/build-config.yaml
git commit -m "Switch curl to remote repo with multi-arch"
git push

# Verify:
# - curl builds for both amd64 and arm64
# - Multi-arch manifest created
# - Can pull curl image and get correct arch automatically
```

### Phase 3 Testing
```bash
# Add kaniko directory
git add kaniko/
git commit -m "Add Kaniko multi-arch build"
git push

# Verify:
# - Kaniko builds for both architectures
# - Multi-arch manifest created
# - Can use our Kaniko image in the pipeline itself (dogfooding!)
```

## Troubleshooting

### Issue: "apk: not found"
**Cause**: Trying to install packages in Kaniko debug image  
**Solution**: Use local context builds, don't try to install packages

### Issue: "git: not found"
**Cause**: Trying to clone repos without git  
**Solution**: Use `use_local_context: true` for bootstrap

### Issue: manifest-tool can't find curl tag
**Cause**: curl hasn't built yet (wrong order)  
**Solution**: Ensure curl is alphabetically before manifest-tool

### Issue: Dockerfile can't pull base image
**Cause**: Base image doesn't exist in ECR yet  
**Solution**: Build dependencies first (curl before manifest-tool)

## Success Criteria

### Phase 1 Complete When:
- ✅ curl image exists in ECR (amd64)
- ✅ manifest-tool image exists in ECR (amd64)
- ✅ manifest-tool can create multi-arch manifests
- ✅ No git or package installation required

### Phase 2 Complete When:
- ✅ curl is multi-arch (amd64 + arm64)
- ✅ manifest-tool is multi-arch (amd64 + arm64)
- ✅ Both have proper manifests
- ✅ Auto-pull selects correct architecture

### Phase 3 Complete When:
- ✅ Kaniko is multi-arch (amd64 + arm64)
- ✅ Can use our own Kaniko in the pipeline
- ✅ No longer dependent on upstream Kaniko images
- ✅ Full control over Kaniko version and features
