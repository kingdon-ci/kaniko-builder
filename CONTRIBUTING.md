# Contributing to hephy-builder

Welcome to hephy-builder! We're building the future of "git push deis main" with modern, secure tooling.

## 🎯 **Project Vision**

**hephy-builder** resurrects the elegant simplicity of Deis Workflow deployment using modern container and WebAssembly build systems. We're not just building containers—we're rebuilding the developer experience that made Platform-as-a-Service magical.

## 🚀 **Quick Start for Contributors**

### **Understanding the Project**
1. **Read the heritage**: [docs/lore/DEIS_HERITAGE.md](docs/lore/DEIS_HERITAGE.md) - The story that brought us here
2. **Explore the vision**: [docs/lore/HEPHY_VISION.md](docs/lore/HEPHY_VISION.md) - Where we're going
3. **Review the roadmap**: [ROADMAP.md](ROADMAP.md) - Current development priorities

### **Technical Foundation**
- **Current state**: Multi-arch container builds with Kaniko (production ready)
- **Active development**: Multi-backend support (Ko, Spin, BuildKit)
- **Future vision**: Git remote server with real-time log streaming

## 🤝 **How to Contribute**

### **🐛 Pick Up an Issue**
- **Browse**: [GitHub Issues](https://github.com/kingdon-ci/kaniko-builder/issues)
- **Good first issues**: Look for `good first issue` label
- **Research tasks**: Perfect for learning the ecosystem
- **Implementation tasks**: For hands-on development

### **📚 Improve Documentation**
- **Add examples**: Real-world build configurations
- **Write tutorials**: Help others get started
- **Fix typos**: Every improvement helps
- **Translate vision**: Help others understand the heritage connection

### **🧪 Test and Validate**
- **Try builds**: Test with your own projects
- **Report issues**: Help us find edge cases
- **Suggest improvements**: Share your experience
- **Performance testing**: Help optimize the pipeline

### **🔧 Implement Features**
- **Backend development**: Ko, Spin, BuildKit integration
- **Platform support**: GitHub Actions workflows
- **Git server**: SSH streaming and real-time logs
- **CLI tools**: hephy command-line interface

## 🌟 **Current Focus Areas**

### **High Impact Opportunities**
1. **Backend Research** (Issue #14): Complete builder comparison matrix
2. **GitHub Actions** (Issue #15): Platform portability implementation  
3. **Infrastructure** (Issue #16): Multi-arch NodePool deployment
4. **Git Server** (Issues #17-18): "git push hephy main" implementation

### **Community Building**
- **Documentation**: Expand guides and examples
- **Examples**: Real-world application builds
- **Tutorials**: Step-by-step walkthroughs
- **Evangelism**: Share the hephy-builder vision

## 🛠️ **Development Setup**

### **Prerequisites**
- GitLab CI environment or GitHub Actions (for testing)
- Multi-architecture runners (AMD64 + ARM64)
- Container registry access (ECR, Docker Hub, etc.)
- Basic understanding of container builds

### **Local Testing**
```bash
# Clone the repository
git clone https://github.com/kingdon-ci/kaniko-builder.git
cd kaniko-builder

# Review documentation structure
ls docs/

# Test change detection
./hack/prepare_diff.sh

# Validate build configurations
find . -name "build-config.yaml" -exec yq '.' {} \;
```

### **CI/CD Testing**
- **Fork the repository** for your own testing
- **Set up GitLab CI variables** as described in [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)
- **Create test branches** to validate changes
- **Use small changes** to test pipeline behavior

## 📋 **Contribution Guidelines**

### **Code Quality**
- **Clear commit messages**: Explain the "why" not just the "what"
- **Documentation updates**: Keep docs in sync with code changes
- **Test your changes**: Ensure builds work before submitting
- **Follow existing patterns**: Maintain consistency with current code

### **Pull Request Process**
1. **Create an issue** first (for non-trivial changes)
2. **Fork and branch** from main
3. **Make focused changes** (one concept per PR)
4. **Update documentation** as needed
5. **Write clear PR description** explaining the change

### **Communication**
- **Be respectful**: We're all learning and building together
- **Ask questions**: Better to clarify than assume
- **Share context**: Help others understand your perspective
- **Celebrate progress**: Acknowledge good work from others

## 🎭 **The hephy-builder Philosophy**

### **Heritage First**
We honor the legacy of Deis Workflow while building for the future. Every decision should consider both the elegant simplicity of "git push deis main" and the security/performance needs of 2025.

### **Ingredients, Not Recipes**
> *"Sometimes you need the Rube Goldberg harmony of multiple tools working together. These are ingredients. We're not here to tell developers where they can shop, or what they're allowed to cook with."*

### **Community Driven**
This project succeeds when developers love using it and contributors enjoy building it. Technical excellence serves the human experience.

## 🔗 **Resources**

### **Documentation**
- **[docs/README.md](docs/README.md)**: Comprehensive navigation hub
- **[docs/BUILD_CONFIG_SPEC.md](docs/BUILD_CONFIG_SPEC.md)**: Configuration reference
- **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)**: Setup and deployment guide

### **Community**
- **[GitHub Issues](https://github.com/kingdon-ci/kaniko-builder/issues)**: Active development tasks
- **[Discussions](https://github.com/kingdon-ci/kaniko-builder/discussions)**: Ideas and questions
- **Sunkworks**: Regular development streams and community updates

### **Heritage Learning**
- **Deis Workflow**: Study the original implementation and user experience
- **Modern PaaS**: Understand current solutions (Heroku, Railway, Fly.io)
- **Container Evolution**: From Docker to Kaniko to Ko to WebAssembly

---

**Welcome to hephy-builder! Let's make "git push deis main" magic again.** ✨

*Questions? Start with an issue or discussion. We're here to help!*