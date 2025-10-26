# hephy-builder: Test Application for Pipeline Validation

Real-world validation using **spkane/scratch-helloworld** - a Go HTTP server that demonstrates hephy-builder's capabilities.

**Role in hephy-builder**: Production validation of the remote repository building capability that bridges kaniko-builder MVP to full hephy-builder vision.

## Purpose & Heritage

This test validates the complete hephy-builder foundation:
- ✅ **Remote repository builds** (GitHub integration)
- ✅ **Multi-architecture support** (AMD64 + ARM64)  
- ✅ **Professional tagging** (latest, version tags, custom names)
- ✅ **Real-world application** (Go HTTP server, not toy examples)
- ✅ **Future backend readiness** (Ko will excel with Go applications)

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