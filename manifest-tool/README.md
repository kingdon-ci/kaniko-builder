# Manifest Tool Image

This directory builds a self-contained manifest-tool image based on Alpine Linux.

## Purpose

The manifest-tool image is used in the GitLab CI pipeline to create multi-architecture container manifests. It's now completely self-contained to avoid circular dependencies:

1. ✅ Self-contained Alpine base (no external image dependencies)
2. ✅ Built-in curl and ECR credential helper
3. ✅ manifest-tool binary for creating multi-arch manifests
4. ✅ **crane tool for additional tags support** (Oct 16, 2025)
5. ✅ Resolves circular dependency issue (Oct 16, 2025)

## Build Configuration

- **Base Image**: alpine:latest (no dependencies on our images)  
- **Architecture**: amd64 only (the tool itself doesn't need multi-arch)
- **Local Build**: Uses `use_local_context: true` to build from this directory instead of cloning from remote

## Usage in Pipeline

The manifest stage uses this image to merge architecture-specific images into multi-arch manifests:

```yaml
manifest:
  stage: manifest
  image: 
    name: $ECR_REGISTRY:manifest-tool-latest
    entrypoint: [""]
```

## Manifest Tool

This image includes [manifest-tool](https://github.com/estesp/manifest-tool) v2.1.6, which is used to create and push multi-architecture container manifests.
