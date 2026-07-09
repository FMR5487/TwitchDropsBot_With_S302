#!/bin/sh
set -e

REPO="Alorf/TwitchDropsBot"
ASSET_PATTERN="Console-linux-x64.*\.tar\.gz"
LOCAL_DIR="TwitchDropsBot"

echo "🔍 Fetching latest release info from GitHub..."
API_URL="https://api.github.com/repos/$REPO/releases/latest"
RESPONSE=$(curl -f -s -L "$API_URL" 2>/dev/null) || {
    echo "❌ Failed to fetch release info."
    exit 1
}

if [ "$(echo "$RESPONSE" | head -c1)" != "{" ]; then
    echo "❌ Invalid API response. First 200 chars:"
    echo "$RESPONSE" | head -c200
    echo ""
    exit 1
fi

DOWNLOAD_URL=$(echo "$RESPONSE" | jq -r --arg pattern "$ASSET_PATTERN" \
    '.assets[] | select(.name | test($pattern)) | .browser_download_url' | head -1)

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
    echo "❌ No asset matching pattern '$ASSET_PATTERN' found."
    exit 1
fi

FILENAME=$(basename "$DOWNLOAD_URL")

REMOTE_VERSION=$(echo "$FILENAME" | awk -F 'linux-x64-|.tar.gz' '{print $2}')
if [ -z "$REMOTE_VERSION" ]; then
    echo "❌ Failed to extract version from filename: $FILENAME"
    exit 1
fi
echo "📦 Remote version: '$REMOTE_VERSION'"

LOCAL_VERSION=""
if [ -d "$LOCAL_DIR" ]; then
    MARKER_FILE=$(find "$LOCAL_DIR" -maxdepth 1 -name "V-*" -type f | head -1)
    if [ -n "$MARKER_FILE" ]; then
        LOCAL_VERSION=$(basename "$MARKER_FILE" | sed 's/^V-//')
        echo "📁 Local version: '$LOCAL_VERSION'"
    else
        echo "📁 No version marker found locally."
    fi
else
    echo "📁 Local directory does not exist."
fi

if [ -n "$LOCAL_VERSION" ] && [ "$LOCAL_VERSION" = "$REMOTE_VERSION" ]; then
    echo "✅ Already up-to-date (version $REMOTE_VERSION). No action needed."
    exit 0
fi

echo "🔄 Version mismatch or missing. Updating to $REMOTE_VERSION ..."

[ -d "$LOCAL_DIR" ] && rm -rf "$LOCAL_DIR"

PROXY_DOWNLOAD_URL="https://ghfast.top/$DOWNLOAD_URL"
echo "⬇️  Downloading via proxy..."
curl -L "$PROXY_DOWNLOAD_URL" -o "/tmp/$FILENAME" || {
    echo "⚠️  Proxy failed, trying direct..."
    curl -L "$DOWNLOAD_URL" -o "/tmp/$FILENAME" || {
        echo "❌ Download failed."
        exit 1
    }
}

TEMP_EXTRACT="/tmp/extract_$$"
mkdir -p "$TEMP_EXTRACT"
echo "📂 Extracting..."
tar -xzf "/tmp/$FILENAME" -C "$TEMP_EXTRACT"

EXTRACTED_DIR=$(tar -tzf "/tmp/$FILENAME" | head -1 | cut -f1 -d'/')
if [ -z "$EXTRACTED_DIR" ]; then
    echo "❌ Failed to determine extracted directory."
    rm -rf "$TEMP_EXTRACT" "/tmp/$FILENAME"
    exit 1
fi

mv "$TEMP_EXTRACT/$EXTRACTED_DIR" "./$LOCAL_DIR"

VERSION_TAG="V-$REMOTE_VERSION"
touch "$LOCAL_DIR/$VERSION_TAG"
echo "🏷️  Created marker: $LOCAL_DIR/$VERSION_TAG"

rm -rf "$TEMP_EXTRACT" "/tmp/$FILENAME"

echo "🎉 Updated to version $REMOTE_VERSION in ./$LOCAL_DIR"