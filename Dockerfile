# Extends claude-code-sandbox with RE and embedded development tools
# Build base first: cd claude-code-sandbox && docker build -t claude-code-sandbox:latest docker/
FROM claude-code-sandbox:latest

# ============================================
# Build Arguments
# ============================================
ARG TZ=America/Denver
ARG GHIDRA_VERSION=11.2.1
ARG GHIDRA_DATE=20241105
ARG RIZIN_VERSION=0.7.3
ARG PMD_VERSION=7.21.0

# ============================================
# Switch to root for package installation
# ============================================
USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=${TZ}
ENV JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
ENV GHIDRA_HOME="/opt/ghidra"
ENV GHIDRA_DIR="/opt/ghidra"
ENV VOLTA_HOME="/home/claude/.volta"
ENV PATH="${VOLTA_HOME}/bin:/opt/pmd/bin:/opt/ghidra:${PATH}"

# ============================================
# GCC 13 (Ubuntu 22.04 ships with GCC 11)
# ============================================
RUN apt-get update && apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
    && apt-get update && apt-get install -y \
    gcc-13 \
    g++-13 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100 \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# Java 21 + unzip (required for Ghidra)
# ============================================
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    unzip \
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
    # JSON processing
    jq \
    # Build tools
    cmake \
    ninja-build \
    # Language servers
    clangd \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# Application Development Dependencies
# ============================================
RUN apt-get update && apt-get install -y \
    # Qt5 for GUI applications (kuminz-ui)
    qtbase5-dev \
    # PostgreSQL client (e2m-db)
    postgresql-client \
    # Graph visualization (dot, neato, etc.)
    graphviz \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# PMD - Static Code Analysis
# ============================================
RUN curl -fsSL -o /tmp/pmd.zip \
    "https://github.com/pmd/pmd/releases/download/pmd_releases%2F${PMD_VERSION}/pmd-dist-${PMD_VERSION}-bin.zip" \
    && unzip /tmp/pmd.zip -d /opt \
    && rm /tmp/pmd.zip \
    && ln -s /opt/pmd-bin-${PMD_VERSION} /opt/pmd

# ============================================
# Rizin (modern radare2 fork)
# ============================================
RUN curl -fsSL https://github.com/rizinorg/rizin/releases/download/v${RIZIN_VERSION}/rizin-v${RIZIN_VERSION}-static-x86_64.tar.xz \
    | tar -xJ -C /usr/local --strip-components=1

# ============================================
# Python RE/Security Tools
# ============================================
RUN pip3 install --no-cache-dir \
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
    python-magic

# ============================================
# PlatformIO (embedded development)
# ============================================
RUN pip3 install --no-cache-dir platformio

# ============================================
# Cozempic - Claude Code Context Cleaner
# ============================================
RUN pip3 install --no-cache-dir cozempic

# Pre-install common platforms (optional, adds ~1GB but faster first build)
# RUN pio pkg install -g -p espressif32
# RUN pio pkg install -g -p teensy

# ============================================
# Node.js Global Tools
# ============================================
ARG NPM_CACHE_BUST
RUN npm install -g c-next vitest typescript-language-server typescript tsx

# ============================================
# GEF - GDB Enhanced Features (install as claude user)
# ============================================
USER claude
RUN curl -fsSL https://gef.blah.cat/sh | bash

# ============================================
# Volta - JavaScript Tool Manager
# ============================================
RUN curl -fsSL https://get.volta.sh | bash
RUN volta install node

# Stay as claude user (matches base image)
