# GIT_SERVER_ARCHITECTURE.md - Modern Git-Receive Hook Design

**Status**: Architecture Design - Foundation Component  
**Purpose**: Define git server that orchestrates stern + CI/CD for "git push hephy main"  
**Reference**: Based on teamhephy/builder gitreceive/run.go pattern

## 🎯 **Architecture Overview**

### **Core Components**
```
Git Push Flow:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   git push  │───▶│ Git Server  │───▶│   CI/CD     │───▶│ Deployment  │
│ hephy main  │    │   + stern   │    │ (GitLab/GH) │    │ + Logs      │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                          │                   │                  │
                          ▼                   ▼                  ▼
                   SSH Connection      Build Logs        Deploy Logs
                   (Keep Alive)       (stern follow)    (stern follow)
```

## 🏗️ **Git Server Implementation**

### **Base Structure (Go Implementation)**
```go
// pkg/gitserver/server.go
package gitserver

import (
    "bufio"
    "context" 
    "fmt"
    "os"
    "os/exec"
    "strings"
    "time"
    
    "github.com/kingdon-ci/hephy-builder/pkg/ci"
    "github.com/kingdon-ci/hephy-builder/pkg/stern"
)

type GitServer struct {
    config    *Config
    ciTrigger ci.Trigger    // GitLab CI or GitHub Actions
    sternMgr  *stern.Manager
}

// Main git-receive hook entry point
func (gs *GitServer) Run() error {
    scanner := bufio.NewScanner(os.Stdin)
    for scanner.Scan() {
        line := scanner.Text()
        oldRev, newRev, refName, err := parseLine(line)
        if err != nil {
            return fmt.Errorf("parsing git input: %w", err)
        }
        
        // Check if this is a receive-pack (git push)
        if strings.HasPrefix(os.Getenv("SSH_ORIGINAL_COMMAND"), "git-receive-pack") {
            return gs.handlePush(oldRev, newRev, refName)
        }
    }
    return scanner.Err()
}
```

### **Push Handler with Stern Integration**
```go
func (gs *GitServer) handlePush(oldRev, newRev, refName string) error {
    project := gs.extractProject()
    buildID := newRev[:8] // Short SHA for build ID
    
    fmt.Printf("-----> hephy-builder received push (sha: %s)\n", buildID)
    fmt.Printf("-----> Triggering multi-arch build pipeline...\n")
    
    // 1. Trigger CI/CD build
    build, err := gs.ciTrigger.StartBuild(ci.BuildRequest{
        Project:   project,
        SHA:       newRev,
        Branch:    refName,
        BuildID:   buildID,
    })
    if err != nil {
        return fmt.Errorf("triggering build: %w", err)
    }
    
    // 2. Start stern log following
    fmt.Printf("-----> Following build logs:\n\n")
    err = gs.followBuildLogs(build.ID, project)
    if err != nil {
        return fmt.Errorf("following build logs: %w", err)
    }
    
    // 3. Wait for build completion
    err = gs.waitForBuildComplete(build.ID)
    if err != nil {
        return fmt.Errorf("build failed: %w", err)
    }
    
    // 4. Trigger deployment  
    fmt.Printf("-----> Build complete! Triggering deployment...\n")
    deploy, err := gs.triggerDeployment(project, buildID)
    if err != nil {
        return fmt.Errorf("triggering deployment: %w", err)
    }
    
    // 5. Follow deployment logs
    fmt.Printf("-----> Following deployment logs:\n\n")
    err = gs.followDeployLogs(deploy.ID, project)
    if err != nil {
        return fmt.Errorf("following deploy logs: %w", err)
    }
    
    // 6. Success message
    fmt.Printf("-----> %s deployed successfully! 🎉\n", project)
    return nil
}
```

## 🌊 **Stern Integration Layer**

