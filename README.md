# Docker Devbox

Extends [claude-code-sandbox](https://github.com/jlaustill/claude-code-sandbox) with reverse engineering and embedded development tools.

## What's Added

| Category | Tools |
|----------|-------|
| **RE Suite** | Ghidra 11.2.1, Rizin 0.7.3 |
| **Debugging** | GDB + GEF, strace, ltrace |
| **Binary Analysis** | binwalk, foremost, patchelf, elfutils, xxd, hexedit |
| **Python RE** | pwntools, angr, capstone, unicorn, ropper, LIEF, yara |
| **Network** | tshark, nmap, netcat |
| **Crypto** | hashcat, john |
| **Embedded** | PlatformIO, cmake, ninja |

## Prerequisites

Build the base image first:

```bash
cd ~/code/claude-code-sandbox
docker build -t claude-code-sandbox:latest docker/
```

## Quick Start

```bash
# Build devbox
./build.sh

# Or manually
docker build -t docker-devbox:latest .
```

## Build Arguments

| Arg | Default | Description |
|-----|---------|-------------|
| `TZ` | America/Denver | Timezone |
| `GHIDRA_VERSION` | 11.2.1 | Ghidra version |
| `RIZIN_VERSION` | 0.7.3 | Rizin version |

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
