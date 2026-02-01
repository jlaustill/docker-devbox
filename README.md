# Docker Devbox

A comprehensive development container with reverse engineering, embedded development, and AI coding tools.

## What's Included

| Category | Tools |
|----------|-------|
| **RE Suite** | Ghidra 11.2.1, Rizin 0.7.3 |
| **Debugging** | GDB + GEF, strace, ltrace |
| **Binary Analysis** | binwalk, foremost, patchelf, elfutils, xxd, hexedit |
| **Python RE** | pwntools, angr, capstone, unicorn, ropper, LIEF, yara |
| **Network** | tshark, nmap, netcat |
| **Crypto** | hashcat, john |
| **Embedded** | PlatformIO, cmake, ninja |
| **AI Coding** | Claude Code |
| **Dev Tools** | Node.js 20, Python 3, GitHub CLI |

## Quick Start

```bash
# Build the image (uses your UID/GID for file permissions)
./build.sh

# Run interactively
docker run -it --rm -v $(pwd):/workspace docker-devbox:latest

# Run with GUI support (for Ghidra)
docker run -it --rm \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $(pwd):/workspace \
    docker-devbox:latest
```

## Customization

### Build Arguments

| Arg | Default | Description |
|-----|---------|-------------|
| `USERNAME` | dev | Container username |
| `USER_UID` | 1000 | User ID (for file permissions) |
| `USER_GID` | 1000 | Group ID |
| `TZ` | America/Denver | Timezone |
| `GHIDRA_VERSION` | 11.2.1 | Ghidra version |
| `RIZIN_VERSION` | 0.7.3 | Rizin version |

### Custom Build

```bash
docker build \
    --build-arg TZ=Europe/London \
    --build-arg USERNAME=myuser \
    -t my-devbox .
```

## Usage Examples

### Ghidra (headless analysis)
```bash
analyzeHeadless /workspace/ghidra_project MyProject -import binary.exe -postScript analyze.py
```

### Rizin
```bash
rizin -A ./binary    # Analyze binary
rizin -d ./binary    # Debug mode
```

### PlatformIO
```bash
pio init --board esp32dev
pio run
pio run --target upload
```

### pwntools
```python
from pwn import *
elf = ELF('./binary')
p = process('./binary')
```

## Pre-installing PlatformIO Platforms

Uncomment in Dockerfile to pre-install (adds ~1GB per platform):

```dockerfile
RUN pio pkg install -g -p espressif32
RUN pio pkg install -g -p teensy
```
