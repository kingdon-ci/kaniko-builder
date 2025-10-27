#!/bin/bash
# hephy-builder: Shared Multi-Architecture Build Script
# DRY implementation for both AMD64 and ARM64 builds
# Usage: ./hack/build_images.sh <ARCH> <DIRS> <DATE_TAG>

set -euo pipefail

ARCH="$1"
DIRS="$2"
DATE_TAG="$3"

echo "🏗️  Building for architecture: $ARCH"
echo "📦 Directories to build: $DIRS"

for dir in $DIRS; do
  echo "========================================="
  echo "🔨 Processing $dir"
  echo "========================================="
  
  if [ ! -f "$dir/build-config.yaml" ]; then
    echo "⚠️  No build-config.yaml in $dir, skipping"
    continue
  fi
  
  # Check if this architecture is supported
  if ! grep -A 10 "^platforms:" "$dir/build-config.yaml" | grep -q "linux/$ARCH"; then
    echo "⏭️  Architecture $ARCH not supported for $dir"
    continue
  fi
  
  # Handle remote repository extraction
  USE_LOCAL=$(grep "use_local_context:" "$dir/build-config.yaml" | cut -d':' -f2- | sed 's/#.*//' | tr -d ' ' || echo "false")
  
  if [ "$USE_LOCAL" != "true" ]; then
    # Extract the pre-cloned repository from artifacts
    WORKSPACE="/tmp/workspace-${dir}"
    ARTIFACT_NAME="${dir}-source.tar.gz"
    
    if [ -f "$ARTIFACT_NAME" ]; then
      echo "📦 Extracting $ARTIFACT_NAME to $WORKSPACE"
      mkdir -p "$WORKSPACE"
      tar -xzf "$ARTIFACT_NAME" -C "$WORKSPACE"
      echo "✅ Repository extracted successfully"
      
      # Set the context to the extracted workspace
      BUILD_CONTEXT="$WORKSPACE"
    else
      echo "❌ Pre-cloned artifact $ARTIFACT_NAME not found!"
      echo "Available files:"
      ls -la *.tar.gz || echo "No .tar.gz files found"
      exit 1
    fi
  else
    echo "⏩ $dir uses local context"
    BUILD_CONTEXT="$dir"
  fi
  
  # Detect build backend
  BUILD_BACKEND=$(grep "build_backend:" "$dir/build-config.yaml" | cut -d':' -f2- | sed 's/#.*//' | tr -d ' ' || echo "kaniko")
  echo "🔧 Build backend: $BUILD_BACKEND"
  
  # Generate image tag
  if [ "${GITHUB_REF:-}" = "refs/heads/main" ]; then
    TAG="${dir}-${DATE_TAG}-${ARCH}"
  else
    REF_NAME=$(echo "${GITHUB_REF_NAME:-dev}" | sed 's/[^a-zA-Z0-9.-]/-/g')
    TAG="${dir}-${DATE_TAG}-${REF_NAME}-${ARCH}"
  fi
  
  IMAGE="${IMAGE_BASE:-ghcr.io/kingdon-ci/kaniko-builder}:${TAG}"
  echo "🏷️  Image tag: $IMAGE"
  
  if [ "$BUILD_BACKEND" = "ko" ]; then
    echo "🚀 Building with Ko backend (3x faster, 4x smaller!)"
    
    # Extract Ko configuration
    KO_IMPORT_PATH=$(grep -A 10 "ko_config:" "$dir/build-config.yaml" | grep "import_path:" | cut -d':' -f2- | sed 's/#.*//' | tr -d ' ' || echo "./cmd/server")
    KO_BASE_IMAGE=$(grep -A 10 "ko_config:" "$dir/build-config.yaml" | grep "base_image:" | cut -d':' -f2- | sed 's/#.*//' | tr -d ' ' || echo "cgr.dev/chainguard/static:latest")
    
    # Extract ldflags
    KO_LDFLAGS=$(grep -A 15 "ko_config:" "$dir/build-config.yaml" | grep -A 10 "ldflags:" | grep "^[[:space:]]*-" | sed 's/^[[:space:]]*-[[:space:]]*//' | tr '\n' ' ' | sed 's/[[:space:]]*$//' || echo "")
    
    echo "  📁 Import path: $KO_IMPORT_PATH"
    echo "  🐳 Base image: $KO_BASE_IMAGE"
    echo "  🔗 Ldflags: $KO_LDFLAGS"
    
    # Set Ko environment
    export KO_DOCKER_REPO="${IMAGE_BASE:-ghcr.io/kingdon-ci/kaniko-builder}"
    export KO_DEFAULTBASEIMAGE="$KO_BASE_IMAGE"
    
    if [ -n "$KO_LDFLAGS" ]; then
      export LDFLAGS="$KO_LDFLAGS"
    fi
    
    # Build with Ko using the correct context
    cd "$BUILD_CONTEXT"
    ko build "$KO_IMPORT_PATH" \
      --platform="linux/$ARCH" \
      --tags="$TAG"
    
    echo "✅ Ko build completed for $dir-$ARCH"
    
  else
    echo "🔨 Building with Kaniko backend"
    
    # Extract Kaniko configuration  
    DOCKERFILE_PATH=$(grep "dockerfile_path:" "$dir/build-config.yaml" | cut -d':' -f2- | sed 's/#.*//' | tr -d ' ' || echo "Dockerfile")
    CONTEXT_PATH=$(grep "context_path:" "$dir/build-config.yaml" | cut -d':' -f2- | sed 's/#.*//' | tr -d ' ' || echo ".")
    
    echo "  📄 Dockerfile: $DOCKERFILE_PATH"
    echo "  📁 Context: $CONTEXT_PATH"
    
    # Build with Docker Buildx using the correct context
    docker buildx build \
      --platform="linux/$ARCH" \
      --file="$BUILD_CONTEXT/$DOCKERFILE_PATH" \
      --tag="$IMAGE" \
      --push \
      "$BUILD_CONTEXT/$CONTEXT_PATH"
    
    echo "✅ Kaniko-equivalent build completed for $dir-$ARCH"
  fi
  
  # Save image tag for manifest stage
  echo "$TAG" > "${dir}-${ARCH}.tag"
  
done