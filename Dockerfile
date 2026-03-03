# Use modern Ubuntu 24.04 base
FROM ubuntu:24.04

# Prevent interactive prompts during apt installations
ENV DEBIAN_FRONTEND=noninteractive

# Setup default timezone to prevent tzdata null pointer segfaults
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update system and install GUI dependencies + locales for language control
# We keep the X11/XCB/Qt dependencies because a bare Ubuntu image lacks them (unlike your host OS).
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    locales \
    libnss3 \
    libx11-xcb1 \
    libxcb-dri3-0 \
    libxshmfence1 \
    libegl1 \
    libasound2t64 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    fonts-wqy-zenhei \
    libsm6 \
    libgbm1 \
    libgl1 \
    libpulse0 \
    libpulse-mainloop-glib0 \
    libopus0 \
    tzdata \
    dbus \
    dbus-x11 \
    libxss1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxtst6 \
    libnotify4 \
    libappindicator3-1 \
    libsecret-1-0 \
    libcurl4 \
    libxcb-xinerama0 \
    libxcb-cursor0 \
    libxkbcommon-x11-0 \
    libxcb-shape0 \
    libxcb-keysyms1 \
    libxcb-image0 \
    libxcb-render-util0 \
    libxcb-icccm4 \
    && rm -rf /var/lib/apt/lists/*

# Generate and set English locale so DingTalk defaults to English
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Download and install the DingTalk package
RUN wget -O /tmp/dingtalk.deb https://dtapp-pub.dingtalk.com/dingtalk-desktop/xc_dingtalk_update/linux_deb/Release/com.alibabainc.dingtalk_8.1.0.6021101_amd64.deb && \
    apt-get update && \
    apt-get install -y /tmp/dingtalk.deb && \
    rm /tmp/dingtalk.deb && \
    rm -rf /var/lib/apt/lists/*

# Generate Machine ID (Crucial for D-Bus and Chromium telemetry)
RUN dbus-uuidgen > /var/lib/dbus/machine-id && \
    cp /var/lib/dbus/machine-id /etc/machine-id && \
    mkdir -p /var/run/dbus

# Ubuntu 24.04 base image already has a user 'ubuntu' with UID 1000.
# We rename it to 'dingtalk' and set up the groups to fix volume permissions.
RUN usermod -l dingtalk -d /home/dingtalk -m ubuntu && \
    groupmod -n dingtalk ubuntu && \
    usermod -aG audio,video dingtalk

# Switch to the non-root user
USER dingtalk
WORKDIR /home/dingtalk

# Environment variables
ENV DISPLAY=:0
ENV QT_X11_NO_MITSHM=1

# Clean startup script leveraging the vendor's Elevator.sh wrapper
# 1. Explicitly export English locales so they aren't dropped by D-Bus.
# 2. Run Elevator.sh in the background (&) and keep the container alive (tail -f)
#    so DingTalk can safely restart itself without Docker killing the environment.
RUN echo '#!/bin/bash\n\
export XDG_RUNTIME_DIR=/home/dingtalk/xdg\n\
mkdir -p $XDG_RUNTIME_DIR && chmod 700 $XDG_RUNTIME_DIR\n\
export LANG=en_US.UTF-8\n\
export LANGUAGE=en_US:en\n\
export LC_ALL=en_US.UTF-8\n\
dbus-run-session bash -c "/opt/apps/com.alibabainc.dingtalk/files/Elevator.sh & tail -f /dev/null"\n\
' > /home/dingtalk/start.sh && chmod +x /home/dingtalk/start.sh

# Run the application
CMD ["/home/dingtalk/start.sh"]
