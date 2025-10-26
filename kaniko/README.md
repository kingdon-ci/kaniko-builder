# hephy-builder: Kaniko Build Configuration

**Status**: Disabled - Using maintained external Kaniko for hephy-builder foundation

## Strategic Decision

Instead of building our own Kaniko, hephy-builder uses the maintained `martizih/kaniko:v1.26.0-debug` image:
- **Zero maintenance overhead** for core build tooling
- **Community maintained** with regular updates
- **Battle-tested** reliability for production workloads

## Configuration (Disabled)

The `disabled-build-config.yaml` preserves the original configuration for future reference:
- **Upstream**: https://github.com/chainguard-dev/kaniko  
- **Target**: debug variant for enhanced logging
- **Architectures**: amd64 and arm64 support

## hephy-builder Context

This represents the foundation backend (Kaniko) in the multi-backend hephy-builder vision. Future backends (Ko, Spin, BuildKit) will build on this solid foundation.

## Output Images

The pipeline will create:
- `kaniko-YYYYMMDD-{commit-sha}` (date-based tag)
- `kaniko-v1.25.3` (version tag)
- `kaniko-latest` (latest tag)

All images will be multi-architecture manifests supporting both amd64 and arm64.
