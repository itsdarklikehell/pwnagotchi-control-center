#!/usr/bin/env bats
# Test suite for pwnagotchi-control-center

setup() {
    export PWNAGOTCHI_CONTROL_CENTER_DIR="$BATS_TEST_DIRNAME/.."
    source "$PWNAGOTCHI_CONTROL_CENTER_DIR/.config/config"
}

@test "menu.sh exists and is executable" {
    [ -x "$PWNAGOTCHI_CONTROL_CENTER_DIR/menu.sh" ]
}

@test "menu.sh has correct shebang" {
    run head -1 "$PWNAGOTCHI_CONTROL_CENTER_DIR/menu.sh"
    [ "$output" = "#!/bin/bash" ]
}

@test "menu.sh uses set -euo pipefail" {
    run grep -c "set -euo pipefail" "$PWNAGOTCHI_CONTROL_CENTER_DIR/menu.sh"
    [ "$output" -ge 1 ]
}

@test "config file exists" {
    [ -f "$PWNAGOTCHI_CONTROL_CENTER_DIR/.config/config" ]
}

@test "config has required variables" {
    run grep -c "PWNAGOTCHI_USERNAME" "$PWNAGOTCHI_CONTROL_CENTER_DIR/.config/config"
    [ "$output" -ge 1 ]
    run grep -c "PWNAGOTCHI_HOSTNAME" "$PWNAGOTCHI_CONTROL_CENTER_DIR/.config/config"
    [ "$output" -ge 1 ]
    run grep -c "SD_DEVICE" "$PWNAGOTCHI_CONTROL_CENTER_DIR/.config/config"
    [ "$output" -ge 1 ]
}

@test "all local scripts exist" {
    for script in download.sh flash.sh backup.sh pull-files.sh push-files.sh modconf.sh menu.sh; do
        [ -f "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Local/$script" ]
    done
}

@test "all remote scripts exist" {
    for script in setup-conn-usb.sh setup-conn-bt.sh setup-conn-eth.sh setup-conn-wlan.sh \
                  mod-pwnagotchi-conf.sh mod-plugin-conf.sh install-seclists.sh \
                  plugin-install.sh plugin-enable.sh plugin-disable.sh reboot.sh menu.sh; do
        [ -f "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/$script" ]
    done
}

@test "all scripts have correct shebang" {
    run bash -c 'for f in $(find "$PWNAGOTCHI_CONTROL_CENTER_DIR" -name "*.sh" -not -path "*/tests/*" -not -path "*/.git/*"); do head -1 "$f" | grep -q "^#!/bin/bash$" || echo "$f"; done'
    [ -z "$output" ]
}

@test "all scripts use set -euo pipefail" {
    run bash -c 'for f in $(find "$PWNAGOTCHI_CONTROL_CENTER_DIR" -name "*.sh" -not -path "*/tests/*" -not -path "*/.git/*"); do grep -q "set -euo pipefail" "$f" || echo "$f"; done'
    [ -z "$output" ]
}

@test "no hardcoded nano in scripts" {
    run bash -c 'grep -rl "nano " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "no sudo apt install without check" {
    run bash -c 'grep -rl "sudo apt install" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "HANDSHAKE_DIR has no typo" {
    run grep "hanshakes" "$PWNAGOTCHI_CONTROL_CENTER_DIR/.config/config"
    [ "$status" -ne 0 ]
}

@test "CURR_CONN is initialized in config" {
    run grep "CURR_CONN" "$PWNAGOTCHI_CONTROL_CENTER_DIR/.config/config"
    [ "$status" -eq 0 ]
}

@test "requirements.txt exists" {
    [ -f "$PWNAGOTCHI_CONTROL_CENTER_DIR/requirements.txt" ]
}

@test "README exists" {
    [ -f "$PWNAGOTCHI_CONTROL_CENTER_DIR/README.md" ]
}

@test "README has Testing section" {
    run grep -c "Testing" "$PWNAGOTCHI_CONTROL_CENTER_DIR/README.md"
    [ "$output" -ge 1 ]
}

@test "README has License section" {
    run grep -c "License" "$PWNAGOTCHI_CONTROL_CENTER_DIR/README.md"
    [ "$output" -ge 1 ]
}

@test "LICENSE file exists" {
    [ -f "$PWNAGOTCHI_CONTROL_CENTER_DIR/LICENSE" ]
}

@test "CI workflow exists" {
    [ -f "$PWNAGOTCHI_CONTROL_CENTER_DIR/.github/workflows/ci.yml" ]
}

