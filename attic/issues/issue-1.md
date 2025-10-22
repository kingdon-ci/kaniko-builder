---
# Issue #1: manifest stage fails when build jobs fail due to missing prepare dependency

**State**: CLOSED
**Created**: 2025-10-16T17:10:38Z
**Closed**: 2025-10-16T17:14:59Z

## Description

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
- [x] `prepare` added to manifest dependencies
- [x] Pipeline runs successfully even when build jobs fail
- [x] `dirs.txt` is available to manifest stage
- [x] Test with intentionally failed build jobs
