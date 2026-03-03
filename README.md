# **Dockerized DingTalk for Linux**

A stable, containerized version of the official DingTalk Linux client.

Proprietary Linux clients often suffer from library shadowing, ABI (Application Binary Interface) collisions, or UI crashes when run on newer Linux distributions. This Docker image isolates DingTalk using a modern Ubuntu 24.04 base, leverages the vendor's native Elevator.sh launch script to handle internal library overrides safely, and properly passes through your host machine's hardware (GPU, Audio, Display).

## **Prerequisites**

* Docker installed and your user added to the docker group.  
* A Linux desktop environment using X11 (or XWayland).  
* PulseAudio or PipeWire-Pulse for sound.

## **Installation & Setup**

1. **Make the scripts executable:**  
   chmod \+x build.sh run.sh

2. **Build the Docker Image:**  
   ./build.sh

   *(This downloads the latest .deb from DingTalk, installs necessary GUI/XCB dependencies, and configures the environment).*  
3. **Run the Application:**  
   ./run.sh

## **How Persistence Works**

Docker containers are ephemeral, meaning they wipe their data when they stop. To prevent you from having to log in every time, the run.sh script creates a folder on your host machine at \~/.config/dingtalk-docker.

This folder is mounted directly into the container. All of your DingTalk settings, login tokens, chat caches, and configurations are safely stored here without polluting your actual host \~/.config folder.

## **Troubleshooting**

### **The app "crashes" when I change the language**

This is expected behavior\! When you change the language in DingTalk, it initiates a soft reboot (spawning a new process and killing the old one).

Our container is designed with a smart "watchdog" script specifically to handle this. The window will disappear and reappear a few seconds later in English. Since your data is persisted in \~/.config/dingtalk-docker, the language preference will be saved for all future launches.

### **How do I restart the app after closing it?**

Simply run ./run.sh again\! The script will automatically clean up the old stopped container and launch a fresh one, immediately logging you back in using your saved data.

### **No Audio or Microphone**

The container maps PulseAudio via socket. Ensure your host system is actually using PulseAudio or PipeWire with the pipewire-pulse compatibility layer. If the container complains about missing /run/user/1000/pulse/native, check your host's audio routing.

### **Display / X11 Errors**

If you see errors about Cannot open display, ensure you are running X11. The run.sh script automatically runs xhost \+local:docker to permit the container to draw to your screen. If you are on strict Wayland (without XWayland), you may need to configure additional Wayland socket mappings.