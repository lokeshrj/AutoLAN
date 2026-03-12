# AutoLAN

A macOS menu bar utility that automatically disables WiFi when ethernet is connected, and re-enables it when ethernet is disconnected.

## Features

- **Automatic WiFi toggling** — WiFi turns off when ethernet is plugged in, turns back on when unplugged
- **Sleep/wake aware** — Re-evaluates network state after your Mac wakes from sleep
- **Launch at Login** — Optional toggle from the menu bar
- **Lightweight** — Single-file Swift app, no Xcode project needed
- **Menu bar only** — Runs as an agent app with no Dock icon

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode Command Line Tools (`xcode-select --install`)

## Build

```bash
git clone https://github.com/lokeshrj/AutoLAN.git
cd AutoLAN
make build
```

The compiled app bundle will be at `build/AutoLAN.app`.

## Run

```bash
open build/AutoLAN.app
```

A menu bar icon will appear:
- **WiFi icon** — ethernet is disconnected, WiFi is active
- **Slashed antenna icon** — ethernet is connected, WiFi is disabled

Click the icon for status info, Launch at Login toggle, and Quit.

## Install

Copy to `/Applications/`:

```bash
make install
```

## How It Works

AutoLAN uses `NWPathMonitor` to watch for wired ethernet connections. When ethernet is detected, it disables WiFi via CoreWLAN (with a `networksetup` fallback). When ethernet is removed, WiFi is re-enabled.

On wake from sleep, it waits 3 seconds for network interfaces to reinitialize before re-evaluating.

## License

MIT
