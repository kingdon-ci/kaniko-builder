# hephy-builder: Archive and Cold Storage

Historical documentation and reference materials preserving the evolution from kaniko-builder to hephy-builder.

**Heritage Value**: Documents the complete transformation journey, architectural decisions, and lessons learned during the evolution to modern PaaS resurrection.

## Directory Structure

### `/cold-storage/`
**Purpose**: Retired documents from kaniko-builder phase, preserving historical context for hephy-builder development.

**Heritage Contents**: 
- Resolved kaniko-builder issues and implementation records
- Original planning documents before transformation
- Bootstrap process documentation and lessons learned
- Retirement records documenting the evolution process

**Protocol**: See `cold-storage/README.md` for complete retirement protocol.

### Root Attic Files
**Purpose**: Reference materials that may have ongoing value but are not part of active development.

**Current Contents**:
- `crossplane-node-pool-objects.yaml` - Node pool configuration examples
- `example-gitlab-runner.yaml` - GitLab runner configuration template
- `gitlab-runner-amd64.yaml` - AMD64-specific runner config
- `gitlab-runner-arm64.yaml` - ARM64-specific runner config  
- `minimal-example.gitlab-ci.yml` - Simplified CI example
- `object-node-pool.yaml` - Alternative node pool config
- `multiarch-spot-nodepool.yaml` - Multi-arch node pool setup

## Document Lifecycle

```
Active Docs → Issues Created → Issues Resolved → Information Migrated → Cold Storage
     ↓              ↓              ↓                    ↓                   ↓
README.md      GitHub Issues   Closed Issues      Planned Docs         Retired
AGENTS.md         #1-4         (When fixed)      (Architecture)       Documents
```

### Active Documents
- `README.md` - Current usage and overview
- `AGENTS.md` - Comprehensive technical context
- `DEVELOPMENT.md` - Contributing and development guide (when created)

### Issue Tracking
- **GitHub Issues**: `github.com/kingdon-ci/kaniko-builder/issues`
- **Current Issues**: #1 (manifest deps), #2 (remote cloning), #3 (multi-target), #4 (additional tags)

### Retirement Candidates
Documents awaiting retirement after issue resolution:
- `PROGRESS_REPORT.md` - Status report (superseded by GitHub issues)
- `IMPLEMENTATION_PLAN.md` - May contain valuable operational info to preserve

## Guidelines

### Keep in Attic (Root)
- Configuration examples and templates
- Infrastructure setup references
- Historical context with ongoing value

### Move to Cold Storage
- Issue descriptions now in GitHub
- Status reports superseded by issue tracking
- Ad-hoc documentation replaced by planned docs

### Never Archive
- Current operational documentation
- Active configuration files
- Maintained technical references

## Maintenance

- **Quarterly Review**: Evaluate retirement candidates
- **Issue Resolution**: Retire documents when GitHub issues close
- **Information Audit**: Ensure migration completeness before retirement