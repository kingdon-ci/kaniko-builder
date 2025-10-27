# STERN_INTEGRATION_RESEARCH.md - Real-Time Log Streaming for hephy-builder

**Status**: Research Document - Defining Core User Experience  
**Purpose**: Design stern-based log aggregation for git push → build → deploy workflow  
**Context**: Based on MVP scope "Smart Build & Deploy Orchestration" (Q13)

## 🎯 **The Vision**

> *"I would be so happy if I could git push to a stern pipeline that knew when the build was in progress and when it was finished, and waited for the deployment to settle, and did so in an orderly fashion..."*

**Goal**: Real-time log streaming that follows the complete journey from `git push hephy main` to running application.

## 📊 **Stern Capabilities Analysis**

### **Core Stern Features**
```bash
# Multi-pod log tailing with label selectors
stern --selector app=hephy-build,build-id=abc123 --tail 50

# Architecture-specific filtering  
stern --selector app=hephy-build,arch=amd64 --color always

# Namespace and time-based filtering
stern --namespace hephy-builds --since 1h --timestamps
```

### **Label-Based Log Aggregation Strategy**
```yaml
# GitLab CI/GitHub Actions pods would be labeled:
metadata:
  labels:
    app: hephy-build
    build-id: "git-sha-abc123"
    arch: "amd64"  # or "arm64" 
    stage: "prepare" # "build", "manifest", "deploy"
    project: "my-app"
```

## 🌊 **User Experience Flow**

### **Phase 1: Git Push Experience**
```bash
user@laptop:~/my-app$ git push hephy main
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Writing objects: 100% (3/3), 286 bytes | 286.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
remote: 
remote: -----> hephy-builder received push (sha: abc123)
remote: -----> Triggering multi-arch build pipeline...
remote: -----> Following build logs:
remote: 
```

### **Phase 2: Build Log Streaming**
```bash
# stern starts following GitLab CI/GitHub Actions pods
remote: [prepare] 🔍 Detecting changed directories...
remote: [prepare] ✅ Found changes in: my-app/
remote: [prepare] 📊 Need builds: amd64=true, arm64=true
remote: 
remote: [build-amd64] 🏗️  Building linux/amd64 image...
remote: [build-arm64] 🏗️  Building linux/arm64 image...
remote: [build-amd64] ✅ Image built: my-app:abc123-amd64
remote: [build-arm64] ✅ Image built: my-app:abc123-arm64
remote: 
remote: [manifest] 📦 Creating multi-arch manifest...
remote: [manifest] ✅ Published: my-app:abc123
```

### **Phase 3: Deployment Transition**
```bash
remote: -----> Build complete! Triggering deployment...
remote: -----> Following deployment logs:
remote: 
remote: [deploy] 🚀 Applying Kubernetes manifests...
remote: [deploy] 📊 Waiting for rollout: deployment/my-app
remote: [deploy] ✅ Deployment ready (2/2 replicas)
remote: [deploy] 🌐 Service available at: https://my-app.example.com
remote: 
remote: -----> my-app deployed successfully! 🎉
```

## 🔧 **Technical Implementation**

### **Stern Configuration for hephy-builder**
```yaml
# .hephy/stern-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: hephy-stern-config
data:
  build-selector: "app=hephy-build,project={{.PROJECT}},build-id={{.BUILD_ID}}"
  deploy-selector: "app={{.PROJECT}},hephy-deploy=true"
  namespaces: "hephy-builds,hephy-apps"
  tail: "50"
  since: "1h"
  timestamps: true
  color: "always"
```

### **Git Server Integration**
```go
// Based on teamhephy/builder pattern
func streamBuildLogs(buildID, project string) error {
    // Start stern for build logs
    buildCmd := exec.Command("stern", 
        "--selector", fmt.Sprintf("app=hephy-build,project=%s,build-id=%s", project, buildID),
        "--namespace", "hephy-builds",
        "--tail", "50",
        "--timestamps")
    
    // Stream to SSH client
    buildCmd.Stdout = os.Stdout
    buildCmd.Stderr = os.Stderr
    
    return buildCmd.Run()
}

func streamDeployLogs(project string) error {
    // Transition to deployment logs
    deployCmd := exec.Command("stern",
        "--selector", fmt.Sprintf("app=%s,hephy-deploy=true", project),
        "--namespace", "hephy-apps", 
        "--tail", "20")
        
    deployCmd.Stdout = os.Stdout
    deployCmd.Stderr = os.Stderr
    
    return deployCmd.Run()
}
```

