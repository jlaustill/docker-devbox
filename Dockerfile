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

# ============================================
# Switch to root for package installation
# ============================================
USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=${TZ}
ENV JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
ENV GHIDRA_HOME="/opt/ghidra"
ENV PATH="/opt/ghidra:${PATH}"

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
    # Build tools
    cmake \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

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

# Pre-install common platforms (optional, adds ~1GB but faster first build)
# RUN pio pkg install -g -p espressif32
# RUN pio pkg install -g -p teensy

# ============================================
# GEF - GDB Enhanced Features (install as claude user)
# ============================================
USER claude
RUN curl -fsSL https://gef.blah.cat/sh | bash

# Stay as claude user (matches base image)
