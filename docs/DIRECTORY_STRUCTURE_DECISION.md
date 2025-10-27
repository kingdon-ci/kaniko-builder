# Directory Structure Decision for hephy-builder

**Date**: October 26, 2025  
**Context**: Discovered that current pipeline only supports single-level directories  
**Issue**: Created `examples/ko-demo/build-config.yaml` but pipeline expects `*/build-config.yaml`

## 🔍 Problem Analysis

### Current Pipeline Behavior
- `prepare_diff.sh` uses `cut -d/ -f1` to extract first directory level only
- Changed file: `examples/ko-demo/cmd/server/main.go` → detected as `examples/`
- Pipeline looks for `examples/build-config.yaml` (doesn't exist)
- **Result**: Nested projects completely ignored

### Existing Structure
```
curl/build-config.yaml              ✅ Works (1 level)
kaniko/build-config.yaml            ✅ Works (1 level)  
examples/ko-demo/build-config.yaml  ❌ Ignored (2 levels)
```

## 🎯 Strategic Options

### Option A: Flatten Structure
**Move to**: `ko-demo/build-config.yaml`
- ✅ **Pros**: Works immediately with current pipeline
- ❌ **Cons**: Pollutes top-level namespace, doesn't scale

### Option B: Extend Pipeline (RECOMMENDED)
**Modify**: `prepare_diff.sh` to find all `build-config.yaml` files in changed paths
- ✅ **Pros**: Supports organized structure, future-proof, GitHub migration friendly
- ✅ **Pros**: Enables templates, examples, organized backends
- ⚠️ **Cons**: Requires pipeline modification (manageable)

### Option C: Hybrid Approach  
**Support**: Both `*/build-config.yaml` and `examples/*/build-config.yaml`
- ✅ **Pros**: Backwards compatible, organized examples
- ❌ **Cons**: More complex logic, potential confusion

## 🚀 **Recommendation: Option B**

**Rationale**: 
- **GitHub migration strategy**: More flexible structure supports multi-org plans
- **hephy-builder vision**: Needs organized templates, examples, backends
- **Scalability**: Supports future growth patterns

### Future Structure Vision
```
# Multi-org GitHub structure potential:
kingdon-ci/hephy-builder/
├── backends/
│   ├── ko-demo/build-config.yaml      # Go optimization
│   ├── spin-demo/build-config.yaml    # WebAssembly  
│   └── buildkit-demo/build-config.yaml # Advanced Docker
├── templates/
│   ├── nextjs-app/build-config.yaml   # React applications
│   ├── go-service/build-config.yaml   # Microservices
│   └── python-api/build-config.yaml   # FastAPI/Django
├── core/
│   ├── curl/build-config.yaml         # Utilities
│   ├── manifest-tool/build-config.yaml
│   └── stern/build-config.yaml        # Log aggregation
└── examples/
    └── minimal-app/build-config.yaml  # Getting started
```

## 🛠️ **Implementation Plan**

### Immediate Action Required
1. **Decide on approach** before committing Ko demo
2. **Implement pipeline changes** if choosing Option B
3. **Document directory structure policy** for future contributors

### Pipeline Modification (Option B)
```bash
# Current: Extract first directory level only
git diff --name-status --diff-filter=AMR $DIFF_TARGET | awk '{print $2}' | grep '/' | cut -d/ -f1

# New: Find all directories containing build-config.yaml in changed paths
find_changed_build_configs() {
  git diff --name-status --diff-filter=AMR $DIFF_TARGET | awk '{print $2}' | while read file; do
    dir=$(dirname "$file")
    while [ "$dir" != "." ]; do
      if [ -f "$dir/build-config.yaml" ]; then
        echo "$dir"
        break
      fi
      dir=$(dirname "$dir")
    done
  done | sort -u
}
```

## 📋 **Decision Matrix**

| Criteria | Option A (Flatten) | Option B (Extend) | Option C (Hybrid) |
|----------|-------------------|-------------------|-------------------|
| **Immediate compatibility** | ✅ | ⚠️ | ⚠️ |
| **GitHub migration ready** | ❌ | ✅ | ✅ |
| **Scalability** | ❌ | ✅ | ⚠️ |
| **Implementation effort** | ✅ | ⚠️ | ❌ |
| **Future maintenance** | ❌ | ✅ | ❌ |

## 🎯 **Recommendation: Implement Option B**

**Justification**: The GitHub migration and multi-org strategy requires a flexible, scalable directory structure. The pipeline modification is manageable and enables the full hephy-builder vision.

**Next Steps**:
1. Modify `prepare_diff.sh` to support nested `build-config.yaml` detection
2. Update `.gitlab-ci.yml` to handle nested directory processing  
3. Document the new directory structure policy
4. Test with `examples/ko-demo` as the first nested project