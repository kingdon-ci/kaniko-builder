# Today's Kaniko Multi-Architecture Deployment Plan

## Objective
Deploy multi-architecture Kaniko building capability to sandbox cluster today without disrupting existing workloads.

## Strategy
1. **Add new `multiarch-spot` NodePool** alongside existing `spot-pool`
2. **Deploy architecture-specific GitLab runners** targeting the new pool
3. **Test multi-arch pipeline** with isolated workloads
4. **Leave existing consumers untouched** - they continue using `spot-pool`

## Phase 1: Infrastructure Changes

### 1.1 Create New NodePool Configuration

Based on `attic/crossplane-node-pool-objects.yaml`, we need to add a new NodePool resource to the Crossplane composition.

**New NodePool spec:**
```yaml
- name: eks-multiarch-spot-nodepool
  base:
    apiVersion: kubernetes.crossplane.io/v1alpha2
    kind: Object
    metadata:
      labels:
        role: eks-multiarch-spot-nodepool
    spec:
      forProvider:
        manifest:
          apiVersion: karpenter.sh/v1
          kind: NodePool
          metadata:
            name: multiarch-spot
            annotations:
              kubernetes.io/description: "Multi-architecture Spot NodePool for CI/CD builds"
          spec:
            disruption:
              consolidateAfter: 30s  # Faster consolidation for ephemeral builds
              consolidationPolicy: WhenEmpty
            template:
              metadata:
                labels:
                  lifecycle: Ec2Spot
                  intent: cicd-builds
                  aws.amazon.com/spot: "true"
                spec:
                  # Taint to prevent non-CI workloads from scheduling here
                  taints:
                    - key: cicd-builds
                      value: "true"
                      effect: NoSchedule
                  nodeClassRef:
                    group: eks.amazonaws.com
                    kind: NodeClass
                    name: eks-nodeclass
                  requirements:
                    - key: "karpenter.sh/capacity-type"
                      operator: In
                      values: ["spot"]
                    - key: "eks.amazonaws.com/instance-category"
                      operator: In
                      values: ["c", "m", "r"]
                    - key: "eks.amazonaws.com/instance-cpu"
                      operator: Gt
                      values: ["1"]
                    - key: "topology.kubernetes.io/zone"
                      operator: In
                      values: ["patch-me"]
                    - key: "kubernetes.io/arch"
                      operator: In
                      values: ["amd64", "arm64"]  # KEY DIFFERENCE: Both architectures
            limits:
              cpu: "32"   # Smaller limit for focused CI usage
              memory: 64Gi
  patches:
  - type: PatchSet
    patchSetName: common-parameters
  - type: FromCompositeFieldPath
    fromFieldPath: spec.resourceConfig.region
    toFieldPath: spec.forProvider.manifest.spec.template.spec.requirements[3].values[0]
    transforms:
      - type: string
        string:
          fmt: "%sa"  # Use az 'a' in region

- name: eks-multiarch-spot-nodepool-uses-cluster
  base:
    apiVersion: apiextensions.crossplane.io/v1beta1
    kind: Usage
    spec:
      replayDeletion: true
      of:
        apiVersion: eks.aws.upbound.io/v1beta1
        kind: ClusterAuth
        resourceSelector:
          matchControllerRef: true
          matchLabels:
            role: eks-cluster-auth
      by:
        apiVersion: kubernetes.crossplane.io/v1alpha2
        kind: Object
        resourceSelector:
          matchControllerRef: true
          matchLabels:
            role: eks-multiarch-spot-nodepool
```

**Action Required:** Add this to the Crossplane composition in your cluster GitOps repo.

### 1.2 Update GitLab Runner Configurations

**Update `attic/gitlab-runner-amd64.yaml`:**
```yaml
# Change the node selector and add toleration
runners:
  tags: "scip-sandbox-amd64"
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
          "karpenter.sh/nodepool" = "multiarch-spot"  # Changed from spot-pool
          "lifecycle" = "Ec2Spot"
          "kubernetes.io/arch" = "amd64"
        [runners.kubernetes.node_tolerations]
          "cicd-builds=true" = "NoSchedule"
```

