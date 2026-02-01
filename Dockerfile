FROM ubuntu:22.04

# ============================================
# Build Arguments
# ============================================
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000
ARG TZ=America/Denver
ARG GHIDRA_VERSION=11.2.1
ARG GHIDRA_DATE=20241105
ARG RIZIN_VERSION=0.7.3

# ============================================
# Environment
# ============================================
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=${TZ}
ENV JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
ENV GHIDRA_HOME="/opt/ghidra"
ENV PATH="/opt/ghidra:${PATH}"

# ============================================
# Base System & Dev Tools
# ============================================
RUN apt-get update && apt-get install -y \
    # Essentials
    curl \
    wget \
    git \
    openssh-client \
    sudo \
    ca-certificates \
    gnupg \
    # Build tools
    build-essential \
    cmake \
    ninja-build \
    # Editors
    vim \
    nano \
    # Utilities
    jq \
    tree \
    htop \
    unzip \
    # Python
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# Node.js 20.x
# ============================================
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# GitHub CLI
# ============================================
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# Java 21 (required for Ghidra)
# ============================================
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# Ghidra - NSA Reverse Engineering Suite
# ============================================
RUN curl -fsSL -o /tmp/ghidra.zip \
    "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${GHIDRA_VERSION}_build/ghidra_${GHIDRA_VERSION}_PUBLIC_${GHIDRA_DATE}.zip" \
    && unzip /tmp/ghidra.zip -d /opt \
    && rm /tmp/ghidra.zip \
    && ln -s /opt/ghidra_${GHIDRA_VERSION}_PUBLIC /opt/ghidra

# ============================================
# Reverse Engineering CLI Tools
# ============================================
RUN apt-get update && apt-get install -y \
    # Binary analysis
    binwalk \
    foremost \
    hexedit \
    xxd \
    # Disassembly & debugging
    gdb \
    gdbserver \
    strace \
    ltrace \
    # ELF/binary utilities
    binutils \
    elfutils \
    patchelf \
    # Network analysis
    wireshark-common \
    tshark \
    nmap \
    netcat-openbsd \
    # Crypto tools
    hashcat \
    john \
    # Archive/filesystem tools
    file \
    p7zip-full \
    squashfs-tools \
    cpio \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# Rizin (modern radare2 fork)
# ============================================
RUN curl -fsSL https://github.com/rizinorg/rizin/releases/download/v${RIZIN_VERSION}/rizin-v${RIZIN_VERSION}-static-x86_64.tar.xz \
    | tar -xJ -C /usr/local --strip-components=1

# ============================================
# Python RE/Security Tools
# ============================================
RUN pip3 install --no-cache-dir --break-system-packages \
    # Exploit development
    pwntools \
    ropper \
    # Disassembly frameworks
    capstone \
    keystone-engine \
    # Emulation
    unicorn \
    # Symbolic execution
    angr \
    # Binary patching
    lief \
    # Forensics
    yara-python \
    # General analysis
    pyelftools \
    python-magic \
    # Firmware
    uefi-firmware-parser

# ============================================
# PlatformIO (embedded development)
# ============================================
RUN pip3 install --no-cache-dir --break-system-packages platformio

# ============================================
# Create non-root user
# ============================================
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# ============================================
# GEF - GDB Enhanced Features (user install)
# ============================================
USER ${USERNAME}
RUN curl -fsSL https://gef.blah.cat/sh | bash
USER root

# ============================================
# Claude Code (optional - comment out if not needed)
# ============================================
RUN npm install -g @anthropic-ai/claude-code@latest

# ============================================
# Workspace setup
# ============================================
RUN mkdir -p /workspace && chown ${USERNAME}:${USERNAME} /workspace
WORKDIR /workspace

# Switch to non-root user
USER ${USERNAME}

CMD ["bash"]
