# Dockerfile for Kaniko comparison
# This shows what the equivalent Docker build would look like

# Multi-stage build for comparison with Ko
FROM golang:1.21-alpine AS builder

# Install ca-certificates and git for dependencies
RUN apk add --no-cache ca-certificates git

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} \
    go build -ldflags="-s -w -X main.version=v1.0.0" \
    -o server ./cmd/server

# Final stage - distroless base
FROM gcr.io/distroless/static:nonroot

# Copy the binary from builder stage
COPY --from=builder /app/server /server

# Set environment variable to indicate Kaniko build
ENV KANIKO_BUILT=true

# Use non-root user
USER nonroot:nonroot

# Expose port
EXPOSE 8080

# Run the server
ENTRYPOINT ["/server"]

# Comparison notes:
# - Ko version: No Dockerfile needed, automatic optimization
# - Ko advantages: Faster builds, better caching, simpler config
# - This Dockerfile: More complex, slower builds, manual optimization