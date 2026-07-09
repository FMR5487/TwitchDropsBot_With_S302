#!/bin/sh
set -e

IMAGE_NAME_ARG="$1"
ACTION="$2"
USERNAME="$3"

if [ -z "$IMAGE_NAME_ARG" ]; then
    echo "❌ Usage: $0 <image-name> [push|--push-only] [github-username]"
    echo "   Example: $0 imagename push username"
    echo "   Example: $0 imagename --push-only username"
    exit 1
fi

if [ -n "$USERNAME" ]; then
    if ! echo "$IMAGE_NAME_ARG" | grep -q '/'; then
        IMAGE_NAME="ghcr.io/$USERNAME/$IMAGE_NAME_ARG"
        echo "🔗 Using GitHub Container Registry: $IMAGE_NAME"
    else
        IMAGE_NAME="$IMAGE_NAME_ARG"
    fi
else
    IMAGE_NAME="$IMAGE_NAME_ARG"
fi

push_image() {
    echo "📤 Pushing image $IMAGE_NAME ..."
    if ! docker push "$IMAGE_NAME"; then
        echo "❌ Push failed! (but build was successful)"
        return 1
    fi
    echo "✅ Push completed!"
    return 0
}

if [ "$ACTION" = "--push-only" ]; then
    echo "🚀 Push-only mode: pushing existing image $IMAGE_NAME"
    if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
        echo "❌ Image $IMAGE_NAME does not exist locally. Please build first."
        exit 1
    fi
    push_image
    exit $?
fi

echo "🚀 Building Docker image: $IMAGE_NAME"

CACHEBUST=$(date +%s)
docker build \
    --build-arg CACHEBUST="$CACHEBUST" \
    -t "$IMAGE_NAME" \
    .

echo "✅ Build completed!"

if [ "$ACTION" = "push" ]; then
    push_image
fi

echo "📦 Image: $IMAGE_NAME (built with cache-bust $CACHEBUST)"