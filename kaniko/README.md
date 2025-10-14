# Kaniko Build Configuration

This directory contains the build configuration for building Kaniko itself using Kaniko.

## Configuration

The `build-config.yaml` file specifies:
- **Upstream**: https://github.com/chainguard-dev/kaniko
- **Version**: v1.25.3
- **Target**: debug (builds the debug variant of Kaniko)
- **Architectures**: amd64 and arm64

## Why Build Kaniko?

The upstream Kaniko project no longer publishes arm64 builds, but we need multi-architecture support for our build pipeline. This configuration allows us to build our own Kaniko images with both amd64 and arm64 support.

## Output Images

The pipeline will create:
- `kaniko-YYYYMMDD-{commit-sha}` (date-based tag)
- `kaniko-v1.25.3` (version tag)
- `kaniko-latest` (latest tag)

All images will be multi-architecture manifests supporting both amd64 and arm64.