**Update `attic/gitlab-runner-arm64.yaml`:**
```yaml
# Same changes but for arm64
runners:
  tags: "scip-sandbox-arm64"
  config: |
    [[runners]]
      [runners.kubernetes]
        # ... same base config as amd64
        [runners.kubernetes.node_selector]
          "karpenter.sh/nodepool" = "multiarch-spot"  # Changed from spot-pool
          "lifecycle" = "Ec2Spot"
          "kubernetes.io/arch" = "arm64"
        [runners.kubernetes.node_tolerations]
          "cicd-builds=true" = "NoSchedule"
```

## Phase 2: Deployment Sequence

### 2.1 Infrastructure Deployment
1. **Submit PR to cluster GitOps repo** with new NodePool configuration
2. **Wait for Crossplane reconciliation** (~5-10 minutes)
3. **Verify NodePool exists:** Check that `multiarch-spot` NodePool is created

### 2.2 Runner Deployment
1. **Submit PR to runner GitOps repo** with updated runner configurations
2. **Wait for runner deployment** (~10-15 minutes)
3. **Verify runners registered:** Check GitLab UI shows both architecture-specific runners

### 2.3 Pipeline Testing
1. **Configure GitLab CI variables** (see DEPLOYMENT.md prerequisites)
2. **Trigger test build** (see DEPLOYMENT.md Phase 1)
3. **Monitor pipeline execution** (see DEPLOYMENT.md Phase 2)

## Phase 3: Validation

### 3.1 Success Criteria
- [ ] `multiarch-spot` NodePool created and available
- [ ] Both AMD64 and ARM64 runners show as "online" in GitLab
- [ ] Test pipeline successfully builds both architectures
- [ ] Multi-arch manifest created and pushed to ECR
- [ ] **Existing workloads continue using `spot-pool` unchanged**

### 3.2 Monitoring Points
```bash
# Check NodePool status (via kubectl on target cluster)
kubectl get nodepool multiarch-spot -o yaml

# Verify runners are healthy
kubectl get pods -n gitlab-runner -l app=gitlab-runner-amd64
kubectl get pods -n gitlab-runner -l app=gitlab-runner-arm64

# Monitor node provisioning during first build
kubectl get nodes -l karpenter.sh/nodepool=multiarch-spot --watch
```

## Risk Mitigation

### Isolation Benefits
- **Taints prevent interference:** Other workloads can't accidentally use our nodes
- **Separate NodePool:** No impact on existing `spot-pool` consumers
- **Independent scaling:** Our builds don't compete for existing capacity

### Rollback Plan
1. **Disable runners:** Scale runner deployments to 0 replicas
2. **Remove NodePool:** Delete from Crossplane composition
3. **Revert to existing setup:** Use current runners for critical builds

### Emergency Procedures
- **Pipeline failures:** Refer to DEPLOYMENT.md troubleshooting section
- **Node provisioning issues:** Check Karpenter logs and instance availability
- **Runner connectivity:** Verify GitLab registration tokens and network access

## Timeline

- **NodePool deployment:** 10 minutes (Crossplane reconciliation)
- **Runner deployment:** 15 minutes (Helm + registration)
- **First pipeline test:** 20 minutes (multi-arch build)
- **Total deployment window:** ~45 minutes
- **Full validation:** 1 hour

## Post-Deployment

Once validated:
1. **Document success:** Update relevant team channels
2. **Monitor usage:** Track node utilization and build performance
3. **Plan migration:** Consider moving other CI workloads to `multiarch-spot`
4. **Future cleanup:** Eventually deprecate `spot-pool` when all consumers migrate

## Key Differences from Existing Setup

| Aspect | Current `spot-pool` | New `multiarch-spot` |
|--------|-------------------|---------------------|
| Architecture | AMD64 only | AMD64 + ARM64 |
| Access | Open (no taints) | Restricted (tainted) |
| Purpose | General workloads | CI/CD builds only |
| Consumers | Multiple existing | Kaniko builds only |
| Disruption | Affects others | Isolated |

This approach provides a clean migration path without disrupting existing workloads while enabling our multi-architecture build requirements.