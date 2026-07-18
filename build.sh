#!/bin/sh
set -e

IMAGE_NAME_ARG="$1"
ACTION="$2"
USERNAME="$3"

if [ -z "$IMAGE_NAME_ARG" ]; then
    echo "❌ Usage: $0 <image-name> [push|push-only] [github-username]"
    echo "   Example: $0 twitchdropsbots302 push fmr5487"
    echo "   Example: $0 twitchdropsbots302 push-only fmr5487"
    exit 1
fi

LOCAL_IMAGE_NAME="$IMAGE_NAME_ARG"
REMOTE_IMAGE_NAME=""
if [ -n "$USERNAME" ]; then
    if ! echo "$IMAGE_NAME_ARG" | grep -q '/'; then
        REMOTE_IMAGE_NAME="ghcr.io/$USERNAME/$IMAGE_NAME_ARG"
        echo "🔗 Will push to remote: $REMOTE_IMAGE_NAME (local: $LOCAL_IMAGE_NAME)"
    else
        REMOTE_IMAGE_NAME="$IMAGE_NAME_ARG"
        LOCAL_IMAGE_NAME="$IMAGE_NAME_ARG"
        echo "⚠️  Using provided full image name, no local/remote distinction."
    fi
else
    echo "📦 Local image only (no remote push)."
fi

push_image() {
    if [ -z "$REMOTE_IMAGE_NAME" ]; then
        echo "❌ No remote image name defined. Please provide username."
        return 1
    fi
    echo "📤 Pushing $REMOTE_IMAGE_NAME ..."
    if ! docker push "$REMOTE_IMAGE_NAME"; then
        echo "❌ Push failed! (but build was successful)"
        return 1
    fi
    echo "✅ Push completed!"
    return 0
}

if [ "$ACTION" = "push-only" ]; then
    if [ -z "$REMOTE_IMAGE_NAME" ]; then
        echo "❌ push-only requires a username to construct remote name."
        exit 1
    fi
    echo "🚀 Push-only mode: checking local image $LOCAL_IMAGE_NAME ..."
    if ! docker image inspect "$LOCAL_IMAGE_NAME" >/dev/null 2>&1; then
        echo "❌ Local image $LOCAL_IMAGE_NAME does not exist. Please build first."
        exit 1
    fi
    if [ "$LOCAL_IMAGE_NAME" != "$REMOTE_IMAGE_NAME" ]; then
        echo "🏷️  Tagging $LOCAL_IMAGE_NAME as $REMOTE_IMAGE_NAME ..."
        docker tag "$LOCAL_IMAGE_NAME" "$REMOTE_IMAGE_NAME"
    fi
    push_image
    exit $?
fi

echo "🚀 Building Docker image: $LOCAL_IMAGE_NAME"
CACHEBUST=$(date +%s)
docker build --build-arg CACHEBUST="$CACHEBUST" -t "$LOCAL_IMAGE_NAME" .
echo "✅ Build completed!"

if [ "$ACTION" = "push" ]; then
    if [ -n "$REMOTE_IMAGE_NAME" ] && [ "$LOCAL_IMAGE_NAME" != "$REMOTE_IMAGE_NAME" ]; then
        echo "🏷️  Tagging $LOCAL_IMAGE_NAME as $REMOTE_IMAGE_NAME ..."
        docker tag "$LOCAL_IMAGE_NAME" "$REMOTE_IMAGE_NAME"
    fi
    push_image
fi

echo "📦 Local image: $LOCAL_IMAGE_NAME"
[ -n "$REMOTE_IMAGE_NAME" ] && echo "📦 Remote image: $REMOTE_IMAGE_NAME"