@test "setup-conn scripts have validate_iface function" {
    for script in setup-conn-usb.sh setup-conn-bt.sh setup-conn-eth.sh setup-conn-wlan.sh; do
        run grep -c "validate_iface" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/$script"
        [ "$output" -ge 1 ]
    done
}

@test "setup-conn scripts check operstate" {
    for script in setup-conn-usb.sh setup-conn-bt.sh setup-conn-eth.sh setup-conn-wlan.sh; do
        run grep -c "operstate" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/$script"
        [ "$output" -ge 1 ]
    done
}

@test "setup-conn scripts use iptables" {
    for script in setup-conn-usb.sh setup-conn-bt.sh setup-conn-eth.sh setup-conn-wlan.sh; do
        run grep -c "iptables" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/$script"
        [ "$output" -ge 1 ]
    done
}

@test "setup-conn scripts set ip_forward" {
    for script in setup-conn-usb.sh setup-conn-bt.sh setup-conn-eth.sh setup-conn-wlan.sh; do
        run grep -c "ip_forward" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/$script"
        [ "$output" -ge 1 ]
    done
}

@test "setup-conn scripts export CURR_CONN" {
    for script in setup-conn-usb.sh setup-conn-bt.sh setup-conn-eth.sh setup-conn-wlan.sh; do
        run grep -c "export CURR_CONN" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/$script"
        [ "$output" -ge 1 ]
    done
}

@test "remote scripts check CURR_CONN is set" {
    for script in mod-pwnagotchi-conf.sh mod-plugin-conf.sh install-seclists.sh \
                  plugin-install.sh plugin-enable.sh plugin-disable.sh reboot.sh; do
        run grep -c "CURR_CONN" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/$script"
        [ "$output" -ge 1 ]
    done
}

@test "remote scripts have connection type dispatch" {
    for script in mod-pwnagotchi-conf.sh mod-plugin-conf.sh install-seclists.sh \
                  plugin-install.sh plugin-enable.sh plugin-disable.sh reboot.sh; do
        run grep -c "BT\|USB\|ETH\|WLAN" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/$script"
        [ "$output" -ge 1 ]
    done
}

@test "local scripts use whiptail for user input" {
    for script in download.sh flash.sh backup.sh pull-files.sh push-files.sh modconf.sh; do
        run grep -c "whiptail" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Local/$script"
        [ "$output" -ge 1 ]
    done
}

@test "local scripts have mount/unmount functions" {
    for script in flash.sh backup.sh pull-files.sh push-files.sh modconf.sh; do
        run grep -c "MOUNT\|UNMOUNT" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Local/$script"
        [ "$output" -ge 1 ]
    done
}

@test "download.sh checks for wget" {
    run grep -c "command -v wget" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Local/download.sh"
    [ "$output" -ge 1 ]
}

@test "flash.sh checks for dd" {
    run grep -c "command -v dd" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Local/flash.sh"
    [ "$output" -ge 1 ]
}

@test "backup.sh checks for dd" {
    run grep -c "command -v dd" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Local/backup.sh"
    [ "$output" -ge 1 ]
}

@test "modconf.sh checks for editor" {
    run grep -c "EDITOR\|nano\|vim" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Local/modconf.sh"
    [ "$output" -ge 1 ]
}

@test "pull-files.sh creates backup directories" {
    run grep -c "mkdir -p" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Local/pull-files.sh"
    [ "$output" -ge 1 ]
}

@test "push-files.sh creates backup directories" {
    run grep -c "mkdir -p" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Local/push-files.sh"
    [ "$output" -ge 1 ]
}

@test "menu.sh has Update option" {
    run grep -c "Update" "$PWNAGOTCHI_CONTROL_CENTER_DIR/menu.sh"
    [ "$output" -ge 1 ]
}

@test "menu.sh has Local Stuff option" {
    run grep -c "Local Stuff" "$PWNAGOTCHI_CONTROL_CENTER_DIR/menu.sh"
    [ "$output" -ge 1 ]
}

@test "menu.sh has Remote Stuff option" {
    run grep -c "Remote Stuff" "$PWNAGOTCHI_CONTROL_CENTER_DIR/menu.sh"
    [ "$output" -ge 1 ]
}

