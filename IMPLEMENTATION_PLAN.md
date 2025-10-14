# Multi-Architecture Runner Implementation Plan

## Problem Statement

The current kaniko-builder pipeline assumes a single `CICD_TAG` can handle both amd64 and arm64 builds. However, to ensure builds run on the correct architecture, we need separate GitLab runners with architecture-specific node selectors.

**Current State:**
- Single runner with `CICD_TAG: scip-sandbox` 
- `spot-pool` constrained to amd64 nodes only
- Pipeline jobs can't guarantee they run on the intended architecture

**Target State:**
- Separate runners for amd64 and arm64
- `spot-pool` unconstrained, can provision both architectures
- Explicit node selectors for architecture-specific workloads
- Pipeline jobs guaranteed to run on correct architecture

## Implementation Plan

### Phase 1: Update Kubernetes Node Pool Configuration

1. **Remove Architecture Constraint from spot-pool**
   ```yaml
   # REMOVE this constraint from spot-pool:
   - key: kubernetes.io/arch
     operator: In
     values:
     - amd64
   ```

2. **Update spot-pool to support both architectures**
   ```yaml
   # Allow spot-pool to provision both amd64 and arm64 nodes
   - key: kubernetes.io/arch
     operator: In
     values:
     - amd64
     - arm64
   ```

### Phase 2: Create Architecture-Specific GitLab Runners

#### Option A: Separate Runner Deployments (Recommended)

Based on your existing `attic/example-gitlab-runner.yaml`, create two separate GitLab runner deployments:

1. **AMD64 Runner Configuration**
   ```yaml
   # gitlab-runner-amd64.yaml
   apiVersion: helm.crossplane.io/v1beta1
   kind: Release
   metadata:
     name: gitlab-runner-amd64
   spec:
     forProvider:
       chart:
         name: gitlab-runner
         repository: https://charts.gitlab.io/
         version: "0.78.1"
       namespace: gitlab-runner
       values:
         # Inherit all existing configuration from example-gitlab-runner.yaml
         nodeSelector:
           lifecycle: OnDemand
           karpenter.sh/nodepool: system-pool
           kubernetes.io/arch: amd64  # Add architecture constraint
         
         runners:
           tags: "scip-sandbox-amd64"  # Architecture-specific tag
           config: |
             [[runners]]
               [runners.kubernetes]
                 namespace = "{{.Release.Namespace}}"
                 image = "ubuntu:22.04"
                 privileged = false
                 [runners.kubernetes.pod_annotations]
                   "karpenter.sh/do-not-evict" = "true"
                   "eks.amazonaws.com/compute-type" = "ec2"
                 [runners.kubernetes.node_selector]
                   "karpenter.sh/nodepool" = "spot-pool"
                   "lifecycle" = "Ec2Spot"
                   "kubernetes.io/arch" = "amd64"  # Ensure jobs run on amd64
   ```

2. **ARM64 Runner Configuration**
   ```yaml
   # gitlab-runner-arm64.yaml
   apiVersion: helm.crossplane.io/v1beta1
   kind: Release
   metadata:
     name: gitlab-runner-arm64
   spec:
     forProvider:
       chart:
         name: gitlab-runner
         repository: https://charts.gitlab.io/
         version: "0.78.1"
       namespace: gitlab-runner
       values:
         # Inherit all existing configuration from example-gitlab-runner.yaml
         nodeSelector:
           lifecycle: OnDemand
           karpenter.sh/nodepool: system-pool
           kubernetes.io/arch: arm64  # Add architecture constraint
         
         runners:
           tags: "scip-sandbox-arm64"  # Architecture-specific tag
           config: |
             [[runners]]
               [runners.kubernetes]
                 namespace = "{{.Release.Namespace}}"
                 image = "ubuntu:22.04"
                 privileged = false
                 [runners.kubernetes.pod_annotations]
                   "karpenter.sh/do-not-evict" = "true"
                   "eks.amazonaws.com/compute-type" = "ec2"
                 [runners.kubernetes.node_selector]
                   "karpenter.sh/nodepool" = "spot-pool"
                   "lifecycle" = "Ec2Spot"
                   "kubernetes.io/arch" = "arm64"  # Ensure jobs run on arm64
   ```

#### Option B: Single Runner with Dynamic Architecture Selection

Alternative approach using your existing runner with architecture-specific pod templates:

