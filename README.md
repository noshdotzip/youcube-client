# YouCube Client

Client programs for ComputerCraft: Tweaked.

## Contents
- `src/` main client program and libraries
- `installer/` install and cleanup scripts (Lua)
- `extras/wavestream/` WaveStream client utilities

## Setup
1. Install the client.
2. Set your server URL:
   - Run `youcube --server wss://your.server:5000`, or
   - Edit `/.youcube_server` with your URL (installer writes this).
   - If your CC version supports `settings`, `settings.set("youcube.server", "wss://your.server:5000")` also works.

## Features
- Auto-selects the largest attached monitor (falls back to terminal).
- Click to pause/resume (terminal or monitor).
- Optional progress bar: `youcube --progress` or `settings.set("youcube.progress", true)`.
- Server-side FPS downsample: `youcube --server-fps 15`.
- Optional playback FPS override: `youcube --fps 15`.
- If both are set, `--server-fps` controls conversion and `--fps` controls playback timing.

## Installer
- Install bootstrap: `installer/src/pastebin_installer.lua`
- Cleanup bootstrap: `installer/src/pastebin_cleanup.lua`

## Server Docs
https://github.com/noshdotzip/youcube-server#readme

## Legacy Docs
See `README.legacy.md` for upstream documentation (settings, events, older install flows).
