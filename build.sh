#!/bin/bash
set -e

IMAGE_NAME="rela/dingtalk:latest"

echo "🔨 Building DingTalk Docker image ($IMAGE_NAME)..."
docker build -t "$IMAGE_NAME" .

echo "✅ Build complete!"