### **Log Following Strategy**
```go
// pkg/stern/manager.go
package stern

import (
    "context"
    "os/exec"
    "time"
)

type Manager struct {
    namespace string
    config    *Config
}

func (sm *Manager) FollowBuildLogs(ctx context.Context, buildID, project string) error {
    selector := fmt.Sprintf("app=hephy-build,project=%s,build-id=%s", project, buildID)
    
    cmd := exec.CommandContext(ctx, "stern",
        "--selector", selector,
        "--namespace", sm.namespace,
        "--tail", "50",
        "--timestamps",
        "--color", "always")
    
    // Stream directly to SSH client
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr
    
    return cmd.Run()
}

func (sm *Manager) FollowDeployLogs(ctx context.Context, deployID, project string) error {
    selector := fmt.Sprintf("app=%s,hephy-deploy=true", project)
    
    cmd := exec.CommandContext(ctx, "stern",
        "--selector", selector, 
        "--namespace", "hephy-apps",
        "--tail", "20",
        "--since", "30s") // Only recent deploy logs
        
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr
    
    return cmd.Run()
}
```

## 🔗 **CI/CD Integration Layer**

### **GitLab CI Trigger**
```go
// pkg/ci/gitlab.go
package ci

import (
    "encoding/json"
    "fmt"
    "net/http"
)

type GitLabTrigger struct {
    baseURL string
    token   string
    project string
}

func (gt *GitLabTrigger) StartBuild(req BuildRequest) (*Build, error) {
    // Trigger GitLab CI pipeline with variables
    variables := map[string]string{
        "HEPHY_BUILD_ID": req.BuildID,
        "HEPHY_PROJECT":  req.Project,
        "HEPHY_SHA":      req.SHA,
    }
    
    pipeline, err := gt.triggerPipeline(req.SHA, variables)
    if err != nil {
        return nil, err
    }
    
    return &Build{
        ID:       fmt.Sprintf("%d", pipeline.ID),
        Project:  req.Project,
        SHA:      req.SHA,
        Status:   "running",
    }, nil
}
```

### **GitHub Actions Trigger**
```go
// pkg/ci/github.go  
package ci

import (
    "context"
    "github.com/google/go-github/v45/github"
)

type GitHubTrigger struct {
    client *github.Client
    owner  string
    repo   string
}

func (gh *GitHubTrigger) StartBuild(req BuildRequest) (*Build, error) {
    // Trigger workflow dispatch
    inputs := map[string]interface{}{
        "build_id": req.BuildID,
        "project":  req.Project,
        "sha":      req.SHA,
    }
    
    _, err := gh.client.Actions.CreateWorkflowDispatchEvent(
        context.Background(),
        gh.owner,
        gh.repo,
        "hephy-build.yml",
        github.CreateWorkflowDispatchEventRequest{
            Ref:    req.SHA,
            Inputs: inputs,
        })
    
    return &Build{
        ID:      req.BuildID,
        Project: req.Project, 
        SHA:     req.SHA,
        Status:  "running",
    }, err
}
```

## ⏰ **State Management & Waiting**

### **Build Completion Detection**
```go
func (gs *GitServer) waitForBuildComplete(buildID string) error {
    timeout := time.After(30 * time.Minute) // Max build time
    ticker := time.NewTicker(10 * time.Second)
    defer ticker.Stop()
    
    for {
        select {
        case <-timeout:
            return fmt.Errorf("build timeout after 30 minutes")
            
        case <-ticker.C:
            status, err := gs.ciTrigger.GetBuildStatus(buildID)
            if err != nil {
                continue // Keep trying
            }
            
            switch status.Status {
            case "success":
                return nil
            case "failed":
                return fmt.Errorf("build failed: %s", status.Error)
            case "canceled":
                return fmt.Errorf("build canceled")
            // "running" - continue waiting
            }
        }
    }
}
```

### **SSH Connection Keep-Alive**
```go
// pkg/ssh/keepalive.go
func KeepSSHAlive(ctx context.Context) {
    ticker := time.NewTicker(30 * time.Second)
    defer ticker.Stop()
    
    for {
        select {
        case <-ctx.Done():
            return
        case <-ticker.C:
            // Send SSH keep-alive
            fmt.Fprintf(os.Stderr, "\x00") // Null byte keep-alive
        }
    }
}
```

