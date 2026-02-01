#!/bin/bash
set -e

IMAGE_NAME="${1:-docker-devbox:latest}"
TZ="${TZ:-America/Denver}"

echo "Building $IMAGE_NAME..."
echo "Timezone: $TZ"

docker build \
    --build-arg TZ="$TZ" \
    --build-arg USERNAME="$(whoami)" \
    --build-arg USER_UID="$(id -u)" \
    --build-arg USER_GID="$(id -g)" \
    -t "$IMAGE_NAME" \
    .

echo ""
echo "Done! Run with:"
echo "  docker run -it --rm -v \$(pwd):/workspace $IMAGE_NAME"
