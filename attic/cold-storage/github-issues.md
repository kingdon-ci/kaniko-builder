# GitHub Issues for Kaniko Builder

This document tracks the issues identified in the kaniko-builder project that need to be created in GitHub.

## Issue 1: Manifest Stage Missing Prepare Dependency

**Title**: `manifest` stage fails when build jobs fail due to missing `prepare` dependency

**Priority**: Medium (Easy Fix)

**Description**: 
The `manifest` stage in the GitLab CI pipeline attempts to read `dirs.txt` but doesn't depend on the `prepare` stage that creates this file. This causes the manifest stage to fail when build jobs fail, even though the build failure might be unrelated to manifest creation.

**Root Cause Analysis**:
- The `manifest` stage script contains: `for dir in $(cat dirs.txt)` (line 438 in `.gitlab-ci.yml`)
- `dirs.txt` is created by the `prepare` stage
- Current dependencies: `build_arm64`, `build_amd64` 
- Missing dependency: `prepare`

**Error Symptoms**:
```
cat: can't open 'dirs.txt': No such file or directory
```

**Solution**:
Add `prepare` to the manifest stage dependencies:
```yaml
manifest:
  dependencies:
    - prepare      # ADD THIS LINE  
    - build_arm64
    - build_amd64
```

**Source Documents** (for cleanup consideration):
- `/AGENTS.md` - Lines 150-158 (Issue 2: Manifest Stage Dependencies)
- `/PROGRESS_REPORT.md` - Issue 2: Manifest Stage Missing dirs.txt
- `/.gitlab-ci.yml` - Lines 424-426 (current incorrect dependencies)

**Acceptance Criteria**:
- [ ] `prepare` added to manifest dependencies
- [ ] Pipeline runs successfully even when build jobs fail
- [ ] `dirs.txt` is available to manifest stage
- [ ] Test with intentionally failed build jobs

---

## Issue 2: Remote Repository Cloning Blocked by Missing Git

**Title**: Cannot build from remote repositories due to git unavailable in Kaniko debug image

**Priority**: Critical (Blocks main goal)

**Description**:
The primary goal of building Kaniko itself is blocked because Kaniko's debug image (`gcr.io/kaniko-project/executor:debug`) doesn't include git or package managers. This prevents cloning upstream repositories.

**Impact**:
- Cannot build Kaniko (primary project goal)
- Any project requiring `upstream_repo` in `build-config.yaml` fails
- Limited to `use_local_context: true` builds only

**Root Cause Analysis**:
- Kaniko debug image is minimal and security-focused
- No `apk`, `apt`, or other package managers available
- No `git` binary included
- Build stage uses Kaniko image which lacks cloning capabilities

**Current Workaround**:
Only local context builds work (curl, manifest-tool)

**Proposed Solution**:
Pre-clone in prepare stage using `alpine/git` image:
1. Detect remote repositories in prepare stage
2. Clone repos and package as `{directory}-source.tar.gz` artifacts
3. Extract artifacts in build stage before Kaniko execution
4. Modify build script to use extracted source

**Source Documents** (for cleanup consideration):
- `/AGENTS.md` - Lines 135-149 (Issue 1: Remote Repository Cloning)
- `/PROGRESS_REPORT.md` - Issue 1: Kaniko Builds Failing (Remote Repos)
- `/SPEC.md` - Lines 101-150 (Stage 2: Build requirements)
- `/.gitlab-ci.yml` - Lines 87-100 (current git detection logic)

**Acceptance Criteria**:
- [ ] Pre-clone implementation in prepare stage
- [ ] Artifact packaging and extraction working
- [ ] Successfully clone and build Kaniko repository
- [ ] Multi-arch Kaniko builds functional
- [ ] Pipeline can build any project with `upstream_repo`

---

## Issue 3: Multi-Target Build Support for Kaniko Variants

**Title**: Support building multiple Kaniko variants (executor, debug, warmer) from single repository

**Priority**: High (Required for complete Kaniko support)

**Description**:
Kaniko has multiple build targets in its Makefile (`make images` includes executor, debug, warmer, etc.) but the current directory-based system assumes one image per directory. Need to design enhanced `build-config.yaml` format to support multiple targets.

**Current Limitation**:
- `kaniko/` directory only builds debug variant
- Need all Kaniko variants for complete replacement
- Directory naming becomes awkward (kaniko-executor/, kaniko-debug/)

**Proposed Solution**:
Enhanced `build-config.yaml` with targets array:
```yaml
upstream_repo: https://github.com/chainguard-dev/kaniko
upstream_ref: v1.25.3
dockerfile_path: deploy/Dockerfile

targets:
  - name: executor
    target: executor
    additional_tags: [latest, v1.25.3]
  - name: debug  
    target: debug
    additional_tags: [debug-latest, debug-v1.25.3]
```

**Source Documents** (for cleanup consideration):
- `/AGENTS.md` - Lines 159-171 (Issue 3: Multi-Target Kaniko Builds)
- `/SPEC.md` - Lines 160-180 (Kaniko-Specific Considerations)
- User requirements for multiple Kaniko variants

**Research Required**:
- [ ] Examine Kaniko Makefile structure
- [ ] Identify all available build targets
- [ ] Design matrix build job generation
- [ ] Test with actual Kaniko repository

**Acceptance Criteria**:
- [ ] Enhanced build-config.yaml format implemented
- [ ] Multiple images generated from single repository
- [ ] All Kaniko variants (executor, debug, warmer) buildable
- [ ] Proper tagging for each variant
- [ ] Multi-arch support for all variants

---

## Issue 4: Additional Tags Implementation Missing

**Title**: `additional_tags` field parsed but not implemented

**Priority**: Low (Feature enhancement)

**Description**:
The `build-config.yaml` supports an `additional_tags` field that gets parsed but no additional tags are actually created. Need tooling to copy/tag images after Kaniko build.

**Current State**:
- Tags parsed from YAML correctly
- TODO comment in pipeline: "requires crane or similar tool"
- Only date-based tags created (e.g., `curl-20251015-amd64`)

**Solution Options**:
1. Add `crane` to manifest-tool image (recommended)
2. Use Kaniko's multiple `--destination` flags (wasteful)
3. Create separate tagging stage

**Source Documents** (for cleanup consideration):
- `/AGENTS.md` - Lines 172-180 (Issue 4: Additional Tags Not Implemented)
- `/.gitlab-ci.yml` - Lines 280-290 (TODO comments)

**Acceptance Criteria**:
- [ ] `crane` added to manifest-tool image
- [ ] Additional tags implemented in manifest stage
- [ ] Tags like `latest`, `v1.25.3` working
- [ ] Both arch-specific and manifest tags supported

---

## Documentation Cleanup Plan

After these issues are resolved, consider archiving/consolidating:

1. **PROGRESS_REPORT.md** → Archive to `attic/docs/` (historical record)
2. **IMPLEMENTATION_PLAN.md** → Update with actual implementation details
3. **AGENTS.md** → Keep as primary context document
4. **SPEC.md** → Merge relevant parts into README, archive rest

**New Documentation Structure**:
- `README.md` - Current usage and setup
- `AGENTS.md` - Comprehensive technical context  
- `DEVELOPMENT.md` - Contributing and testing guide
- `attic/docs/` - Historical implementation documents
- GitHub Issues - Active issue tracking
- GitHub Wiki - Detailed technical docs