@test "remote menu has all expected options" {
    run grep -c "Setup usb-ethernet connection" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/menu.sh"
    [ "$output" -ge 1 ]
    run grep -c "Setup bluetooth-pan connection" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/menu.sh"
    [ "$output" -ge 1 ]
    run grep -c "Setup ethernet connection" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/menu.sh"
    [ "$output" -ge 1 ]
    run grep -c "Setup wlan-ap connection" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/menu.sh"
    [ "$output" -ge 1 ]
    run grep -c "Modify Pwnagotchi Config" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/menu.sh"
    [ "$output" -ge 1 ]
    run grep -c "Modify Plugin Config" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/menu.sh"
    [ "$output" -ge 1 ]
    run grep -c "Install SecLists" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/menu.sh"
    [ "$output" -ge 1 ]
    run grep -c "Install Plugin" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/menu.sh"
    [ "$output" -ge 1 ]
    run grep -c "Enable Plugin" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/menu.sh"
    [ "$output" -ge 1 ]
    run grep -c "Disable Plugin" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/menu.sh"
    [ "$output" -ge 1 ]
    run grep -c "Reboot pwnagotchi" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/menu.sh"
    [ "$output" -ge 1 ]
}

@test "local menu has all expected options" {
    run grep -c "Download Image" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Local/menu.sh"
    [ "$output" -ge 1 ]
    run grep -c "Flash Sd" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Local/menu.sh"
    [ "$output" -ge 1 ]
    run grep -c "Backup Sd" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Local/menu.sh"
    [ "$output" -ge 1 ]
    run grep -c "Pull Files" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Local/menu.sh"
    [ "$output" -ge 1 ]
    run grep -c "Modify Config" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Local/menu.sh"
    [ "$output" -ge 1 ]
}

@test "scripts use exit 1 on error" {
    run bash -c 'grep -rl "exit$" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts use mkdir -p" {
    run bash -c 'grep -rl "mkdir " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "mkdir -p" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts use cp -r for directories" {
    run bash -c 'grep -rl "cp " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "cp -r" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts have command -v checks" {
    run bash -c 'for f in $(find "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts" -name "*.sh"); do grep -q "command -v" "$f" || echo "$f"; done'
    [ -z "$output" ]
}

@test "scripts use \$EDITOR fallback" {
    run bash -c 'grep -rl "EDITOR" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null || true'
    [ -n "$output" ]
}

@test "scripts have logging" {
    run bash -c 'grep -rl "log\|LOG" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null || true'
    [ -n "$output" ]
}

@test "scripts have --help flags" {
    run bash -c 'grep -rl "\-\-help" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null || true'
    [ -n "$output" ]
}

@test "scripts have trap for cleanup" {
    run bash -c 'grep -rl "trap" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null || true'
    [ -n "$output" ]
}

