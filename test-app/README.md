# Test Application for Multi-Arch Pipeline Validation

This tests our multi-arch Kaniko pipeline using **spkane/scratch-helloworld** - a real Go HTTP server application.

## Purpose

Validate that:
- ✅ External Kaniko (`martizih/kaniko:v1.26.0-debug`) can build multi-arch images
- ✅ **Remote repository cloning works** (Issue #2 validation!)
- ✅ Pipeline creates both amd64 and arm64 variants  
- ✅ **Additional tags support** (Issue #4 - testing crane implementation + TODO bug fixes!)  
- ✅ Manifest tool combines them into multi-arch manifest
- ✅ Circular dependency between curl/manifest-tool resolved (Oct 16, 2025)
- ✅ Docker automatically selects correct architecture

## What It Does

**spkane/scratch-helloworld** is a simple Go HTTP server that:
- Listens on port 8080
- Responds with "Hello World!" 
- Perfect for testing multi-arch container builds
- Real-world Go application (not just a toy example)

## Expected Pipeline Output

```bash
# Should create tags like:
test-app-20251016-amd64
test-app-20251016-arm64  
test-app-20251016        # Multi-arch manifest

# Additional tags:
test-app-latest
test-app-pipeline-test
```

## Testing Multi-Arch

```bash
# Test automatic architecture selection
docker run --rm <ECR-REGISTRY>:test-app-latest

# Test specific architectures  
docker run --rm --platform linux/amd64 <ECR-REGISTRY>:test-app-latest
docker run --rm --platform linux/arm64 <ECR-REGISTRY>:test-app-latest
```

## Success Criteria

- ✅ Pipeline builds without errors
- ✅ Both architecture variants are created
- ✅ Multi-arch manifest is published  
- ✅ Architecture-specific selection works
- ✅ Proves external Kaniko integration works

This validates our entire multi-arch build infrastructure using a maintained external Kaniko image.