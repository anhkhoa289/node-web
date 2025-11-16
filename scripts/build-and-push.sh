#!/bin/bash
# Build and push Node.js Express app using Cloud Native Buildpacks

set -e

# Configuration from arguments or environment variables
IMAGE_NAME=${IMAGE_NAME:-${1:-"node-web"}}
IMAGE_TAG=${IMAGE_TAG:-${2:-"1.0.0"}}
REGISTRY=${REGISTRY:-${3}}

if [ -z "$REGISTRY" ]; then
    echo "Error: Registry is required for push"
    echo "Usage: $0 [IMAGE_NAME] [IMAGE_TAG] [REGISTRY]"
    echo "Or set environment variables: IMAGE_NAME, IMAGE_TAG, REGISTRY"
    echo ""
    echo "Example:"
    echo "  $0 node-web 1.0.0 docker.io/myuser"
    echo "  or"
    echo "  REGISTRY=docker.io/myuser IMAGE_TAG=1.0.0 $0"
    exit 1
fi

FULL_IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "============================================"
echo "Build and Push with Cloud Native Buildpacks"
echo "============================================"
echo "Image: ${FULL_IMAGE_NAME}"
echo "============================================"

# Build
./scripts/build-with-buildpack.sh "${IMAGE_NAME}" "${IMAGE_TAG}" "${REGISTRY}"

# Push
echo ""
echo "Pushing image to registry..."
docker push "${FULL_IMAGE_NAME}"

echo ""
echo "============================================"
echo "Push completed successfully!"
echo "============================================"
echo "Image: ${FULL_IMAGE_NAME}"
echo ""
echo "To deploy with Helm:"
echo "  helm install my-node-web ./helm/node-web \\"
echo "    --set image.repository=${REGISTRY}/${IMAGE_NAME} \\"
echo "    --set image.tag=${IMAGE_TAG}"
echo "============================================"
