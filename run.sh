#!/bin/bash
set -e

# Ensure host prerequisites
mkdir -p "${DINGTALK_CONFIG:-$HOME/.config/dingtalk-docker}"
touch ~/.config/pulse/cookie

# Allow local connections to X11 (required for some desktop environments)
xhost +local:docker > /dev/null 2>&1 || true

# Export HOST_UID so docker-compose.yml can locate the PulseAudio socket
export HOST_UID=$(id -u)

# --- Dynamic video device detection ---
# Docker Compose device lists are static, so we generate an override file
# to pass through any /dev/video* devices found on the host.
OVERRIDE_FILE="docker-compose.override.yml"
VIDEO_DEVICES=(/dev/video*)
if [ -e "${VIDEO_DEVICES[0]}" ]; then
    echo "📷 Detected video devices: ${VIDEO_DEVICES[*]}"
    cat > "$OVERRIDE_FILE" <<EOF
services:
  dingtalk:
    devices:
EOF
    for dev in "${VIDEO_DEVICES[@]}"; do
        echo "      - ${dev}:${dev}" >> "$OVERRIDE_FILE"
    done
else
    echo "📷 No video devices detected."
    rm -f "$OVERRIDE_FILE"
fi

echo "📁 Downloads directory: ${DINGTALK_DOWNLOADS:-/tmp} (override with DINGTALK_DOWNLOADS=/your/path)"
echo "🚀 Starting DingTalk via Docker Compose..."
docker compose up -d

echo "✅ DingTalk is now running in the background."
echo "💡 Stop with: docker compose down"
