# Sunkworks Episode 80: hephy-builder Vision Interview Questions

**Format**: Transcription-friendly Q&A for 15-minute workshop sessions  
**Goal**: Define complete hephy-builder architecture and implementation roadmap  
**Episode Structure**: Workshop → Deep dive → Public plan

---

## 🎬 **Pre-Interview Workshop Questions** (15 minutes)

### **Round 1: Heritage & Core Vision**
**Q1**: Walk me through the original `git push deis main` experience from a developer's perspective. What did you see on your terminal from hitting enter to your app being live?

**Q2**: What was the "magic moment" in that workflow? The thing that made developers love it compared to traditional deployment?

**Q3**: In 2025, what would be the equivalent user experience? What stays the same, what needs to change?

---

### **Round 2: Technical Architecture Deep Dive**
**Q4**: How did the original Deis git server work? Was it a custom implementation or stock git with hooks?

**Q5**: For multi-arch builds, how should the developer experience work? Do they see two parallel log streams, one unified stream, or something else?

**Q6**: What's the modern equivalent of the Deis Controller? Do we rebuild it, use FluxCD, or something hybrid?

---

### **Round 3: Scope & Implementation Strategy**
**Q7**: Where do we draw the line? Are we building just the git-push-to-build experience, or the full PaaS (databases, routing, etc.)?

**Q8**: How does hephy-builder relate to existing solutions like Heroku, Railway, Fly.io? Are we competing or complementing?

**Q9**: What's the minimal viable "git push hephy main" that would make developers excited?

---

## 🔧 **Interview Questions Bank** (30-minute deep dive)

### **Heritage & Evolution**
- What were the key components of Deis Workflow? (Controller, Builder, Router, etc.)
- How did the transition from Deis v1 (Fleet) to Deis Workflow (Kubernetes) inform our approach?
- What lessons from the Deis acquisition and CNCF donation should we apply?
- How did buildpacks evolve into containers, and what's the next evolution?

### **Git Server Implementation**
- How did Deis handle SSH key management and authentication?
- What was the post-receive hook implementation pattern?
- How did build logs stream back through the SSH connection in real-time?
- How should we handle timeout scenarios for long builds?
- What's the modern equivalent using GitLab CI or GitHub Actions?

### **Multi-Architecture Challenges**
- How do we present parallel AMD64/ARM64 builds to the user?
- Should architecture differences be highlighted or hidden?
- How do we handle cases where one architecture fails but the other succeeds?
- What's the user experience for architecture-specific debugging?

### **Backend Selection Strategy**
- Should backend selection be automatic (Go → Ko) or explicit configuration?
- How do we handle migration between backends (Kaniko → Ko)?
- What's the configuration format for backend-specific options?
- How do we validate backend compatibility with the project?

### **Deployment Integration**
- How does the build complete → deployment flow work?
- What's our relationship with FluxCD vs rebuilding Deis Controller?
- How do we handle rollbacks and deployment history?
- What about blue-green deployments and traffic splitting?

### **Platform Portability**
- Should the same config work identically on GitLab CI and GitHub Actions?
- How do we handle platform-specific features and limitations?
- What's the story for self-hosted Git/CI environments?
- How do we make the git server work with both platforms?

### **CLI Design**
- What commands should `hephy` support? (logs, config, deploy, etc.)
- How does the CLI integrate with the git workflow?
- What's the relationship between `git push hephy main` and `hephy deploy`?
- How do we handle authentication and configuration?

### **Scope & Positioning**
- Are we building a complete PaaS or just the build/deploy layer?
- How do we handle databases, secrets, environment management?
- What's our story for production vs development environments?
- How do we scale from hobby projects to enterprise use?

### **Implementation Priorities**
- What's the MVP that would make this useful immediately?
- Which backend should we implement first (Ko, Spin, BuildKit)?
- What's the order of platform support (GitLab first, then GitHub)?
- How do we maintain backward compatibility with kaniko-builder?

### **Community & Adoption**
- How do we onboard contributors to this vision?
- What's the migration path for existing Deis/Hephy users?
- How do we build momentum without overwhelming the project?
- What examples and tutorials make the vision concrete?

---

## 🎯 **Workshop Session Structure**

### **15-Minute Iteration Format**
1. **Present 3 questions** from current round
2. **Transcribe responses** with your tool
3. **Quick clarification** on key points
4. **Note follow-up questions** for deep dive
5. **Move to next round** or iterate on unclear areas

### **Between-Session Processing**
- AI enhancement of transcription for clarity
- Architectural decision extraction
- Question refinement for next round
- Visual aid preparation (diagrams, examples)

### **30-Minute Deep Dive Prep**
- **Focus areas** identified from workshop
- **Visual materials** prepared (architecture diagrams)
- **Example scenarios** ready for discussion
- **Technical details** prioritized by importance

---

## 📝 **Output Targets for Public Plan**

### **Immediate Deliverables**
- **ARCHITECTURE_VISION.md**: Complete technical architecture
- **DEVELOPER_EXPERIENCE_SPEC.md**: Detailed "git push hephy main" workflow
- **IMPLEMENTATION_ROADMAP.md**: Phased development plan
- **MVP_DEFINITION.md**: Minimal viable product scope

### **GitHub Issues Generation**
- **Epic issues** for major components (git server, CLI, backends)
- **Research tasks** for unclear technical areas
- **Implementation tickets** with clear acceptance criteria
- **Community tasks** for documentation and examples

### **Community Artifacts**
- **Architecture diagrams** showing component relationships
- **Comparison charts** (backends, platforms, existing solutions)
- **Example workflows** demonstrating the vision
- **Contributor onboarding** guides and quick-start tutorials

---

**Ready for the workshop sessions! 🚀**