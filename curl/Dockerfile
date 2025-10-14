# Bootstrap Dockerfile for curl
# Uses well-known curlimages/curl as base for initial build
# Once we have manifest-tool working, we can switch to building from upstream

FROM curlimages/curl:latest

# This image already has curl and is Alpine-based
# We're just using it as-is for bootstrapping (testing x11)

USER root
RUN apk add --no-cache ca-certificates

USER curl_user
