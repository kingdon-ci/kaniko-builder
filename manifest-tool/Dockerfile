# Dockerfile for manifest-tool
# Self-contained image - no dependencies on other builds
# Test build: Oct 26, 2025 x2 - GitHub Actions Kaniko backend validation
FROM alpine:latest

# Install tools needed for extracting and building
RUN apk add --no-cache curl file tar docker-credential-ecr-login crane


# Download and extract manifest-tool from tarball
RUN echo "Downloading manifest-tool v2.2.1..." && \
    curl -L -o /tmp/manifest-tool.tar.gz \
    https://github.com/estesp/manifest-tool/releases/download/v2.2.1/binaries-manifest-tool-2.2.1.tar.gz && \
    echo "Extracting tarball..." && \
    cd /tmp && \
    tar -xzf manifest-tool.tar.gz && \
    echo "Available binaries:" && \
    ls -la /tmp/manifest-tool-* && \
    # Detect architecture and copy the right binary
    ARCH=$(uname -m) && \
    echo "Detected architecture: $ARCH" && \
    if [ "$ARCH" = "x86_64" ]; then \
        BINARY="manifest-tool-linux-amd64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        BINARY="manifest-tool-linux-arm64"; \
    else \
        echo "Unsupported architecture: $ARCH"; \
        exit 1; \
    fi && \
    echo "Using binary: $BINARY" && \
    cp "/tmp/$BINARY" /usr/local/bin/manifest-tool && \
    chmod +x /usr/local/bin/manifest-tool && \
    # Verify it's a valid binary
    file /usr/local/bin/manifest-tool && \
    # Test that it works
    echo "Testing manifest-tool..." && \
    /usr/local/bin/manifest-tool --help && \
    # Cleanup
    rm -rf /tmp/manifest-tool*

# Set up for ECR authentication
RUN mkdir -p /root/.docker

ENTRYPOINT ["/bin/sh"]
