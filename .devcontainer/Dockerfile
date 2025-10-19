# Debian base image (slim)
ARG ZIG_VERSION=0.15.2
ARG ZLS_VERSION=0.15.0


FROM debian:bookworm-slim

ARG ZIG_VERSION
ARG ZLS_VERSION


ENV DEBIAN_FRONTEND=noninteractive \
    PICO_SDK_PATH=/opt/pico-sdk \
    PICO_EXAMPLES_PATH=/opt/pico-examples \
    ZIG_ROOT=/usr/local/zig \
    MICROZIG_ROOT=/opt/microzig

# Install essential packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget git build-essential python3 python3-pip \
    unzip tar xz-utils ca-certificates pkg-config cmake ninja-build \
    gdb-multiarch openocd rsync jq \
    tio screen minicom \
    libudev-dev libusb-1.0-0-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Zig (official tarball)
RUN mkdir -p /tmp/zig && \
    ZIG_TARBALL="zig-x86_64-linux-${ZIG_VERSION}.tar.xz" && \
    curl -fsSL "https://ziglang.org/download/${ZIG_VERSION}/${ZIG_TARBALL}" -o /tmp/zig/${ZIG_TARBALL} && \
    mkdir -p ${ZIG_ROOT} && \
    tar -xJf /tmp/zig/${ZIG_TARBALL} -C /tmp/zig && \
    mv /tmp/zig/zig-x86_64-linux-${ZIG_VERSION}/* ${ZIG_ROOT}/ && \
    ln -s ${ZIG_ROOT}/zig /usr/local/bin/zig && \
    rm -rf /tmp/zig

# Install zls (language server)
RUN ZLS_ARCHIVE="/tmp/zls.tar.gz" && \
    ZLS_TARBALL=zls-x86_64-linux-${ZLS_VERSION}.tar.xz && \
    ZLS_URL=$(curl -sL "https://builds.zigtools.org/${ZLS_TARBALL}" | jq -r '.assets[] | select(.name|test("x86_64.*linux")) | .browser_download_url' ) || true && \
    if [ -n "$ZLS_URL" ]; then \
      curl -fsSL "$ZLS_URL" -o ${ZLS_ARCHIVE} && \
      mkdir -p /tmp/zls && tar -xzf ${ZLS_ARCHIVE} -C /tmp/zls && \
      mv /tmp/zls/zls /usr/local/bin/zls || mv /tmp/zls/*/zls /usr/local/bin/zls ; \
    else \
      echo "Could not determine ZLS URL at build time. Please install zls manually."; \
    fi && \
    chmod +x /usr/local/bin/zls || true && \
    rm -rf /tmp/zls*

# probe-rs installation:
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/probe-rs/probe-rs/releases/latest/download/probe-rs-tools-installer.sh | sh && \
    mv /root/.cargo/bin/probe-rs /usr/local/bin/ || true

# Clone Pico SDK and pico-examples into /opt
RUN git clone --depth=1 https://github.com/raspberrypi/pico-sdk.git ${PICO_SDK_PATH} && \
    git clone --depth=1 https://github.com/raspberrypi/pico-examples.git ${PICO_EXAMPLES_PATH} || true

# Make sure elf2uf2 is available (in pico-sdk tools)
ENV PATH="${PICO_SDK_PATH}/tools/elf2uf2:${PATH}"

# Create workspace and user
RUN useradd -m vscode && mkdir -p /workspace && chown -R vscode:vscode /workspace /opt/pico-sdk /opt/pico-examples

USER vscode
WORKDIR /workspace

# defaults
CMD [ "bash" ]
