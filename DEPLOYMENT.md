# Deployment Guide

This document provides instructions for deploying and testing the kaniko-builder pipeline.

## Prerequisites

Before deploying this pipeline, ensure you have:

1. **GitLab CI/CD Variables configured:**
   - `ECR_REGISTRY`: Your ECR registry URL (e.g., `123456789.dkr.ecr.us-east-1.amazonaws.com/your-repo`)
   - `CICD_TAG_AMD64`: Runner tag for amd64 builds (e.g., `scip-sandbox-amd64`)
   - `CICD_TAG_ARM64`: Runner tag for arm64 builds (e.g., `scip-sandbox-arm64`)
   - `CICD_TAG`: Legacy runner tag for prepare stage (can use either architecture)

2. **GitLab Runners:**
   - **AMD64 Runner**: Deployed with `scip-sandbox-amd64` tag, node selector for amd64
   - **ARM64 Runner**: Deployed with `scip-sandbox-arm64` tag, node selector for arm64
   - ECR authentication configured (ecr-login credential helper)
   - Docker-in-Docker or Kaniko support
   - **Note**: See `IMPLEMENTATION_PLAN.md` for runner deployment details

3. **ECR Repository:**
   - ECR repository created and accessible
   - Proper IAM permissions for push/pull operations

## Testing the Pipeline

### Phase 1: Test Basic Functionality

1. **Create a test branch:**
   ```bash
   git checkout -b test-kaniko-build
   ```

2. **Make a small change to trigger the pipeline:**
   ```bash
   echo "# Test change" >> kaniko/README.md
   git add kaniko/README.md
   git commit -m "Test: trigger kaniko build"
   git push origin test-kaniko-build
   ```

3. **Create a merge request** to main branch and observe the pipeline execution.

### Phase 2: Test Multi-Architecture Support

1. **Monitor the pipeline stages:**
   - `prepare`: Should detect the `kaniko` directory
   - `build_arm64`: Should build Kaniko for arm64
   - `build_amd64`: Should build Kaniko for amd64
   - `manifest`: Should create multi-arch manifest

2. **Verify the built images:**
   ```bash
   # Check if images exist in ECR
   aws ecr describe-images --repository-name your-repo --region us-east-1
   ```

### Phase 3: Test Second Project

1. **Trigger curl build:**
   ```bash
   echo "# Test curl build" >> curl/README.md
   git add curl/README.md
   git commit -m "Test: trigger curl build"
   git push origin test-kaniko-build
   ```

2. **Verify both projects build in parallel**

### Phase 4: Test Scheduled Builds

1. **Configure a scheduled pipeline** in GitLab CI/CD settings
2. **Verify it uses `rebuild-weekly.txt`** to build all projects

## Expected Output

### Successful Pipeline Results

After a successful pipeline run, you should have:

1. **Kaniko Images:**
   - `kaniko-YYYYMMDD-{commit-sha}`
   - `kaniko-v1.25.3`
   - `kaniko-latest`

2. **Curl Images:**
   - `curl-YYYYMMDD-{commit-sha}`
   - `curl-latest`
   - `curl-test`

3. **Multi-arch Support:**
   - Each image should support both `linux/amd64` and `linux/arm64`
   - Automatic architecture selection when pulling

### Testing Multi-arch Images

```bash
# Test pulling on different architectures
docker pull $ECR_REGISTRY:kaniko-latest
docker inspect $ECR_REGISTRY:kaniko-latest | grep Architecture

# Should show the correct architecture for your platform
```

## Troubleshooting

### Common Issues

1. **ECR Authentication Failures:**
   - Verify ECR credentials are configured on runners
   - Check IAM permissions for ECR operations

2. **Architecture-specific Build Failures:**
   - Ensure runners support the target architecture
   - Verify correct runner tags are configured (`CICD_TAG_AMD64`, `CICD_TAG_ARM64`)
   - Check if upstream Dockerfile supports multi-arch builds
   - Confirm Karpenter can provision nodes of the requested architecture

3. **Runner Scheduling Issues:**
   - Verify architecture-specific runners are deployed and registered
   - Check node selectors are correctly configured
   - Ensure spot-pool supports both amd64 and arm64 nodes

4. **Manifest Creation Failures:**
   - Verify both architecture builds completed successfully
   - Check manifest-tool has proper ECR access

5. **prepare_diff.sh Failures:**
   - Ensure script has execute permissions
   - Check git history is available in the pipeline

### Debug Commands

```bash
# Check pipeline artifacts
ls -la *.tag *.tags

# Verify ECR authentication
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REGISTRY

# Test manifest-tool locally
manifest-tool inspect $ECR_REGISTRY:kaniko-latest

# Check GitLab runner registration and tags
kubectl get pods -n gitlab-runner -o wide
kubectl logs -n gitlab-runner deployment/gitlab-runner-amd64
kubectl logs -n gitlab-runner deployment/gitlab-runner-arm64

# Verify node architecture availability
kubectl get nodes -o wide --show-labels | grep kubernetes.io/arch
```

## Next Steps

After successful deployment:

1. **Add more projects** by creating new directories with `build-config.yaml`
2. **Configure scheduled rebuilds** for security updates
3. **Set up monitoring** for build failures
4. **Consider caching strategies** for faster builds

## Success Criteria Checklist

- [ ] Can build Kaniko v1.25.3 for arm64
- [ ] Can build Kaniko v1.25.3 for amd64
- [ ] Multi-arch manifest created and pushed
- [ ] Can build curl project with a Dockerfile
- [ ] Images pushed to ECR with proper tags
- [ ] Pipeline triggered on merge to main
- [ ] Documentation explains how to add new projects

## Performance Notes

- **Build Time**: Expect 10-20 minutes per architecture for Kaniko
- **Parallel Execution**: arm64 and amd64 builds run in parallel
- **Resource Usage**: Each build requires ~2GB RAM, 2 CPU cores
- **Storage**: Each image ~100-500MB depending on the project