## 🚀 **Deployment Integration**

### **FluxCD Integration Pattern**
```go
func (gs *GitServer) triggerDeployment(project, buildID string) (*Deployment, error) {
    // Update GitOps repository with new image tags
    return gs.updateGitOpsRepo(project, buildID)
}

func (gs *GitServer) updateGitOpsRepo(project, buildID string) (*Deployment, error) {
    // Clone gitops repository
    // Update image tags in Kubernetes manifests
    // Commit and push changes
    // FluxCD will detect and deploy automatically
    
    manifest := fmt.Sprintf(`
apiVersion: apps/v1
kind: Deployment
metadata:
  name: %s
spec:
  template:
    spec:
      containers:
      - name: app
        image: %s:%s
`, project, gs.config.Registry, buildID)
    
    return &Deployment{
        ID:      buildID,
        Project: project,
        Status:  "deploying",
    }, nil
}
```

## 📦 **Configuration & Setup**

### **Server Configuration**
```yaml
# config/gitserver.yaml
gitserver:
  listen_address: "0.0.0.0:2222"
  host_key_path: "/etc/ssh/hephy_host_key"
  authorized_keys_path: "/etc/ssh/authorized_keys"
  
ci:
  platform: "gitlab" # or "github"
  gitlab:
    base_url: "https://gitlab.com"
    project_id: "12345"
    token: "${GITLAB_TOKEN}"
  github:
    owner: "kingdon-ci"
    repo: "hephy-apps"
    token: "${GITHUB_TOKEN}"
    
stern:
  namespace: "hephy-builds"
  deploy_namespace: "hephy-apps"
  
deployment:
  strategy: "fluxcd" # or "direct"
  gitops_repo: "git@github.com:company/gitops.git"
```

### **Kubernetes Deployment**
```yaml
# k8s/gitserver.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hephy-gitserver
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hephy-gitserver
  template:
    metadata:
      labels:
        app: hephy-gitserver
    spec:
      containers:
      - name: gitserver
        image: kingdon-ci/hephy-gitserver:latest
        ports:
        - containerPort: 2222
        env:
        - name: GITLAB_TOKEN
          valueFrom:
            secretKeyRef:
              name: hephy-secrets
              key: gitlab-token
        volumeMounts:
        - name: ssh-keys
          mountPath: /etc/ssh
          readOnly: true
      volumes:
      - name: ssh-keys
        secret:
          secretName: hephy-ssh-keys
```

## 🎯 **Success Criteria**

### **Core Functionality**
- [ ] **Git push reception**: Handles `git push hephy main` correctly
- [ ] **CI/CD triggering**: Starts GitLab CI or GitHub Actions builds
- [ ] **Log streaming**: stern follows build logs in real-time
- [ ] **State management**: Knows when build completes, deployment starts
- [ ] **SSH keep-alive**: Maintains connection during long operations

### **User Experience**
- [ ] **Real-time feedback**: User sees logs immediately 
- [ ] **Orderly progression**: Clear transition from build → deploy
- [ ] **Error handling**: Clear error messages for failures
- [ ] **Success confirmation**: Deployment URL provided on completion

## 🔧 **Implementation Phases**

### **Phase 1: Basic Git Server** (Next Week)
- SSH server accepting git pushes
- Simple CI/CD trigger (GitLab CI webhook)
- Basic stern log following

### **Phase 2: Full Integration** (Following Week)
- State management and waiting logic
- Deployment triggering and monitoring
- Error handling and recovery

### **Phase 3: Production Polish** (Later)
- Multi-project support
- Advanced configuration
- Monitoring and observability

---

**This architecture provides the foundation for the complete "git push hephy main" experience, orchestrating modern CI/CD with real-time log feedback.**