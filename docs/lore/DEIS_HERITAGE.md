# DEIS_HERITAGE.md - The Story That Brought Us Here

**Status**: Heritage Document - The Vision  
**Purpose**: Connect hephy-builder to the legacy of simple, powerful PaaS

## 🏛️ **The Golden Age of Simple Deployment**

### **When "Git Push" Just Worked**
Back in the day, there was magic in the air. You could take any application, any language, any framework—and deploy it to production with three words:

```bash
git push deis main
```

That was it. No YAML configuration files. No pipeline definitions. No multi-stage Docker builds. No Kubernetes manifests. Just **git push**, and your application was running in the cloud, load-balanced, scaled, and monitored.

**This was Deis Workflow.** And it was *glorious*.

## 🌊 **The Orchestration Wars**

### **The Uncertainty**
In those days (2014-2017), the container orchestration landscape was a battlefield. We had choices, and **nobody knew which one would win**:

- **Fleet + systemd**: CoreOS's distributed init system
- **Kubernetes**: Google's container orchestrator (still young)
- **Mesos + Marathon**: Apache's resource manager
- **Docker Swarm**: Docker's native clustering
- **Nomad**: HashiCorp's workload orchestrator

### **Deis Made the Bold Choice**
Deis v1 ran on **CoreOS + Fleet**, orchestrating Docker containers with systemd units distributed across a cluster. It worked! But the writing was on the wall—**Kubernetes was the future**.

So Deis evolved. **Deis Workflow** was rebuilt on Kubernetes, keeping the elegant developer experience while gaining the power of the emerging orchestration standard.

### **The Complete Stack**
Deis Workflow wasn't just a build system. It was a **complete Platform-as-a-Service**:

- **deis-store**: In-cluster distributed storage (Ceph)
- **hephy-postgres**: Failover-capable databases with WAL-E backup
- **deis-router**: Load balancing and SSL termination
- **deis-builder**: Git-triggered container builds
- **deis-logger**: Centralized log aggregation
- **deis-monitor**: Metrics and alerting

**You got Heroku in a box.** Complete. Self-contained. No vendor lock-in.

## 🏗️ **The Great Unbundling**

### **Cloud Services Changed Everything**
As public cloud matured, the economics shifted. Why run your own storage cluster when you could use **AWS S3**? Why manage your own databases when you had **AWS RDS** with automated backups? Why build your own load balancer when **AWS ALB** integrated with Kubernetes ingress?

The industry started **opportunistically offloading** services to cloud providers:
- **Storage**: S3, Azure Blob, Google Cloud Storage
- **Databases**: RDS, Cloud SQL, Azure Database
- **Networking**: Cloud load balancers, managed ingress
- **Monitoring**: CloudWatch, Datadog, New Relic

### **The False Victory**
Piece by piece, Deis Workflow components became "unnecessary":
- *"Just use S3!"*
- *"Just use RDS!"*  
- *"Just use ingress controllers!"*
- *"Just use Prometheus!"*

Soon, people said: **"We don't need Deis Workflow anymore!"**

## 💔 **What We Lost**

### **The Core Problem Was Never Solved**
Yes, we could offload storage. Yes, we could use managed databases. Yes, cloud load balancers were better than running our own.

**But we never solved the core problem again.**

Users **still wanted** a consistent interface to develop their applications using "git ops." They didn't care if that meant:
- CI gets invoked
- Flux CD handles deployment  
- Some combination of both
- Magic container fairies

**They just wanted their app running in the cloud** with the same elegant simplicity.

### **The Complexity Explosion**
Instead of `git push deis main`, deployment became:
1. Write Dockerfile (or multiple)
2. Configure CI pipeline (GitLab CI, GitHub Actions, Jenkins)
3. Set up multi-arch builds
4. Configure image registries
5. Write Kubernetes manifests
6. Set up GitOps deployment (Flux, ArgoCD)
7. Configure monitoring and logging
8. Set up ingress and SSL certificates
9. **Pray it all works together**

**We lost the magic.** We gained power, but lost simplicity.

## 🔥 **The Deis Legacy**

### **The Microsoft Acquisition** 
In 2017, Microsoft acquired the Deis team. They wanted the Kubernetes expertise to build **Azure Container Service** (later AKS). The team responsibly **donated Helm to the CNCF** (now approaching Helm v4), but **EOL'd Deis Workflow**.

### **The Great Mourning**
Everyone cried for a while, because **all of the users loved Workflow**. The problem wasn't technical—it was economic. **Nobody wanted to pay for it** (and Microsoft certainly didn't want to pay for it). 

The codebase was "donated" to the commons, changing from Apache license to MIT license, which was interpreted to mean: **"do what you want, just don't call yourself Deis."**

### **Team Hephy: The Community Continues**
So **Team Hephy** formed and carried on the work of maintenance—until we could not any longer.

