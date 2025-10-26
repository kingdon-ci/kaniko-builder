# hephy-builder: Curl Build Configuration

Bootstrap utility image that demonstrates hephy-builder's multi-architecture capabilities.

**Role in hephy-builder**: Foundation component used by manifest-tool and other builds, showcasing dependency chaining in the hephy-builder ecosystem.

## Configuration

The `build-config.yaml` file specifies:
- **Local context build**: Uses curlimages/curl base image
- **Architectures**: amd64 and arm64 support
- **Purpose**: Bootstrap utility for hephy-builder pipeline components

## Heritage & Purpose

Originally created as the second example project for kaniko-builder generalization, now serves as a key bootstrap component in the hephy-builder vision.

## Output Images

The pipeline will create:
- `curl-YYYYMMDD-{commit-sha}` (date-based tag)
- `curl-latest` (latest tag)
- `curl-test` (test tag)

All images will be multi-architecture manifests supporting both amd64 and arm64.
