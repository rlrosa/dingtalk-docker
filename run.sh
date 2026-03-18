#!/bin/bash
set -e

# Ensure host prerequisites
mkdir -p "${DINGTALK_CONFIG:-$HOME/.config/dingtalk-docker}"
touch ~/.config/pulse/cookie

# Allow local connections to X11 (required for some desktop environments)
xhost +local:docker > /dev/null 2>&1 || true

# Export HOST_UID so docker-compose.yml can locate the PulseAudio socket
export HOST_UID=$(id -u)

echo "📁 Downloads directory: ${DINGTALK_DOWNLOADS:-/tmp} (override with DINGTALK_DOWNLOADS=/your/path)"
echo "🚀 Starting DingTalk via Docker Compose..."
docker compose up -d

echo "✅ DingTalk is now running in the background."
echo "💡 Stop with: docker compose down"
