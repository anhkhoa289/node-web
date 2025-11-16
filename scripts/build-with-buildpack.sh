#!/bin/bash
# Build Node.js Express app using Cloud Native Buildpacks

set -e

# Configuration
IMAGE_NAME=${1:-"node-web"}
IMAGE_TAG=${2:-"latest"}
REGISTRY=${3:-""}

# Full image name
if [ -n "$REGISTRY" ]; then
    FULL_IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
else
    FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"
fi

echo "============================================"
echo "Building with Cloud Native Buildpacks"
echo "============================================"
echo "Image: ${FULL_IMAGE_NAME}"
echo "Builder: paketobuildpacks/builder:base"
echo "============================================"

# Check if pack CLI is installed
if ! command -v pack &> /dev/null; then
    echo "Error: 'pack' CLI is not installed."
    echo "Please install it from: https://buildpacks.io/docs/tools/pack/"
    echo ""
    echo "Quick install:"
    echo "  macOS/Linux: brew install buildpacks/tap/pack"
    echo "  Or download from: https://github.com/buildpacks/pack/releases"
    exit 1
fi

# Build with pack
echo "Starting build process..."
pack build "${FULL_IMAGE_NAME}" \
    --builder paketobuildpacks/builder:base \
    --buildpack paketo-buildpacks/nodejs \
    --env BP_NODE_VERSION="18.*" \
    --env NODE_ENV=production \
    --cache-image "${IMAGE_NAME}-cache" \
    --verbose

echo ""
echo "============================================"
echo "Build completed successfully!"
echo "============================================"
echo "Image: ${FULL_IMAGE_NAME}"
echo ""
echo "To run the image locally:"
echo "  docker run -p 3000:3000 ${FULL_IMAGE_NAME}"
echo ""
echo "To push to registry:"
echo "  docker push ${FULL_IMAGE_NAME}"
echo "============================================"
