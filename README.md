# **Dockerized DingTalk for Linux**

A stable, containerized version of the official DingTalk Linux client.

Proprietary Linux clients often suffer from library shadowing, ABI (Application Binary Interface) collisions, or UI crashes when run on newer Linux distributions. This Docker image isolates DingTalk using a modern Ubuntu 24.04 base, leverages the vendor's native Elevator.sh launch script to handle internal library overrides safely, and properly passes through your host machine's hardware (GPU, Audio, Display).

Available in dockerhub under

```
docker pull rela/dingtalk:latest
```

## **Prerequisites**

* Docker installed and your user added to the docker group.
* A Linux desktop environment using X11 (or XWayland).
* PulseAudio or PipeWire-Pulse for sound.

## **Quick Start (Prebuilt Image)**

```bash
chmod +x run.sh
./run.sh
```

The `run.sh` wrapper handles X11 permissions and launches via Docker Compose.

To stop:

```bash
docker compose down
```

## **Build From Source**

```bash
chmod +x build.sh run.sh
./build.sh
./run.sh
```

## **Configuration**

All configuration is done through environment variables. Copy `.env.example` to `.env` and uncomment the values you want to change:

```bash
cp .env.example .env
```

Or pass variables inline:

```bash
DINGTALK_DOWNLOADS=~/Downloads ./run.sh
```

| Variable | Default | Description |
|---|---|---|
| `DINGTALK_DOWNLOADS` | `/tmp` | Host directory mounted as DingTalk's Downloads folder |
| `DINGTALK_CONFIG` | `~/.config/dingtalk-docker` | Host directory for persistent login/settings data |
| `HOST_UID` | `1000` | Your host UID, used to find the PulseAudio socket |
| `PULSE_COOKIE` | `~/.config/pulse/cookie` | Path to PulseAudio cookie on the host |

## **File Sharing / Downloads**

By default, your host's `/tmp` is mounted into the container at `/home/dingtalk/Downloads`. Inside DingTalk, save or open files from that `Downloads` folder to exchange them with your host.

```bash
# Linux — use ~/Downloads instead of /tmp
DINGTALK_DOWNLOADS=~/Downloads ./run.sh

# macOS
DINGTALK_DOWNLOADS=~/Downloads ./run.sh

# Windows (WSL / Git Bash)
DINGTALK_DOWNLOADS=/c/Users/me/Downloads ./run.sh
```

## **How Persistence Works**

Docker containers are ephemeral, meaning they wipe their data when they stop. To prevent you from having to log in every time, the container mounts a folder on your host machine (default `~/.config/dingtalk-docker`).

All of your DingTalk settings, login tokens, chat caches, and configurations are safely stored here without polluting your actual host `~/.config folder`.

## **Troubleshooting**

### **The app "crashes" when I change the language**

This is expected behavior! When you change the language in DingTalk, it initiates a soft reboot (spawning a new process and killing the old one).

Our container is designed with a smart "watchdog" script specifically to handle this. The window will disappear and reappear a few seconds later in English. Since your data is persisted in `~/.config/dingtalk-docker`, the language preference will be saved for all future launches.

### **How do I restart the app after closing it?**

Simply run `./run.sh` again! Docker Compose will automatically recreate the container and log you back in using your saved data.

### **No Audio or Microphone**

The container maps PulseAudio via socket. Ensure your host system is actually using PulseAudio or PipeWire with the pipewire-pulse compatibility layer. If the container complains about missing `/run/user/1000/pulse/native`, check your host's audio routing. If your UID is not 1000, set `HOST_UID` in your `.env` file.

### **Display / X11 Errors**

If you see errors about Cannot open display, ensure you are running X11. The run.sh script automatically runs `xhost +local:docker` to permit the container to draw to your screen. If you are on strict Wayland (without XWayland), you may need to configure additional Wayland socket mappings.