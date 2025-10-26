# hephy-builder: Manifest Tool Image

Self-contained multi-architecture manifest creation tool - a critical component of the hephy-builder pipeline.

**Role in hephy-builder**: Enables professional multi-arch container distribution, supporting the transition from single-purpose builds to full PaaS resurrection.

## Purpose & Evolution

Originally created to solve circular dependencies in kaniko-builder, now serves as the manifest management component for hephy-builder's multi-backend vision:

1. ✅ **Self-contained** Alpine base (no external dependencies)
2. ✅ **Professional tagging** with built-in crane tool  
3. ✅ **Multi-arch manifests** for automatic architecture selection
4. ✅ **Future-ready** for Ko, Spin, and BuildKit backend integration

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
