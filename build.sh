#!/bin/sh
set -e

IMAGE_NAME_ARG="$1"
ACTION="$2"
USERNAME="$3"

if [ -z "$IMAGE_NAME_ARG" ]; then
    echo "❌ Usage: $0 <image-name> [push] [github-username]"
    echo "   Example: $0 twitchdropsbots302 push myuser"
    exit 1
fi

if [ -n "$USERNAME" ]; then
    if ! echo "$IMAGE_NAME_ARG" | grep -q '/'; then
        IMAGE_NAME="ghcr.io/$USERNAME/$IMAGE_NAME_ARG"
        echo "🔗 Using GitHub Container Registry: $IMAGE_NAME"
    else
        IMAGE_NAME="$IMAGE_NAME_ARG"
        echo "⚠️  Image name already contains '/', using as-is: $IMAGE_NAME"
    fi
else
    IMAGE_NAME="$IMAGE_NAME_ARG"
    echo "📦 Using local/Docker Hub image name: $IMAGE_NAME"
fi

echo "🚀 Building Docker image: $IMAGE_NAME"

CACHEBUST=$(date +%s)
docker build \
    --build-arg CACHEBUST="$CACHEBUST" \
    --build-arg VERSION="$LATEST_VERSION" \
    -t "$IMAGE_NAME" \
    .

echo "✅ Build completed successfully!"

if [ "$ACTION" = "push" ]; then
    if echo "$IMAGE_NAME" | grep -q '^ghcr.io/'; then
        echo "📤 Pushing to GitHub Container Registry..."
        REGISTRY_USER=$(echo "$IMAGE_NAME" | cut -d'/' -f2)
        echo "ℹ️  Make sure you are logged in: docker login ghcr.io -u $REGISTRY_USER"
    else
        echo "📤 Pushing to default registry (Docker Hub)..."
    fi
    docker push "$IMAGE_NAME"
    echo "✅ Push completed successfully!"
else
    echo "💡 To push this image, run: $0 $IMAGE_NAME_ARG push $USERNAME"
fi

echo "📦 Image: $IMAGE_NAME (based on version $LATEST_VERSION)"