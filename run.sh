#!/bin/bash
set -e

CONTAINER_NAME="dingtalk"
IMAGE_NAME="rela/dingtalk:latest"
CONFIG_DIR="${HOME}/.config/dingtalk-docker"

echo "📂 Ensuring persistent config directory exists at $CONFIG_DIR..."
mkdir -p "$CONFIG_DIR"

# Ensure pulse audio cookie exists to prevent docker mount errors
touch ~/.config/pulse/cookie

# Allow local connections to X11 (required for some desktop environments)
xhost +local:docker > /dev/null 2>&1 || true

# Remove any existing container with the same name
if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
    echo "🧹 Removing old container..."
    docker rm -f "$CONTAINER_NAME" > /dev/null
fi

# Detect webcam for video calls (mount if exists)
VIDEO_ARGS=""
if [ -e /dev/video0 ]; then
    VIDEO_ARGS="--device /dev/video0"
fi

echo "🚀 Starting DingTalk container..."
docker run -d \
    --name "$CONTAINER_NAME" \
    --net host \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /dev/shm:/dev/shm \
    --device /dev/dri \
    $VIDEO_ARGS \
    -v /run/user/$(id -u)/pulse/native:/tmp/pulse-socket \
    -e PULSE_SERVER=unix:/tmp/pulse-socket \
    -v ~/.config/pulse/cookie:/home/dingtalk/.config/pulse/cookie:ro \
    -v "$CONFIG_DIR":/home/dingtalk/.config \
    "$IMAGE_NAME"

echo "✅ DingTalk is now running in the background."
echo "💡 Note: When you change language or settings, the app may restart itself."
