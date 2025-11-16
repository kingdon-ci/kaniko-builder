# GitLab CI Modernization Plan

## Executive Summary

**Current State**: The GitLab CI workflow contains ~600 lines of embedded shell scripts due to Kaniko's limitations (missing `/bin/sh`), preventing modular script extraction. The workflow has grown complex with redundant code and multiple backend logic mixed into YAML templates.

**Goal**: Modernize the GitLab CI pipeline to be maintainable, testable, and extensible while working within Kaniko's constraints until BuildKit integration enables full script modularity.

**Key Challenge**: Kaniko lacks `/bin/sh`, preventing execution of external scripts from `hack/` directory. We embedded all logic in YAML to work around this limitation.

## Current Architecture Analysis

### GitLab CI Structure (609 lines)
```
prepare stage (alpine/git)         → 120 lines of embedded bash
build_amd64/arm64 (kaniko:debug)   → 280 lines x2 = 560 lines of embedded bash  
manifest stage (manifest-tool)     → 150 lines of embedded bash
```

### Critical Issues Identified

#### 1. **Script Embedding Problem**
- **Root Cause**: Kaniko image lacks `/bin/sh` binary
- **Current Workaround**: All logic embedded in `.gitlab-ci.yml` 
- **Impact**: 600+ lines of unmaintainable, untestable shell code
- **Evidence**: Build template contains 280 lines of inline script

#### 2. **Code Duplication**
- Build template repeated for ARM64/AMD64 with 95% identical logic
- Architecture detection logic duplicated across stages
- Build config parsing repeated in every stage

#### 3. **Testing Limitations**
- Embedded scripts cannot be unit tested in isolation
- No local development workflow for script changes
- Debugging requires full GitLab CI pipeline runs

#### 4. **Kaniko Self-Build Blocker**
- **Original Goal**: Build Kaniko itself for self-hosting
- **Blocker**: Kaniko's Dockerfile uses BuildKit `RUN --mount=from=` syntax
- **Current Solution**: Using external `martizih/kaniko:v1.26.0-debug`
- **Future Path**: BuildKit integration would enable Kaniko self-build

## Modernization Strategy

### Phase 1: Immediate Improvements (Without BuildKit)
**Target**: Reduce complexity while maintaining Kaniko compatibility

#### 1.1 Create Enhanced Builder Image
**Problem**: Kaniko image lacks essential tools
**Solution**: Build custom `hephy-kaniko` image

```dockerfile
# hephy-kaniko/Dockerfile
FROM martizih/kaniko:v1.26.0-debug
USER root

# Add essential shell and tools
RUN apk add --no-cache \
    bash \
    curl \
    git \
    yq \
    jq

# Add hephy-builder scripts
COPY hack/ /hephy/scripts/
RUN chmod +x /hephy/scripts/*.sh

USER kaniko
```

**Benefits**:
- ✅ Enables external script execution
- ✅ Reduces GitLab CI from 600 to ~150 lines  
- ✅ Makes scripts unit testable
- ✅ Improves debugging experience

#### 1.2 Extract Scripts to hack/ Directory
**Target Structure**:
```
hack/
├── prepare_diff.sh           # ✅ Already exists
├── build_images.sh           # 🔄 Needs enhancement  
├── create_manifests.sh       # ➕ New
├── parse_build_config.sh     # ➕ New  
├── detect_architecture.sh    # ➕ New
└── test-all-scripts.sh       # ➕ New
```

#### 1.3 Modernized GitLab CI (Target: ~150 lines)
```yaml
stages: [prepare, build, manifest]

prepare:
  image: alpine/git:latest
  script: /hephy/scripts/prepare_diff.sh

.build_template: &build_template
  image: hephy-kaniko:latest
  script: /hephy/scripts/build_images.sh $ARCH

manifest:
  image: hephy-kaniko:latest  
  script: /hephy/scripts/create_manifests.sh
```

### Phase 2: BuildKit Integration
**Target**: Enable advanced Docker features and Kaniko self-build

#### 2.1 Add BuildKit Backend Support
**Configuration**:
```yaml
# build-config.yaml
build_backend: buildkit

buildkit_config:
  features:
    - cache_mounts
    - secrets
    - ssh_agent
  platforms:
    - linux/amd64
    - linux/arm64
```

**Benefits**:
- ✅ Supports all Dockerfile syntax
- ✅ Enables Kaniko self-build  
- ✅ Advanced caching capabilities
- ✅ Parallel build stages

#### 2.2 Enhanced Backend Matrix
```yaml
# Future backend support
build_backend: kaniko|ko|buildkit|spin

ko_config:          # Go-optimized builds
buildkit_config:    # Advanced Docker features  
spin_config:        # WebAssembly applications
```

### Phase 3: Advanced Features
**Target**: Complete modernization with testing and optimization

