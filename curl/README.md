# Curl Build Configuration

This directory contains the build configuration for building the curl utility image.

## Configuration

The `build-config.yaml` file specifies:
- **Upstream**: https://github.com/curlimages/curl
- **Version**: master (latest)
- **Architectures**: amd64 and arm64

## Why Build Curl?

This serves as a second example project to demonstrate the generalizability of our kaniko-builder framework. The curl image is a lightweight utility that's commonly used in containerized environments.

## Output Images

The pipeline will create:
- `curl-YYYYMMDD-{commit-sha}` (date-based tag)
- `curl-latest` (latest tag)
- `curl-test` (test tag)

All images will be multi-architecture manifests supporting both amd64 and arm64.