## 🎭 **Multi-Architecture Log Presentation**

### **Option A: Unified Stream with Architecture Labels**
```bash
remote: [build-amd64] Step 3/5 : COPY . /app
remote: [build-arm64] Step 3/5 : COPY . /app  
remote: [build-amd64] Successfully built abc123
remote: [build-arm64] Successfully built def456
remote: [manifest] Creating multi-arch manifest from abc123, def456
```

### **Option B: Sequential Architecture Builds**  
```bash
remote: -----> Building AMD64 image...
remote: [build] Step 1/5 : FROM golang:1.21
remote: [build] Successfully built abc123
remote: 
remote: -----> Building ARM64 image...
remote: [build] Step 1/5 : FROM golang:1.21
remote: [build] Successfully built def456
```

### **Option C: Architecture Summary** (RECOMMENDED)
```bash
remote: [build] 🏗️  Multi-arch build in progress...
remote: [build] ├── amd64: Building... ⏳
remote: [build] └── arm64: Building... ⏳
remote: [build] ├── amd64: Complete ✅ (2m 30s)
remote: [build] └── arm64: Complete ✅ (2m 45s)
remote: [manifest] 📦 Creating multi-arch manifest... ✅
```

## 🚦 **State Management & Orchestration**

### **Build State Detection**
```bash
# How stern knows when build transitions to deploy
# Option 1: Label-based state tracking
stern --selector "stage=build" | watch-for "build-complete"

# Option 2: Kubernetes events
stern --selector "app=hephy-orchestrator" | grep "BUILD_COMPLETE"

# Option 3: Custom hephy-orchestrator pod
stern hephy-orchestrator | parse-build-events
```

### **Orderly Progression Logic**
```yaml
# hephy-orchestrator state machine
build:
  prepare: ✅ (30s)
  build-amd64: ✅ (2m 30s) 
  build-arm64: ✅ (2m 45s)
  manifest: ✅ (15s)
  
deploy:
  trigger: ✅ (5s)
  rollout: ⏳ (waiting...)
  ready: ⏳ (waiting...)
```

## 🎯 **Success Criteria**

### **User Experience Goals**
- [ ] **Real-time feedback**: Logs stream immediately when build starts
- [ ] **Orderly progression**: Clear transition from build → deploy  
- [ ] **Multi-arch clarity**: Architecture differences clear but not overwhelming
- [ ] **Error handling**: Build failures clearly reported with actionable info
- [ ] **Completion feedback**: Clear success message with deployment URL

### **Technical Requirements**
- [ ] **stern integration**: Reliable pod selection and log streaming
- [ ] **State management**: Knows when to transition between phases
- [ ] **SSH connection**: Keeps connection alive during long builds
- [ ] **Error recovery**: Handles pod failures and restarts gracefully

## 🔍 **Research Questions for Next Week**

1. **Stern Multi-Namespace**: Can stern follow logs across multiple namespaces (builds → deployments)?
2. **Label Strategy**: What's the optimal Kubernetes label scheme for hephy-builder pods?
3. **State Transitions**: How should the git server know when build completes and deployment starts?
4. **SSH Keep-Alive**: How to maintain SSH connection during 5-10 minute builds?
5. **Error Presentation**: How should build failures appear in the log stream?

## 💡 **Implementation Priority**

### **Phase 1: Basic Stern Integration** (Next Week)
- Single-arch build log following with stern
- Simple state detection (build complete → deploy start)
- SSH connection management

### **Phase 2: Multi-Arch Enhancement** (Later)  
- Parallel build log aggregation
- Architecture-specific error handling
- Performance optimization

### **Phase 3: Production Polish** (Future)
- Advanced error recovery
- Build caching integration
- Performance monitoring

---

**This research defines the core user experience that makes hephy-builder magical - the seamless progression from `git push` to running application with real-time feedback throughout.**