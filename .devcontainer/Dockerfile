FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    python3 \
    python3-pip \
    pkg-config \
    libusb-1.0-0-dev \
    libudev-dev \  
    udev \
    gdb-multiarch \
    minicom \
    openocd \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod +x /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

# Install Zig 0.15.1
ARG ZIG_VERSION=0.15.1
RUN wget https://ziglang.org/download/${ZIG_VERSION}/zig-x86_64-linux-${ZIG_VERSION}.tar.xz \
    && tar -xf zig-x86_64-linux-${ZIG_VERSION}.tar.xz \
    && mv zig-x86_64-linux-${ZIG_VERSION} /usr/local/zig \
    && ln -s /usr/local/zig/zig /usr/local/bin/zig \
    && rm zig-x86_64-linux-${ZIG_VERSION}.tar.xz

    # Install ZLS (Zig Language Server) - matching version
RUN wget https://github.com/zigtools/zls/releases/download/0.15.0/zls-aarch64-linux.tar.xz  \
    && tar -xf zls-aarch64-linux.tar.xz  \
    && mv zls /usr/local/bin/zls \
    && chmod +x /usr/local/bin/zls \
    && rm zls-aarch64-linux.tar.xz 

# Install pico-sdk (required for picotool)
RUN git clone https://github.com/raspberrypi/pico-sdk.git /opt/pico-sdk \
    && cd /opt/pico-sdk \
    && git submodule update --init

# Set environment variable for subsequent RUN commands
ENV PICO_SDK_PATH=/opt/pico-sdk

# Install picotool (needs PICO_SDK_PATH set)
RUN git clone https://github.com/raspberrypi/picotool.git /tmp/picotool \
    && cd /tmp/picotool \
    && git submodule update --init \
    && mkdir build && cd build \
    && PICO_SDK_PATH=/opt/pico-sdk cmake .. \
    && make -j$(nproc) \
    && make install \
    && cd / && rm -rf /tmp/picotool

# Setup udev rules for Pico access
RUN echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e8a", MODE:="0666"' > /etc/udev/rules.d/99-pico.rules

# Configure OpenOCD for RP2040
RUN mkdir -p /home/$USERNAME/.config/openocd

# Switch to non-root user
USER $USERNAME
WORKDIR /workspace

# Verify installations
RUN zig version