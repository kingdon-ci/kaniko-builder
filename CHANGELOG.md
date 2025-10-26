# hephy-builder Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Complete documentation architecture with `docs/` structure
- Heritage preservation in `docs/lore/` (Deis Workflow story)
- hephy-builder vision and roadmap documentation
- Contributor onboarding infrastructure
- 18 GitHub issues for structured development
- Sunkworks interview preparation for live vision capture

### Changed
- Project identity evolution from kaniko-builder to hephy-builder
- Root README.md complete rewrite reflecting transformation
- All documentation updated with hephy-builder context
- Build configurations updated with heritage context

### Deprecated
- kaniko-builder terminology (maintained for compatibility)

## [2.0.0] - 2025-10-26 - "Transformation Complete"

### Added
- **hephy-builder transformation**: Complete evolution from single-purpose kaniko builds to multi-backend PaaS resurrection
- **Documentation architecture**: Professional `docs/` structure with comprehensive navigation
- **Heritage preservation**: Complete Deis Workflow story in `docs/lore/DEIS_HERITAGE.md`
- **Vision articulation**: Future roadmap in `docs/lore/HEPHY_VISION.md`
- **Community infrastructure**: Contributing guide, issue templates, clear onboarding
- **Implementation roadmap**: 18 GitHub issues spanning research, design, and implementation

### Changed
- **Project scope**: From container builds to "git push deis main" resurrection
- **Architecture vision**: Multi-backend support (Kaniko, Ko, BuildKit, Spin)
- **Platform strategy**: GitLab CI + GitHub Actions portability
- **Developer experience**: Foundation for git remote server with real-time logs

### Technical
- All files updated to remove AI-generated commit messages
- Clean git history with meaningful, human-readable commits
- Consistent hephy-builder branding across all documentation
- Professional project structure suitable for contributor onboarding

## [1.0.0] - 2025-10-16 - "MVP Complete"

### Added
- **Multi-architecture builds**: AMD64 + ARM64 container support
- **Remote repository cloning**: GitHub integration validated with real applications
- **Professional tagging**: Support for `latest`, version tags, and custom naming
- **Smart pipeline**: Change detection, architecture filtering, dependency resolution
- **External Kaniko**: Using maintained `martizih/kaniko:v1.26.0-debug`

### Technical Achievements
- **Bootstrap complete**: curl and manifest-tool images operational
- **Dependency chaining**: Clean architecture without circular dependencies
- **Real-world validation**: spkane/scratch-helloworld Go HTTP server builds
- **Multi-arch manifests**: Automatic architecture selection functional
- **ECR integration**: Complete registry authentication and image distribution

### Infrastructure
- **GitLab CI pipeline**: 495 lines of production-ready configuration
- **Multi-arch runners**: AMD64 and ARM64 spot instance support
- **Change detection**: Smart building with `hack/prepare_diff.sh`
- **Architecture filtering**: Cost optimization through selective builds

## [0.3.0] - 2025-10-15 - "External Dependencies"

### Added
- **External Kaniko adoption**: Switch to maintained `martizih/kaniko:v1.26.0-debug`
- **Dependency resolution**: Automatic image dependency management
- **Build arguments**: Support for parameterized builds

### Changed
- **Self-build strategy**: Deferred kaniko self-building in favor of external maintenance
- **Manifest tool**: Made self-contained to eliminate circular dependencies

## [0.2.0] - 2025-10-14 - "Multi-Architecture Foundation"

### Added
- **ARM64 support**: Complete multi-architecture build capability
- **Manifest creation**: Multi-arch container manifests for automatic selection
- **Architecture detection**: Smart filtering for cost optimization

### Technical
- **Kaniko arm64**: First successful arm64 container builds
- **Pipeline architecture**: Prepare → Build → Manifest stages
- **ECR authentication**: Container registry integration

## [0.1.0] - 2025-10-13 - "Initial Implementation"

### Added
- **GitLab CI pipeline**: Basic container build automation
- **Kaniko integration**: Rootless container builds without Docker daemon
- **ECR support**: AWS Elastic Container Registry integration
- **Build configuration**: YAML-based project configuration system

### Technical Foundation
- **Repository structure**: Clean organization with `build-config.yaml` pattern
- **CI/CD variables**: Secure configuration management
- **Container builds**: First successful kaniko-based builds

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to contribute to hephy-builder.

## Heritage

This project continues the spirit of Deis Workflow - bringing elegant simplicity to application deployment while leveraging the best of modern container and WebAssembly tooling.

*"Sometimes you need the Rube Goldberg harmony of multiple tools working together."*