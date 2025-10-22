# Kaniko Builder

A GitLab CI pipeline for building multi-architecture container images using Kaniko. This pipeline can build Kaniko itself and other projects with similar semantics.

## Overview

This project provides a reusable GitLab CI pipeline that:
- Builds container images for multiple architectures (amd64 + arm64)
- Uses Kaniko as the build tool
- Creates multi-arch manifests for automatic architecture selection
- Supports building external projects by cloning their repositories

## Current Status: MVP Complete

- **Phase 1**: ✅ Basic Kaniko arm64 build implemented
- **Phase 2**: ✅ Multi-arch support (amd64 + arm64) with manifest creation
- **Phase 3**: ✅ Generalized framework with build-config.yaml
- **Phase 4**: ✅ Added second project (curl) and polished implementation
- **Phase 5**: ✅ Remote repository cloning (Issue #2 - spkane/scratch-helloworld validated)
- **Phase 6**: ✅ Additional tags support (Issue #4 - `latest`, version tags functional)

### Latest Capabilities (Oct 16, 2025)
- **Remote GitHub repositories**: Clone and build public repos
- **Professional tagging**: `latest`, `v1.0.0` style tags supported  
- **Multi-arch manifests**: Automatic architecture selection
- **External Kaniko**: Using maintained `martizih/kaniko:v1.26.0-debug`
- **Self-contained tools**: No circular dependencies

## Directory Structure

```
.
├── .gitlab-ci.yml          # Main GitLab CI pipeline
├── hack/                   # Build scripts and utilities
│   ├── prepare_diff.sh     # Detects changed directories
│   └── README.md          # Documentation for scripts
├── README.md              # This file
├── kaniko/                # Kaniko build configuration
│   ├── build-config.yaml  # Build metadata for Kaniko
│   └── README.md          # Kaniko-specific documentation
├── curl/                  # Curl build configuration
│   ├── build-config.yaml  # Build metadata for Curl
│   └── README.md          # Curl-specific documentation
├── rebuild-weekly.txt     # List of projects to rebuild weekly
```

## Usage

The pipeline automatically triggers on:
- Merges to main branch (builds changed directories)
- Scheduled runs (builds all directories in rebuild-weekly.txt)

## Configuration

Each buildable project has a `build-config.yaml` file that specifies:
- Upstream repository and version
- Dockerfile path and build context
- Target architectures
- Additional image tags

See `kaniko/build-config.yaml` for an example.

## Requirements

- GitLab runners with multi-architecture support
- ECR registry access configured via `ECR_REGISTRY` CI/CD variable
- `CICD_TAG` variable for runner selection
