#!/bin/bash
set -e

IMAGE_NAME="${1:-docker-devbox:latest}"
TZ="${TZ:-America/Denver}"

echo "Building $IMAGE_NAME..."
echo "Timezone: $TZ"
echo ""
echo "Note: Requires claude-code-sandbox:latest base image"
echo "      Build it first: cd claude-code-sandbox && docker build -t claude-code-sandbox:latest docker/"
echo ""

docker build \
    --build-arg TZ="$TZ" \
    --build-arg NPM_CACHE_BUST="$(date +%s)" \
    -t "$IMAGE_NAME" \
    .

echo ""
echo "Done! Image: $IMAGE_NAME"
