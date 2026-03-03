docker rm -f dingtalk
docker build -t rela/dingtalk:latest .

docker run -d \
    --name dingtalk \
    --net host \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /dev/shm:/dev/shm \
    --device /dev/dri \
    -v /run/user/$(id -u)/pulse/native:/tmp/pulse-socket \
    -e PULSE_SERVER=unix:/tmp/pulse-socket \
    -v ~/.config/pulse/cookie:/root/.config/pulse/cookie:ro \
    --device /dev/video0 \
    rela/dingtalk:latest