### **The Grandfather's Axe Problem**
At around **Kubernetes 1.25**, the Docker shim was finally removed from Kubernetes upstream. The old deis-designed **"dockerbuilder" became unusable**. Similarly, **registry-proxy** depended on having a local Docker runtime—which was now going to be extremely unlikely on any Kubernetes cluster.

With the **builder and runner** being near to the only original parts left, and the builder ailing and in need of replacement, we were left with a **"grandfather's axe" problem**.

*If I use the axe for many years, but then replace the handle, and eventually after many more years, the blade is also worn and honed and worn and honed, until it can't be honed anymore, and is in need of replacement—is it still my grandfather's axe that he passed down to me?*

*(Is the answer any different if my grandfather himself also replaced the handle and the blade, of the axe that was passed down to him?)*

### **The Scattered Ecosystem**
Meanwhile, the container ecosystem exploded in complexity:
- **Build systems**: Docker, Kaniko, BuildKit, Ko, Spin
- **CI platforms**: GitHub Actions, GitLab CI, Jenkins, CircleCI
- **Deployment tools**: Helm, Kustomize, Flux, ArgoCD
- **Runtimes**: Docker, containerd, CRI-O, gVisor, Firecracker, WebAssembly

**Every tool solved one piece brilliantly.** None solved the whole problem simply.

## 🚀 **The Hephy Builder Vision**

### **Resurrect "Git Push Deis Main" with Modern Tooling**
What if we could resurrect that elegant simplicity with modern tooling? What if we could give developers the **best tool for each job** while maintaining the **one-command deployment experience** that made Deis magical?

### **The Rube Goldberg Harmony**
Sometimes you need **both GitHub and GitLab**. Sometimes you need **containers AND WebAssembly**. Sometimes you need **Kaniko AND BuildKit AND Ko AND Spin**.

These are **ingredients**. We're not here to tell our developers where they can shop, or what they're allowed to cook with. We're here to provide the support they need—whether they're developers, or scientists, or both! We're the builders, here to make this easy—**for science**.

```bash
# The dream: Modern complexity hidden behind simple interface
git push deis main

# Behind the scenes: The best tool for each job
# - Ko for Go microservices (fastest, smallest)
# - Spin for WebAssembly components (instant startup)  
# - BuildKit for complex containers (advanced features)
# - Kaniko for security-first environments (rootless)
# - GitHub Actions OR GitLab CI (developer choice)
# - Kubernetes OR SpinKube (workload appropriate)
```

**You don't have to take it if you don't want it!** 😂

But if you want the **harmonious wonder** of having the right tool automatically selected for each job, while maintaining the simple `git push deis main` experience—**that's hephy-builder**.

## 🌈 **The Full Circle**

### **From Complexity Back to Simplicity**
We started with simple deployment. We gained complexity to solve real problems. Now we can build simplicity on top of that complexity.

**hephy-builder** is the bridge between:
- **Deis heritage**: Simple, elegant developer experience
- **Modern reality**: Multiple tools, platforms, and deployment targets
- **Future vision**: WebAssembly, edge computing, hybrid clouds

### **The Choice Architecture**
Just like Deis chose Kubernetes over Fleet, we're choosing **optionality over rigidity**:
- **Multiple build backends**: The right tool for each language/framework
- **Multiple CI platforms**: Work where your team already works
- **Multiple deployment targets**: Containers, WebAssembly, edge, cloud

### **The Consistent Interface**
Whether you're building:
- **Go microservices** with Ko
- **Rust WebAssembly** with Spin  
- **Complex multi-language** apps with BuildKit
- **Security-critical** workloads with Kaniko

The interface remains the same: **git push deis main**

*(Note: The CLI was never renamed from `deis` to `hephy`—Team Hephy kept the familiar command interface that users loved.)*

## 💭 **The Vision Statement**

**hephy-builder resurrects the elegant simplicity of "git push deis main" using modern, secure, multi-platform tooling. We learned from the Deis Workflow legacy that developers want simple deployment, but we also learned that one size doesn't fit all. So we're building the platform that automatically chooses the best tool for each job, while maintaining the magical experience that made Deis legendary.**

**Sometimes you need the Rube Goldberg harmony of multiple tools working together. Sometimes you need both GitHub and GitLab. Sometimes you need containers AND WebAssembly.**

**These are ingredients. We're not here to tell developers where they can shop, or what they're allowed to cook with. We're here to provide the support they need—whether they're developers, or scientists, or both! We're the builders, here to make this easy—for science.**

**You don't have to take it all if you don't want it. Start simple. Add complexity only when you need it. And always keep the magic of `git push deis main`.**

---

*The future is simple again, built on top of all the complexity we've learned to manage.*  
*Welcome to hephy-builder: **git push deis main** for the modern age.* 🚀