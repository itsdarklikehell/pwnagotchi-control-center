# pwnagotchi-control-center

[![CI](https://github.com/itsdarklikehell/pwnagotchi-control-center/actions/workflows/ci.yml/badge.svg)](https://github.com/itsdarklikehell/pwnagotchi-control-center/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/itsdarklikehell/pwnagotchi-control-center)](LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

A menu-driven control center for managing a [pwnagotchi](https://github.com/evilsocket/pwnagotchi) device. Provides scripts to:

- **Local operations**: Flash/backup SD cards, edit config.toml, download pwnagotchi images
- **Remote operations**: Setup SSH connections (USB/Ethernet, Bluetooth PAN, Ethernet, WLAN AP), manage plugins, install SecLists, modify remote configs

## Prerequisites

- `whiptail` (menu dialogs)
- `wget`, `unzip` (download/extract images)
- `dd`, `mount`, `umount` (SD card operations)
- `ssh` (remote operations)
- `sudo` access (for mounting, iptables, etc.)
- `bats` (for running tests, optional)

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/itsdarklikehell/pwnagotchi-control-center.git
   cd pwnagotchi-control-center
   ```

2. Edit `.config/config` to match your setup:
   ```bash
   nano .config/config
   ```

3. Run the main menu:
   ```bash
   ./menu.sh
   ```

## Configuration

All settings are in `.config/config`. Key variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `BACKUP_DIR` | Directory for backups | `$PWD/Backups` |
| `SD_DEVICE` | SD card device path | `/dev/sdc` |
| `ROOT_MOUNT_DIR` | Root partition mount point | `/media/usb0` |
| `BOOT_MOUNT_DIR` | Boot partition mount point | `/media/usb1` |
| `PWNAGOTCHI_USERNAME` | SSH username | `pi` |
| `PWNAGOTCHI_HOSTNAME` | Device hostname | `wifikirby` |
| `PWNAGOTCHI_VERSION` | Image version to download | `v1.5.5` |
| `PWNAGOTCHI_BTIP` | Bluetooth IP | `10.0.0.2` |
| `PWNAGOTCHI_USBIP` | USB IP | `10.0.0.2` |
| `PWNAGOTCHI_ETHIP` | Ethernet IP | `192.168.1.6` |
| `PWNAGOTCHI_WLANIP` | WLAN IP | `192.168.1.6` |
| `CUSTOM_PLUGIN_DIR` | Custom plugins path | `/home/pi/pwnagotchi-control-center/pwnagotchi-plugins-contrib` |
| `HANDSHAKE_DIR` | Handshakes directory | `/root/handshakes` |
| `CURR_CONN` | Current connection type (set by setup scripts) | `""` (empty) |

## Usage

### Local Scripts (`Scripts/Local/`)

| Script | Description |
|--------|-------------|
| `download.sh` | Download pwnagotchi image |
| `flash.sh` | Flash image to SD card |
| `backup.sh` | Backup SD card to image |
| `pull-files.sh` | Extract files from SD card |
| `push-files.sh` | Copy files to SD card |
| `modconf.sh` | Edit config.toml on SD card |

### Remote Scripts (`Scripts/Remote/`)

| Script | Description |
|--------|-------------|
| `setup-conn-usb.sh` | Setup USB-Ethernet gadget connection |
| `setup-conn-bt.sh` | Setup Bluetooth PAN connection |
| `setup-conn-eth.sh` | Setup Ethernet connection |
| `setup-conn-wlan.sh` | Setup WLAN AP connection |
| `mod-pwnagotchi-conf.sh` | Edit remote config.toml |
| `mod-plugin-conf.sh` | Edit remote plugin config |
| `install-seclists.sh` | Install SecLists wordlists |
| `plugin-install.sh` | Install a plugin |
| `plugin-enable.sh` | Enable a plugin |
| `plugin-disable.sh` | Disable a plugin |
| `reboot.sh` | Reboot the pwnagotchi |

## Connection Setup

The connection setup scripts configure IP forwarding and NAT to share your internet connection with the pwnagotchi. They support:

- **USB-Ethernet gadget**: Connect via USB, appears as `enx*` interface
- **Bluetooth PAN**: Connect via Bluetooth, appears as `bnep*` interface
- **Ethernet**: Direct Ethernet connection
- **WLAN AP**: Connect to pwnagotchi's access point

Each script will:
1. Ask for the interface name
2. Validate the interface exists
3. Configure IP forwarding and NAT
4. Test connectivity

## Features

- **Logging**: All scripts log to `logs/` directory with timestamps
- **Dependency checks**: Scripts verify required tools are installed before running
- **Error handling**: `set -euo pipefail` and trap-based cleanup on all scripts
- **Safe file operations**: `cp -r` for directories, `mkdir -p` for parent creation
- **Editor fallback**: Uses `$EDITOR` environment variable, falls back to `nano`
- **Connection state**: `CURR_CONN` variable tracks active connection type

## Testing

Run the test suite with [bats](https://github.com/bats-core/bats-core):

```bash
# Install bats (if not already installed)
sudo apt install bats

# Run all tests
bats tests/

# Run with verbose output
bats --verbose-run tests/
```

The test suite covers:
- Script existence and executability
- Shebang and `set -euo pipefail` compliance
- Configuration file validation
- Dependency checks
- Function presence (validate_iface, MOUNT, UNMOUNT, etc.)
- Menu option completeness
- Error handling patterns

## Security

- All scripts use `set -euo pipefail` for strict error handling
- Temporary files are cleaned up via trap handlers
- No hardcoded credentials — all configuration in `.config/config`
- SSH operations use key-based authentication (configure in `.ssh/config`)
- `sudo` operations are limited to specific commands

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Code of Conduct

This project adheres to the [Contributor Covenant](CODE_OF_CONDUCT.md) Code of Conduct.

## Support

For support, please open an issue on GitHub or refer to [SUPPORT.md](SUPPORT.md).

## See: (references)

---

## Gource Visualization

De ontwikkelhistorie van dit project in een film:

<video src="https://raw.githubusercontent.com/itsdarklikehell/pwnagotchi-control-center/main/gource.mp4" controls width="100%"></video>

*De video wordt automatisch gegenereerd door de [Gource workflow](.github/workflows/gource.yml) bij elke push.*

Lokale video genereren:
```bash
gource --max-files 1000 --key -800x600 \
  --highlight-users --filename-time 3 --output-framerate 25 \
  -s 0.6 --multi-sampling --auto-skip-seconds 0.1 \
  --stop-at-end --hide mouse,progress -o gource.ppm
ffmpeg -y -r 15 -f image2pipe -vcodec ppm -i gource.ppm \
  -vcodec libx264 -preset medium -pix_fmt yuv420p \
  -crf 1 -threads 0 -bf 0 gource.mp4
```