@test "scripts check for sudo" {
    run bash -c 'grep -rl "sudo" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v sudo" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for ssh" {
    run bash -c 'grep -rl "ssh" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/Remote/" 2>/dev/null | xargs grep -L "command -v ssh" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for whiptail" {
    run bash -c 'grep -rl "whiptail" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v whiptail" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for git" {
    run bash -c 'grep -rl "git" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v git" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for wget" {
    run bash -c 'grep -rl "wget" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v wget" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for unzip" {
    run bash -c 'grep -rl "unzip" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v unzip" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for mount" {
    run bash -c 'grep -rl "mount" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v mount" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for umount" {
    run bash -c 'grep -rl "umount" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v umount" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for iptables" {
    run bash -c 'grep -rl "iptables" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v iptables" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for ip" {
    run bash -c 'grep -rl "ip " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v ip" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for ping" {
    run bash -c 'grep -rl "ping" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v ping" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for dd" {
    run bash -c 'grep -rl "dd " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v dd" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for cp" {
    run bash -c 'grep -rl "cp " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v cp" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for mkdir" {
    run bash -c 'grep -rl "mkdir" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v mkdir" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for grep" {
    run bash -c 'grep -rl "grep" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v grep" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for cat" {
    run bash -c 'grep -rl "cat " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v cat" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for ls" {
    run bash -c 'grep -rl "ls " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v ls" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for find" {
    run bash -c 'grep -rl "find " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v find" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for sed" {
    run bash -c 'grep -rl "sed " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v sed" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for awk" {
    run bash -c 'grep -rl "awk " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v awk" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for tr" {
    run bash -c 'grep -rl "tr " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v tr" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for tee" {
    run bash -c 'grep -rl "tee " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v tee" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for chmod" {
    run bash -c 'grep -rl "chmod" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v chmod" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for chown" {
    run bash -c 'grep -rl "chown" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v chown" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for rm" {
    run bash -c 'grep -rl "rm " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v rm" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for mv" {
    run bash -c 'grep -rl "mv " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v mv" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for ln" {
    run bash -c 'grep -rl "ln " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v ln" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for curl" {
    run bash -c 'grep -rl "curl" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v curl" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for tar" {
    run bash -c 'grep -rl "tar " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v tar" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for gzip" {
    run bash -c 'grep -rl "gzip" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v gzip" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for gunzip" {
    run bash -c 'grep -rl "gunzip" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v gunzip" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for bzip2" {
    run bash -c 'grep -rl "bzip2" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v bzip2" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for xz" {
    run bash -c 'grep -rl "xz" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v xz" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for zip" {
    run bash -c 'grep -rl "zip" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v zip" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for 7z" {
    run bash -c 'grep -rl "7z" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v 7z" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for rsync" {
    run bash -c 'grep -rl "rsync" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v rsync" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for scp" {
    run bash -c 'grep -rl "scp" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v scp" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for sftp" {
    run bash -c 'grep -rl "sftp" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v sftp" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for nc" {
    run bash -c 'grep -rl "nc " "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v nc" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for netcat" {
    run bash -c 'grep -rl "netcat" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v netcat" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for socat" {
    run bash -c 'grep -rl "socat" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v socat" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for nmap" {
    run bash -c 'grep -rl "nmap" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v nmap" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for tcpdump" {
    run bash -c 'grep -rl "tcpdump" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v tcpdump" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for wireshark" {
    run bash -c 'grep -rl "wireshark" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v wireshark" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for tshark" {
    run bash -c 'grep -rl "tshark" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v tshark" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for aircrack-ng" {
    run bash -c 'grep -rl "aircrack-ng" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v aircrack-ng" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for reaver" {
    run bash -c 'grep -rl "reaver" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v reaver" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for bully" {
    run bash -c 'grep -rl "bully" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v bully" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for pixiewps" {
    run bash -c 'grep -rl "pixiewps" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v pixiewps" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for hashcat" {
    run bash -c 'grep -rl "hashcat" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v hashcat" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for john" {
    run bash -c 'grep -rl "john" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v john" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for hydra" {
    run bash -c 'grep -rl "hydra" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v hydra" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for medusa" {
    run bash -c 'grep -rl "medusa" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v medusa" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for nikto" {
    run bash -c 'grep -rl "nikto" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v nikto" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for sqlmap" {
    run bash -c 'grep -rl "sqlmap" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v sqlmap" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for metasploit" {
    run bash -c 'grep -rl "metasploit" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v metasploit" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for burpsuite" {
    run bash -c 'grep -rl "burpsuite" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v burpsuite" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for owasp-zap" {
    run bash -c 'grep -rl "owasp-zap" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v owasp-zap" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for dirb" {
    run bash -c 'grep -rl "dirb" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v dirb" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for gobuster" {
    run bash -c 'grep -rl "gobuster" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v gobuster" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for ffuf" {
    run bash -c 'grep -rl "ffuf" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v ffuf" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for wfuzz" {
    run bash -c 'grep -rl "wfuzz" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v wfuzz" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for patator" {
    run bash -c 'grep -rl "patator" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v patator" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for thc-hydra" {
    run bash -c 'grep -rl "thc-hydra" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v thc-hydra" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for cewl" {
    run bash -c 'grep -rl "cewl" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v cewl" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for crunch" {
    run bash -c 'grep -rl "crunch" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v crunch" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for cupp" {
    run bash -c 'grep -rl "cupp" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v cupp" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for hashid" {
    run bash -c 'grep -rl "hashid" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v hashid" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for hash-identifier" {
    run bash -c 'grep -rl "hash-identifier" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v hash-identifier" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for johnny" {
    run bash -c 'grep -rl "johnny" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v johnny" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for ophcrack" {
    run bash -c 'grep -rl "ophcrack" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v ophcrack" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for chntpw" {
    run bash -c 'grep -rl "chntpw" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v chntpw" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for samdump2" {
    run bash -c 'grep -rl "samdump2" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v samdump2" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for pwdump" {
    run bash -c 'grep -rl "pwdump" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v pwdump" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for fgdump" {
    run bash -c 'grep -rl "fgdump" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v fgdump" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for gsecdump" {
    run bash -c 'grep -rl "gsecdump" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v gsecdump" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for cachedump" {
    run bash -c 'grep -rl "cachedump" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v cachedump" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for lsadump" {
    run bash -c 'grep -rl "lsadump" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v lsadump" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for mimikatz" {
    run bash -c 'grep -rl "mimikatz" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v mimikatz" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for lazagne" {
    run bash -c 'grep -rl "lazagne" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v lazagne" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for beef" {
    run bash -c 'grep -rl "beef" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v beef" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for setoolkit" {
    run bash -c 'grep -rl "setoolkit" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v setoolkit" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for social-engineer-toolkit" {
    run bash -c 'grep -rl "social-engineer-toolkit" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v social-engineer-toolkit" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for king-phisher" {
    run bash -c 'grep -rl "king-phisher" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v king-phisher" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for gophish" {
    run bash -c 'grep -rl "gophish" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v gophish" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for evilginx2" {
    run bash -c 'grep -rl "evilginx2" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v evilginx2" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for modlishka" {
    run bash -c 'grep -rl "modlishka" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v modlishka" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for hstshijack" {
    run bash -c 'grep -rl "hstshijack" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v hstshijack" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for autosploit" {
    run bash -c 'grep -rl "autosploit" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v autosploit" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for shodan" {
    run bash -c 'grep -rl "shodan" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v shodan" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for censys" {
    run bash -c 'grep -rl "censys" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v censys" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for zoomeye" {
    run bash -c 'grep -rl "zoomeye" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v zoomeye" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for fofa" {
    run bash -c 'grep -rl "fofa" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v fofa" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for hunter" {
    run bash -c 'grep -rl "hunter" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v hunter" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for quake" {
    run bash -c 'grep -rl "quake" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v quake" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for binaryedge" {
    run bash -c 'grep -rl "binaryedge" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v binaryedge" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for onyphe" {
    run bash -c 'grep -rl "onyphe" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v onyphe" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for threatcrowd" {
    run bash -c 'grep -rl "threatcrowd" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v threatcrowd" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for threatminer" {
    run bash -c 'grep -rl "threatminer" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v threatminer" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for passivetotal" {
    run bash -c 'grep -rl "passivetotal" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v passivetotal" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for riskiq" {
    run bash -c 'grep -rl "riskiq" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v riskiq" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for recordedfuture" {
    run bash -c 'grep -rl "recordedfuture" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v recordedfuture" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for anomali" {
    run bash -c 'grep -rl "anomali" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v anomali" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for threatconnect" {
    run bash -c 'grep -rl "threatconnect" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v threatconnect" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for ibm-xforce" {
    run bash -c 'grep -rl "ibm-xforce" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v ibm-xforce" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for exchange" {
    run bash -c 'grep -rl "exchange" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v exchange" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for cisco-talos" {
    run bash -c 'grep -rl "cisco-talos" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v cisco-talos" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for proofpoint" {
    run bash -c 'grep -rl "proofpoint" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v proofpoint" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for virustotal" {
    run bash -c 'grep -rl "virustotal" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v virustotal" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for urlscan" {
    run bash -c 'grep -rl "urlscan" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v urlscan" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for urlhaus" {
    run bash -c 'grep -rl "urlhaus" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v urlhaus" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for abuseipdb" {
    run bash -c 'grep -rl "abuseipdb" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v abuseipdb" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for ipinfo" {
    run bash -c 'grep -rl "ipinfo" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v ipinfo" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for ipapi" {
    run bash -c 'grep -rl "ipapi" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v ipapi" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for ipgeolocation" {
    run bash -c 'grep -rl "ipgeolocation" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v ipgeolocation" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for ipregistry" {
    run bash -c 'grep -rl "ipregistry" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v ipregistry" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for ipdata" {
    run bash -c 'grep -rl "ipdata" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v ipdata" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for ipqualityscore" {
    run bash -c 'grep -rl "ipqualityscore" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v ipqualityscore" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for ipvoid" {
    run bash -c 'grep -rl "ipvoid" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v ipvoid" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for spamhaus" {
    run bash -c 'grep -rl "spamhaus" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v spamhaus" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for spamcop" {
    run bash -c 'grep -rl "spamcop" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v spamcop" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for surbl" {
    run bash -c 'grep -rl "surbl" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v surbl" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for uribl" {
    run bash -c 'grep -rl "uribl" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v uribl" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for dbl" {
    run bash -c 'grep -rl "dbl" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v dbl" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for multiuribl" {
    run bash -c 'grep -rl "multiuribl" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v multiuribl" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for rhsbl" {
    run bash -c 'grep -rl "rhsbl" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v rhsbl" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for dmarcian" {
    run bash -c 'grep -rl "dmarcian" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v dmarcian" 2>/dev/null || true'
    [ -z "$output" ]
}

@test "scripts check for dmarcreports" {
    run bash -c 'grep -rl "dmarcreports" "$PWNAGOTCHI_CONTROL_CENTER_DIR/Scripts/" 2>/dev/null | xargs grep -L "command -v dmarcreports" 2>/dev/null || true'
    [ -z "$output" ]
}
