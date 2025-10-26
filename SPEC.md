# Specification: Multi-Arch Image Builder Pipeline

**Status**: MVP Complete → hephy-builder Transformation Complete (October 26, 2025)  
**Documentation**: See `docs/` for comprehensive guides and specifications  
**Next Phase**: See GitHub Issues for active development tasks

## 🎯 **Project Evolution Summary**

### **Original Mission (kaniko-builder)**
Build multi-architecture container images with Kaniko, supporting both self-hosted Kaniko builds and external project building.

### **Evolved Mission (hephy-builder)**  
Resurrect the elegant "git push deis main" developer experience using modern, secure, multi-platform container and WebAssembly build tooling.

### **Transformation Achievements (PR #13)**
- ✅ **Documentation architecture**: Professional docs/ structure with lore/ heritage preservation
- ✅ **Vision articulation**: Complete hephy-builder roadmap and developer experience design  
- ✅ **Implementation roadmap**: 18 GitHub issues spanning research, design, and implementation
- ✅ **Community foundation**: Contributor onboarding, examples, and clear project navigation
- ✅ **Heritage preservation**: Deis Workflow story and lessons documented for posterity

### 1. Build Kaniko Itself - Evolved to External Solution
- **Original Goal:** Build `gcr.io/kaniko-project/executor:debug` for arm64 + amd64
- **Actual Achievement:** Adopted maintained external Kaniko (`martizih/kaniko:v1.26.0-debug`)
- **Outcome:** Zero maintenance overhead, community maintained
- **Decision:** Deferred self-build (Issue #6) in favor of external dependency strategy

### 2. Support Multiple External Projects - Achieved
- **Original Goal:** Support one additional project  
- **Actual Achievement:** Generalized framework supporting GitHub repositories
- **Validated Examples:** spkane/scratch-helloworld (Go HTTP server), manifest-tool, test-app
- **Remote Cloning:** GitHub integration with pre-clone artifact system

### 3. Multi-Architecture Support - Achieved
- **Original Goal:** Build for linux/amd64 and linux/arm64 with proper manifests
- **Actual Achievement:** Full multi-arch pipeline with professional tagging and dependency resolution
- **Additional Features:** 
  - Professional image tagging (`latest`, version tags)
  - Smart change detection and architecture filtering
  - Circular dependency elimination
  - Self-contained tool architecture

## Current Capabilities (October 2025)

## Pipeline Behavior

### Trigger Conditions
- **On merge to main:** Build all directories with changes (like current minimal-base-image)
- **On scheduled runs:** Build all directories listed in `rebuild-weekly.txt` (future)

### Directory Structure
```
.
├── .gitlab-ci.yml
├── hack/
│   ├── prepare_diff.sh (adapted from minimal-base-image)
│   └── README.md
├── README.md
├── rebuild-weekly.txt (for scheduled builds)
├── kaniko/
│   ├── build-config.yaml
│   └── README.md
└── another-tool/
    ├── build-config.yaml
    └── README.md
```

### Metadata File Format: `build-config.yaml`

```yaml
# Example for Kaniko
upstream_repo: https://github.com/chainguard-dev/kaniko
upstream_ref: v1.25.3  # Can be tag, branch, or commit SHA

# Path to Dockerfile relative to upstream repo root
dockerfile_path: deploy/Dockerfile

# Optional: Dockerfile target (for multi-stage builds)
target: ""  # e.g., "executor", "warmer", "debug" for Kaniko

# Optional: Build context path (defaults to repo root)
context_path: .

# Build arguments to pass to Kaniko
build_args:
  - ARG1=value1
  - ARG2=value2

# Architectures to build
platforms:
  - linux/amd64
  - linux/arm64

# Tags to apply (in addition to date-commit tag)
# Format: {directory-name}-{tag}
additional_tags:
  - v1.25.3
  - latest
```

### Image Naming Convention
Following minimal-base-image pattern:
- **Default tag:** `{directory-name}-{YYYYMMDD}-{short-sha}`
  - Example: `kaniko-20251014-a1b2c3d`
- **Additional tags:** As specified in `build-config.yaml`
  - Example: `kaniko-v1.25.3`, `kaniko-latest`

### ECR Destinations
- Use same `ECR_REGISTRY` CI/CD variable as minimal-base-image
- All images pushed to single ECR repo (like minimal-base-image)
- Multi-arch manifest references individual arch-specific tags

## Pipeline Stages

### Stage 1: Prepare
- Run `prepare_diff.sh` (adapted from minimal-base-image)
- Detect which directories changed
- Validate `build-config.yaml` exists in each directory
- Output `dirs.txt` for next stage

### Stage 2: Build (Multi-Arch)

Each directory spawns parallel jobs for each architecture:

1. **Clone upstream repo** at specified ref
2. **Build image for specific architecture** using Kaniko
   - Use `--customPlatform` flag for architecture
   - Use `--cache=false --use-new-run --cleanup` (like current pipeline)
   - Tag with arch-specific suffix: `{image-tag}-{arch}`
3. **Push arch-specific image** to ECR

### Stage 3: Manifest
- Wait for all architecture builds to complete
- Use `manifest-tool` or Kaniko's approach to create multi-arch manifest
- Apply all tags from `build-config.yaml`
- Push manifest to ECR

## Kaniko-Specific Considerations

### Multiple Targets in One Dockerfile
Kaniko's Dockerfile has multiple targets (executor, warmer, debug, etc.):
- **Solution 1 (Preferred):** Create separate directories for each target
  ```
  kaniko-executor/
  kaniko-debug/
  kaniko-warmer/
  ```
  Each points to same upstream repo but different `target` in `build-config.yaml`

- **Solution 2:** Support array of targets in one directory (more complex)

### Building Kaniko with Kaniko
- Use existing Kaniko image to build new Kaniko
- Start with `gcr.io/kaniko-project/executor:latest` as builder
- After first successful build, use our own image for future builds

## Pragmatic Implementation Path

### Phase 1: Get Kaniko Working (Priority 1)
**Goal:** Build Kaniko arm64 ASAP, even if not perfect

1. Create minimal `.gitlab-ci.yml` that:
   - Clones Kaniko repo
   - Builds for arm64 using Kaniko
   - Pushes to ECR
   - Don't worry about multi-arch manifest yet

2. Validate it works and replaces our EOL Kaniko image

3. Document the process

### Phase 2: Add Multi-Arch (Priority 2)
1. Add amd64 build in parallel
2. Create multi-arch manifest
3. Test auto-pull of correct architecture

### Phase 3: Generalize Framework (Priority 3)
1. Adapt `prepare_diff.sh` from minimal-base-image
2. Add `build-config.yaml` support
3. Add second test project
4. Refactor to handle multiple directories

### Phase 4: Polish (Priority 4)
1. Better error handling
2. Build caching strategies
3. Scheduled rebuild support

## Technical Requirements

### GitLab Runner Tags
- Use `$CICD_TAG` variable (like minimal-base-image)
- Ensure arm64 runners are available and tagged appropriately

### Authentication
- **Public repos:** No auth needed (start here)
- **Private GitLab repos:** Use runner token (already available)
- **Future complex auth:** GitLab CI Secrets or K8s External Secrets

### ECR Authentication
- Use ECR credential helper: `{"credsStore":"ecr-login"}`
- Configure in `/kaniko/.docker/config.json`

### Artifact Management
- `dirs.txt` passed between stages
- Build logs captured for debugging
- Consider caching cloned repos (optional optimization)

## Success Criteria

### Minimum Viable Product (Achieved)
- [x] Can build Kaniko v1.25.3 for arm64 (deferred - using external)
- [x] Can build Kaniko v1.25.3 for amd64 (deferred - using external)
- [x] Multi-arch manifest created and pushed
- [x] Can build other projects with Dockerfiles
- [x] Images pushed to ECR with proper tags
- [x] Pipeline triggered on merge to main
- [x] Documentation explains how to add new projects

### Nice to Have (Future Phases)
- [ ] Reusable GitLab CI component for other repos
- [ ] Scheduled rebuilds via `rebuild-weekly.txt`
- [ ] Build caching for faster iterations
- [ ] Parallel builds of multiple projects
- [ ] Support for private repos with complex auth

## Reference Materials
- Current minimal-base-image pipeline: [provided above]
- GitLab Kaniko component: https://gitlab.com/explore/catalog/guided-explorations/ci-components/kaniko
- Kaniko multi-arch docs: https://github.com/chainguard-dev/kaniko?tab=readme-ov-file#creating-multi-arch-container-manifests-using-kaniko-and-manifest-tool
- Upstream Kaniko: https://github.com/chainguard-dev/kaniko

## Key Constraints
- **Timeline:** ~10 hours for implementation
- **Pragmatism:** Working > Perfect. Iterate after Phase 1.
- **Compliance:** Must not use EOL/unsupported Kaniko version
- **Efficiency:** Don't sacrifice obvious efficiencies (parallel builds, etc.)

## Notes for Cline
- **Shortcut encouraged:** If you find a faster way to get arm64 Kaniko working, take it. We can iterate.
- **Don't reinvent wheels:** Use existing GitLab examples and patterns
- **Ask questions:** If something is ambiguous, surface it quickly
- **Incremental commits:** Get Phase 1 working, commit, then move to Phase 2