```yaml
# Modified version of your existing gitlab-runner.yaml
apiVersion: helm.crossplane.io/v1beta1
kind: Release
metadata:
  name: gitlab-runner-multiarch
spec:
  forProvider:
    # ... existing chart configuration
    values:
      # ... existing values
      runners:
        tags: "scip-sandbox-amd64,scip-sandbox-arm64"  # Both tags
        config: |
          [[runners]]
            [runners.kubernetes]
              namespace = "{{.Release.Namespace}}"
              image = "ubuntu:22.04"
              privileged = false
              [runners.kubernetes.pod_annotations]
                "karpenter.sh/do-not-evict" = "true"
                "eks.amazonaws.com/compute-type" = "ec2"
              [runners.kubernetes.node_selector]
                "karpenter.sh/nodepool" = "spot-pool"
                "lifecycle" = "Ec2Spot"
                # Note: No architecture constraint here - let jobs specify
```

**Note:** This approach requires the spot-pool to support both architectures and relies on job-level architecture selection, which may be less reliable.

### Phase 3: Update Pipeline Configuration

Update `.gitlab-ci.yml` to use architecture-specific runner tags:

```yaml
# New CI/CD variables needed:
# - CICD_TAG_AMD64: scip-sandbox-amd64
# - CICD_TAG_ARM64: scip-sandbox-arm64

.build_template: &build_template
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:debug
    entrypoint: [""]
  # ... existing script content

build_arm64:
  <<: *build_template
  variables:
    ARCH: "arm64"
  tags:
    - $CICD_TAG_ARM64  # Uses arm64 runner

build_amd64:
  <<: *build_template
  variables:
    ARCH: "amd64"
  tags:
    - $CICD_TAG_AMD64  # Uses amd64 runner
```

### Phase 4: Update Existing Workloads for Continuity

Add explicit amd64 node selectors to existing workloads that currently rely on the amd64-only spot-pool:

1. **Argo Workflows**
   ```yaml
   # Add to workflow templates
   spec:
     nodeSelector:
       kubernetes.io/arch: amd64
   ```

2. **Other GitLab CI Jobs**
   ```yaml
   # Add to jobs that need amd64
   existing_job:
     tags:
       - $CICD_TAG_AMD64
   ```

## Implementation Steps

### Step 1: Infrastructure Changes
1. Update Karpenter node pool configuration to remove amd64 constraint
2. Deploy separate GitLab runners for amd64 and arm64
3. Register runners with GitLab with appropriate tags

### Step 2: Pipeline Updates
1. Add new CI/CD variables (`CICD_TAG_AMD64`, `CICD_TAG_ARM64`)
2. Update `.gitlab-ci.yml` to use architecture-specific tags
3. Test pipeline with both architectures

### Step 3: Existing Workload Migration
1. Add explicit amd64 node selectors to Argo Workflows
2. Update other GitLab CI pipelines to use `CICD_TAG_AMD64`
3. Validate no workloads are broken by the changes

### Step 4: Validation
1. Test kaniko-builder pipeline builds both architectures correctly
2. Verify existing workloads continue to run on amd64
3. Confirm new arm64 workloads can be scheduled

## Alternative Solutions Considered

### Option 1: Dynamic Runner Selection
Use GitLab's `parallel:matrix` feature to dynamically select runners:

```yaml
build:
  parallel:
    matrix:
      - ARCH: amd64
        RUNNER_TAG: $CICD_TAG_AMD64
      - ARCH: arm64
        RUNNER_TAG: $CICD_TAG_ARM64
  tags:
    - ${RUNNER_TAG}
```

**Pros:** Single job definition
**Cons:** More complex, harder to debug

### Option 2: Conditional Runner Selection
Use GitLab CI rules to select runners based on variables:

```yaml
.runner_amd64: &runner_amd64
  tags:
    - $CICD_TAG_AMD64

.runner_arm64: &runner_arm64
  tags:
    - $CICD_TAG_ARM64

build_amd64:
  <<: *build_template
  <<: *runner_amd64
  variables:
    ARCH: amd64
```

**Pros:** Clear separation, easy to understand
**Cons:** Requires separate job definitions (current approach)

## Recommended Approach

**Phase 1:** Implement Option A (Separate Runner Deployments) as it provides:
- Clear separation of concerns
- Easy debugging and monitoring
- Explicit architecture guarantees
- Minimal complexity

**Phase 2:** Consider Option B (Dynamic Selection) for future optimization if needed.

## Risk Mitigation

1. **Rollback Plan:** Keep existing amd64-only runner during transition
2. **Testing:** Validate on non-production environment first
3. **Monitoring:** Add alerts for runner availability and job failures
4. **Documentation:** Update all relevant documentation and runbooks

## Success Criteria

- [ ] ARM64 GitLab runner deployed and registered
- [ ] AMD64 GitLab runner explicitly configured with node selector
- [ ] Kaniko pipeline successfully builds both architectures in parallel
- [ ] Existing workloads continue to function on amd64
- [ ] New multi-arch images can be built and deployed
- [ ] No regression in build times or reliability
