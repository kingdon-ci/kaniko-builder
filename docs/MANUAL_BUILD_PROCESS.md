# Manual Build Process for BuildKit-Incompatible Images

**Purpose**: This document provides step-by-step instructions for manually building images that require BuildKit features incompatible with Kaniko (like Kaniko itself).

**When to Use**: When images use `RUN --mount=from=`, `RUN --mount=type=cache`, or other advanced BuildKit syntax.

## Prerequisites

### Local Development Environment
```bash
# Install Docker with BuildKit support
docker version --format '{{.Server.Version}}'  # Should be 18.09+

# Enable BuildKit
export DOCKER_BUILDKIT=1
# OR in daemon.json: {"features": {"buildkit": true}}

# Install crane for image operations
GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
go install github.com/google/go-containerregistry/cmd/crane@latest
```

### AWS ECR Access
```bash
# Configure AWS CLI
aws configure

# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <ECR-REGISTRY>
```

## Manual Build Process

### Step 1: Clone Source Repository
```bash
# Clone the upstream repo
git clone https://github.com/chainguard-dev/kaniko.git
cd kaniko
git checkout v1.25.3

# Verify Dockerfile uses BuildKit features
grep -n "RUN --mount" deploy/Dockerfile
```

### Step 2: Build Multi-Architecture Images
```bash
# Set variables
export ECR_REGISTRY="<ECR-REGISTRY>"
export IMAGE_NAME="kaniko/executor"
export VERSION="v1.25.3"
export TARGET="kaniko-debug"

# Build for AMD64
docker buildx build \
  --platform linux/amd64 \
  --target $TARGET \
  --tag $ECR_REGISTRY/$IMAGE_NAME:$VERSION-debug-amd64 \
  --file deploy/Dockerfile \
  --push \
  .

# Build for ARM64  
docker buildx build \
  --platform linux/arm64 \
  --target $TARGET \
  --tag $ECR_REGISTRY/$IMAGE_NAME:$VERSION-debug-arm64 \
  --file deploy/Dockerfile \
  --push \
  .
```

### Step 3: Update Pipeline Configuration
```yaml
# In kaniko/build-config.yaml
manual_build: true
manual_images:
  amd64: "<ECR-REGISTRY>/kaniko/executor:v1.25.3-debug-amd64"
  arm64: "<ECR-REGISTRY>/kaniko/executor:v1.25.3-debug-arm64"
```

### Step 4: Run Pipeline for Manifest Creation
```bash
# The pipeline will:
# 1. Skip Kaniko build (manual_build: true)
# 2. Use manual_images tags for manifest creation
# 3. Create multi-arch manifest: kaniko/executor:v1.25.3-debug

# Trigger pipeline (or wait for automatic trigger)
git add kaniko/build-config.yaml
git commit -m "Enable manual build mode for Kaniko"
git push origin main
```

## Verification

### Check Manual Images
```bash
# Verify individual architecture images exist
crane manifest $ECR_REGISTRY/kaniko/executor:v1.25.3-debug-amd64
crane manifest $ECR_REGISTRY/kaniko/executor:v1.25.3-debug-arm64

# Check image architecture
crane config $ECR_REGISTRY/kaniko/executor:v1.25.3-debug-amd64 | jq .architecture
crane config $ECR_REGISTRY/kaniko/executor:v1.25.3-debug-arm64 | jq .architecture
```

### Check Multi-Arch Manifest
```bash
# After pipeline runs, verify multi-arch manifest
crane manifest $ECR_REGISTRY/kaniko/executor:v1.25.3-debug | jq .

# Should show manifests for both amd64 and arm64
```

### Test with Docker
```bash
# Test image selection works automatically
docker run --rm $ECR_REGISTRY/kaniko/executor:v1.25.3-debug --version

# Force specific architecture
docker run --rm --platform linux/amd64 $ECR_REGISTRY/kaniko/executor:v1.25.3-debug --version
docker run --rm --platform linux/arm64 $ECR_REGISTRY/kaniko/executor:v1.25.3-debug --version
```

## Local Manifest Creation (Alternative)

If you prefer to create manifests locally instead of using the pipeline:

```bash
# Create manifest locally using manifest-tool
echo "image: $ECR_REGISTRY/kaniko/executor:v1.25.3-debug
manifests:
  - image: $ECR_REGISTRY/kaniko/executor:v1.25.3-debug-amd64
    platform:
      architecture: amd64
      os: linux
  - image: $ECR_REGISTRY/kaniko/executor:v1.25.3-debug-arm64
    platform:
      architecture: arm64
      os: linux" > manifest.yaml

# Push manifest
docker run --rm -v $(pwd)/manifest.yaml:/manifest.yaml \
  -v ~/.docker:/root/.docker \
  $ECR_REGISTRY/manifest-tool:latest \
  push from-spec /manifest.yaml
```

## Integration with Pipeline

### For Future BuildKit Images
1. **Identify BuildKit usage**: Look for `RUN --mount=` in Dockerfiles
2. **Enable manual mode**: Set `manual_build: true` in build-config.yaml
3. **Build manually**: Use this process to create arch-specific images
4. **Update config**: Point `manual_images` to your builds
5. **Run pipeline**: Let automation handle manifest creation

### Migration Path
```yaml
# Example: Gradually move images to BuildKit
example-app/build-config.yaml:
  # Phase 1: Kaniko build (current)
  use_local_context: true
  
  # Phase 2: Manual BuildKit build (when needed)
  manual_build: true
  manual_images:
    amd64: "<ECR-REGISTRY>/example-app:latest-amd64"
    arm64: "<ECR-REGISTRY>/example-app:latest-arm64"
```

## Troubleshooting

### BuildKit Not Available
```bash
# Check BuildKit support
docker buildx version

# Enable BuildKit experimentally
docker buildx create --use --name multiarch --platform linux/amd64,linux/arm64
```

### ECR Push Failures
```bash
# Refresh ECR token
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <ECR-REGISTRY>

# Check repository exists
aws ecr describe-repositories --repository-names kaniko/executor
```

### Manifest Creation Issues
```bash
# Debug manifest-tool
docker run --rm -v ~/.docker:/root/.docker \
  $ECR_REGISTRY/manifest-tool:latest \
  inspect $ECR_REGISTRY/kaniko/executor:v1.25.3-debug-amd64
```

## Future Enhancements

1. **Dev Container Integration**: Pre-configured environment with all tools
2. **Automated Local Scripts**: Shell scripts for common build patterns  
3. **CI/CD for Manual Builds**: GitHub Actions for manual image builds
4. **BuildKit Migration**: Evaluate migrating entire pipeline to BuildKit

---

**Note**: This hybrid approach allows us to leverage Kaniko for simple images while using BuildKit for complex ones, providing the best of both worlds.