#### 3.1 Comprehensive Testing Framework
```bash
hack/test/
├── unit/
│   ├── test_parse_config.sh
│   ├── test_detect_arch.sh
│   └── test_build_logic.sh
├── integration/
│   ├── test_local_builds.sh
│   └── test_remote_builds.sh
└── e2e/
    └── test_full_pipeline.sh
```

#### 3.2 Performance Optimizations
- Parallel architecture builds
- Intelligent caching strategies  
- Change detection optimization
- Build artifact reuse

## Implementation Roadmap

### Week 1: Foundation (Phase 1.1)
**Priority**: Critical infrastructure

1. **Create `hephy-kaniko` builder image**
   - Build Dockerfile with bash/git/tools added to Kaniko
   - Test script execution capability
   - Deploy to ECR registry

2. **Validate script extraction**
   - Convert one embedded script section to external script
   - Test in GitLab CI pipeline
   - Verify functionality maintained

**Success Criteria**: External script executes successfully in Kaniko environment

### Week 2: Script Extraction (Phase 1.2)
**Priority**: High

1. **Extract build logic**
   - Create `hack/build_images.sh` with backend detection
   - Convert embedded build template to script calls
   - Add error handling and logging

2. **Extract manifest logic**  
   - Create `hack/create_manifests.sh`
   - Convert manifest stage to script call
   - Test multi-arch manifest creation

**Success Criteria**: GitLab CI reduced to <200 lines with maintained functionality

### Week 3: Testing & Validation (Phase 1.3)
**Priority**: High

1. **Create unit testing framework**
   - Write tests for config parsing
   - Write tests for architecture detection
   - Set up local testing workflow

2. **Validate complete modernization**
   - Test all existing build scenarios
   - Verify multi-arch functionality
   - Performance comparison with original

**Success Criteria**: All existing functionality working with new architecture

### Week 4: BuildKit Integration (Phase 2.1)
**Priority**: Medium

1. **Add BuildKit backend**
   - Implement BuildKit build logic
   - Add buildkit_config parsing
   - Test advanced Dockerfile features

2. **Enable Kaniko self-build**
   - Configure kaniko/ directory for BuildKit
   - Test self-hosting capability
   - Validate bootstrapping process

**Success Criteria**: Can build Kaniko using BuildKit backend

## Risk Assessment & Mitigation

### High Risk: BuildKit Complexity
**Risk**: BuildKit integration adds operational complexity
**Mitigation**: 
- Start with simple BuildKit builds
- Maintain Kaniko fallback option
- Comprehensive testing before production

### Medium Risk: Image Size Growth  
**Risk**: hephy-kaniko image becomes large
**Mitigation**:
- Use multi-stage build optimization
- Alpine-based additions only
- Regular size monitoring

### Low Risk: Script Compatibility
**Risk**: Extracted scripts have environment differences
**Mitigation**:
- Extensive testing in GitLab CI
- Environment variable documentation
- Rollback capability maintained

## Success Metrics

### Technical Metrics
- **Line Count**: GitLab CI <150 lines (from 600+)
- **Test Coverage**: >80% script line coverage
- **Build Time**: Maintain current performance
- **Functionality**: 100% feature parity

### Developer Experience
- **Local Testing**: Scripts runnable outside GitLab
- **Debug Time**: Faster issue resolution
- **Change Velocity**: Easier feature additions
- **Maintenance**: Reduced complexity burden

## Questions for Clarification

### Infrastructure Questions
1. **ECR Access**: Do we have permissions to push custom `hephy-kaniko` images?
2. **Runner Resources**: Are there compute constraints for BuildKit integration?
3. **Registry Strategy**: Should we use separate registry for builder images?

### Feature Priorities  
1. **Backend Priority**: Is BuildKit integration higher priority than script extraction?
2. **Testing Scope**: How comprehensive should the testing framework be initially?
3. **Backward Compatibility**: Do we need to maintain the old GitLab CI as fallback?

### Timeline Constraints
1. **Delivery Timeline**: Are there external deadlines affecting this modernization?
2. **Resource Allocation**: How much development time is available per week?
3. **Validation Requirements**: What level of testing is required before production?

### Technical Decisions
1. **Image Strategy**: Should `hephy-kaniko` be minimal or comprehensive?
2. **Script Organization**: Any preferences for hack/ directory structure?
3. **BuildKit Mode**: Rootless vs rootful BuildKit preference?

## Next Steps

1. **Review and Approval**: Validate this plan addresses your requirements
2. **Clarification**: Answer the questions above to refine approach  
3. **Pilot Implementation**: Start with Week 1 foundation work
4. **Continuous Validation**: Test each phase before proceeding

This plan provides a structured path from the current embedded script architecture to a modern, maintainable system while working within current constraints and providing a clear path to advanced BuildKit capabilities.