# YouCube Client

Client programs for ComputerCraft: Tweaked.

## Contents
- `src/` main client program and libraries
- `installer/` install scripts (Lua)
- `extras/wavestream/` WaveStream client utilities

## Quick Start (local)
1. Copy `src/youcube.lua` and `src/lib/` to your CC computer.
2. Run `youcube`.
3. Set `youcube.server` to your server WebSocket URL.

## Installer
The installer lives at `installer/src/installer.lua`. Host it (HTTP/pastebin) and replace `noshdotzip` in the installer scripts with your GitHub org/user.

## Legacy Docs
See `README.legacy.md` for upstream documentation (settings, events, older install flows).
