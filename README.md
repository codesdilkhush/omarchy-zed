# Zed Integration for Omarchy

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Zed Editor status bar widget and live theme synchronization for Omarchy on Hyprland.

![Zed Plugin Preview](preview.png)

## Features

- **Live Theme Synchronization**: Automatically syncs Zed editor colors with your Omarchy palette in real time via Omazed (`~/.config/zed/themes/omazed.json`).
- **Interactive Top Bar Widget**: Minimalist code icon (`</>`) showing real-time running state, active Omarchy theme, and sync status.
- **Window Management**: Click to focus the running Zed instance or launch Zed. Middle-click to quickly spawn a new workspace window.
- **Quick Popup Actions**: Right-click to toggle the interactive card to launch/focus, spawn a new window, or trigger theme sync.

## Installation

Install directly using the Omarchy CLI:

```bash
omarchy plugin add https://github.com/codesdilkhush/omarchy-zed --enable
```

## Removal

```bash
omarchy plugin remove codesdilkhush.zed
```

## License

MIT License. See [LICENSE](LICENSE) for details.
